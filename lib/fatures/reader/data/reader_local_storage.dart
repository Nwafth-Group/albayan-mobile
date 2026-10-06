// ============================================
// FILE: lib/fatures/reader/data/reader_local_storage.dart
// ============================================
//
// On-device reader data: the downloaded PDF files, each book's progress
// (last page, bookmarks, highlights) and the viewer settings.

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/reader_models.dart';

/// `[Reader]` log line, shown alongside the app's `[API]` logs.
void readerLog(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(message, name: 'Reader', error: error, stackTrace: stackTrace);
}

/// The downloaded bytes aren't a PDF (e.g. the server returned an HTML error
/// page or an empty body).
class ReaderNotPdfException implements Exception {
  final String details;
  ReaderNotPdfException(this.details);
  @override
  String toString() => 'Downloaded file is not a PDF: $details';
}

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
    final Directory dir;
    try {
      dir = await getApplicationDocumentsDirectory();
    } catch (e, st) {
      // Typically MissingPluginException right after adding path_provider:
      // the app needs a full rebuild (stop + run), not a hot restart.
      readerLog('✖ documents directory unavailable', error: e, stackTrace: st);
      rethrow;
    }
    final folder = Directory('${dir.path}/reader');
    if (!await folder.exists()) await folder.create(recursive: true);
    // Keyed by id + url so a new edition at a new url is fetched again;
    // hashed to keep the file name short and filesystem-safe.
    return File('${folder.path}/${_hash('${book.id}|${book.pdfUrl}')}.pdf');
  }

  /// File urls come with raw spaces / Arabic letters, e.g.
  /// `.../ضجيج الصمت (نسخة تجريبية).pdf` — encode them, without
  /// double-encoding a url that is already encoded.
  static String encodeUrl(String url) {
    try {
      return Uri.encodeFull(Uri.decodeFull(url));
    } catch (_) {
      return Uri.encodeFull(url); // stray '%' that isn't an escape
    }
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
    readerLog('cache file: ${file.path}');

    if (await file.exists()) {
      final size = await file.length();
      if (size > 0 && await _looksLikePdf(file)) {
        readerLog('✔ using cached file ($size bytes)');
        return file;
      }
      readerLog('cached file is invalid ($size bytes) — re-downloading');
      await file.delete();
    }

    final url = encodeUrl(book.pdfUrl);
    readerLog('⬇ download start\n  raw url: ${book.pdfUrl}\n  encoded: $url');

    // Download to a temp file and rename at the end, so an interrupted
    // download never leaves a half-written PDF that looks cached.
    final partial = File('${file.path}.part');
    var lastLoggedStep = -1;
    try {
      final response = await _dio.download(
        url,
        partial.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received / total);
          // Log every 25% (or every ~1 MB when the size is unknown).
          final step = total > 0
              ? (received * 4 ~/ total)
              : (received ~/ (1024 * 1024));
          if (step != lastLoggedStep) {
            lastLoggedStep = step;
            readerLog('  … $received / ${total > 0 ? total : '?'} bytes');
          }
        },
      );
      final size = await partial.length();
      readerLog(
        '⬇ download done: HTTP ${response.statusCode}, '
        'content-type=${response.headers.value('content-type')}, '
        'content-length=${response.headers.value('content-length')}, '
        'saved=$size bytes',
      );

      if (size == 0 || !await _looksLikePdf(partial)) {
        final head = await _head(partial, 120);
        throw ReaderNotPdfException(
          'HTTP ${response.statusCode}, '
          'content-type=${response.headers.value('content-type')}, '
          '$size bytes, starts with: "$head"',
        );
      }
      final done = await partial.rename(file.path);
      readerLog('✔ file ready: ${done.path}');
      return done;
    } catch (e, st) {
      if (e is DioException && CancelToken.isCancel(e)) {
        readerLog('download cancelled (screen closed)');
      } else if (e is DioException) {
        readerLog(
          '✖ download failed: ${e.type.name} '
          'HTTP ${e.response?.statusCode} — ${e.message}',
          error: e.error ?? e,
          stackTrace: st,
        );
      } else {
        readerLog('✖ download failed', error: e, stackTrace: st);
      }
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
  }

  /// Every PDF starts with `%PDF-`.
  static Future<bool> _looksLikePdf(File file) async =>
      (await _head(file, 5)) == '%PDF-';

  static Future<String> _head(File file, int count) async {
    try {
      final bytes = await file.openRead(0, count).fold<List<int>>(
            [],
            (all, chunk) => all..addAll(chunk),
          );
      return utf8.decode(bytes, allowMalformed: true).replaceAll('\n', ' ');
    } catch (_) {
      return '';
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
