// ============================================
// FILE: lib/fatures/reader/data/reader_local_storage.dart
// ============================================
//
// On-device reader data: the downloaded PDF files, each book's progress
// (last page, bookmarks, highlights) and the viewer settings.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/reader_models.dart';

abstract class ReaderLocalStorage {
  /// Returns the book's local PDF, downloading it first if it isn't cached.
  Future<File> getOrDownload(
    ReaderBook book, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  });

  Future<ReaderProgress> loadProgress(String bookId);
  Future<void> saveProgress(String bookId, ReaderProgress progress);

  Future<ReaderSettings> loadSettings();
  Future<void> saveSettings(ReaderSettings settings);

  /// Removes a book's cached file (e.g. if it turned out to be corrupt).
  Future<void> deleteCachedFile(ReaderBook book);
}

class ReaderLocalStorageImpl implements ReaderLocalStorage {
  final Dio _dio;

  ReaderLocalStorageImpl({Dio? dio}) : _dio = dio ?? Dio();

  static const _progressPrefix = 'reader_progress_';
  static const _continuousKey = 'reader_is_continuous';
  static const _horizontalKey = 'reader_is_horizontal';

  Future<File> _fileFor(ReaderBook book) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/reader');
    if (!await folder.exists()) await folder.create(recursive: true);
    // Keyed by id + url so a new edition at a new url is fetched again;
    // hashed to keep the file name short and filesystem-safe.
    return File('${folder.path}/${_hash('${book.id}|${book.pdfUrl}')}.pdf');
  }

  /// 64-bit FNV-1a as hex — stable across runs (unlike String.hashCode).
  static String _hash(String input) {
    var hash = BigInt.parse('cbf29ce484222325', radix: 16);
    final prime = BigInt.parse('100000001b3', radix: 16);
    final mask = (BigInt.one << 64) - BigInt.one;
    for (final byte in utf8.encode(input)) {
      hash = ((hash ^ BigInt.from(byte)) * prime) & mask;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  @override
  Future<File> getOrDownload(
    ReaderBook book, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final file = await _fileFor(book);
    if (await file.exists() && await file.length() > 0) return file;

    // Download to a temp file and rename at the end, so an interrupted
    // download never leaves a half-written PDF that looks cached.
    final partial = File('${file.path}.part');
    try {
      await _dio.download(
        book.pdfUrl,
        partial.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received / total);
        },
      );
      return await partial.rename(file.path);
    } catch (_) {
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedFile(ReaderBook book) async {
    final file = await _fileFor(book);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<ReaderProgress> loadProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_progressPrefix$bookId');
    if (raw == null) return const ReaderProgress();
    try {
      return ReaderProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const ReaderProgress();
    }
  }

  @override
  Future<void> saveProgress(String bookId, ReaderProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_progressPrefix$bookId',
      jsonEncode(progress.toJson()),
    );
  }

  @override
  Future<ReaderSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return ReaderSettings(
      isContinuous: prefs.getBool(_continuousKey) ?? true,
      isHorizontal: prefs.getBool(_horizontalKey) ?? false,
    );
  }

  @override
  Future<void> saveSettings(ReaderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_continuousKey, settings.isContinuous);
    await prefs.setBool(_horizontalKey, settings.isHorizontal);
  }
}
