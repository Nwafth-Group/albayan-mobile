// ============================================
// FILE: lib/fatures/reader/screens/cubit/reader_cubit.dart
// ============================================

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/constants.dart';

import '../../data/models/reader_models.dart';
import '../../data/reader_local_storage.dart';

part 'reader_state.dart';

class ReaderCubit extends Cubit<ReaderState> {
  final ReaderLocalStorage storage;
  final ReaderBook book;

  CancelToken? _downloadToken;

  ReaderCubit(this.storage, {required this.book})
      : super(const ReaderState());

  /// Loads saved progress + settings, then the PDF (downloading if needed).
  Future<void> load() async {
    readerLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    readerLog('📖 open "${book.title}"\n  id: ${book.id}\n  '
        'sample: ${book.isSample}\n  url: ${book.pdfUrl}');
    emit(state.copyWith(status: ReaderStatus.downloading, progress: 0));
    try {
      final saved = await storage.loadProgress(book.id);
      final settings = await storage.loadSettings();
      readerLog('saved progress: page ${saved.lastPage}/${saved.totalPages}, '
          '${saved.bookmarks.length} bookmarks, '
          '${saved.highlights.length} highlights; '
          'continuous=${settings.isContinuous} horizontal=${settings.isHorizontal}');
      emit(state.copyWith(
        currentPage: saved.lastPage < 1 ? 1 : saved.lastPage,
        totalPages: saved.totalPages,
        bookmarks: saved.bookmarks,
        highlights: saved.highlights,
        settings: settings,
      ));

      _downloadToken = CancelToken();
      final file = await storage.getOrDownload(
        book,
        cancelToken: _downloadToken,
        onProgress: (p) {
          if (!isClosed) emit(state.copyWith(progress: p));
        },
      );
      if (isClosed) return;
      readerLog('handing file to the PDF viewer: ${file.path}');
      emit(state.copyWith(status: ReaderStatus.ready, file: file));
    } catch (e, st) {
      if (isClosed || (e is DioException && CancelToken.isCancel(e))) return;
      readerLog('✖ open failed: ${e.runtimeType}: $e', error: e, stackTrace: st);
      emit(state.copyWith(
        status: ReaderStatus.failure,
        error: _messageFor(e),
        debugDetails: '${e.runtimeType}: $e',
      ));
    }
  }

  /// A readable, translated reason — never Dio's technical text. Null when
  /// there's nothing more useful than the screen's "couldn't open" title.
  String? _messageFor(Object e) {
    if (e is! DioException) return null;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return AppStrings.errorConnectionTimeout.tr();
      case DioExceptionType.receiveTimeout:
        return AppStrings.errorServerTimeout.tr();
      case DioExceptionType.connectionError:
        return AppStrings.errorNoInternet.tr();
      default:
        return null;
    }
  }

  /// The viewer couldn't parse the file — drop the cached copy so a retry
  /// downloads it again instead of reopening the same broken file.
  Future<void> onDocumentLoadFailed(String error, String description) async {
    readerLog('✖ PDF viewer could not load the file: $error — $description');
    await storage.deleteCachedFile(book);
    emit(state.copyWith(
      status: ReaderStatus.failure,
      error: description,
      debugDetails: 'SfPdfViewer: $error — $description',
    ));
  }

  void onDocumentLoaded(int totalPages) {
    readerLog('✔ PDF viewer loaded the document: $totalPages pages');
    if (totalPages == state.totalPages) return;
    emit(state.copyWith(totalPages: totalPages));
    _save();
  }

  void onPageChanged(int page) {
    if (page == state.currentPage) return;
    emit(state.copyWith(currentPage: page));
    _save();
  }

  // ── Bookmarks ───────────────────────────────────────────

  /// Adds a bookmark on the current page, or removes it if there is one.
  /// Returns true when a bookmark was added.
  bool toggleBookmark() {
    final page = state.currentPage;
    final exists = state.bookmarks.any((b) => b.page == page);
    final updated = exists
        ? state.bookmarks.where((b) => b.page != page).toList()
        : ([...state.bookmarks, ReaderBookmark(page: page, createdAt: DateTime.now())]
          ..sort((a, b) => a.page.compareTo(b.page)));
    emit(state.copyWith(bookmarks: updated));
    _save();
    return !exists;
  }

  void removeBookmark(ReaderBookmark bookmark) {
    emit(state.copyWith(
      bookmarks: state.bookmarks.where((b) => b.page != bookmark.page).toList(),
    ));
    _save();
  }

  // ── Highlights ──────────────────────────────────────────

  void addHighlight(ReaderHighlight highlight) {
    emit(state.copyWith(highlights: [...state.highlights, highlight]));
    _save();
  }

  void removeHighlightAt(int index) {
    final updated = [...state.highlights]..removeAt(index);
    emit(state.copyWith(highlights: updated));
    _save();
  }

  // ── Viewer settings ─────────────────────────────────────

  void toggleLayout() => _updateSettings(
        state.settings.copyWith(isContinuous: !state.settings.isContinuous),
      );

  void toggleDirection() => _updateSettings(
        state.settings.copyWith(isHorizontal: !state.settings.isHorizontal),
      );

  void _updateSettings(ReaderSettings settings) {
    emit(state.copyWith(settings: settings));
    storage.saveSettings(settings);
  }

  void _save() {
    storage.saveProgress(
      book.id,
      ReaderProgress(
        lastPage: state.currentPage,
        totalPages: state.totalPages,
        bookmarks: state.bookmarks,
        highlights: state.highlights,
      ),
    );
  }

  @override
  Future<void> close() {
    _downloadToken?.cancel();
    return super.close();
  }
}
