// ============================================
// FILE: lib/fatures/library/screens/cubit/library_books_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../issues/data/models/pagination_meta.dart';
import '../../data/datasource/library_remote_data_source.dart';
import '../../../reader/data/models/reader_models.dart';
import '../../../reader/data/reader_local_storage.dart';
import '../../data/models/library_book_model.dart';

part 'library_books_state.dart';

class LibraryBooksCubit extends Cubit<LibraryBooksState> {
  final LibraryRemoteDataSource dataSource;

  /// Where the reader saves each book's last page — the API sends no
  /// reading progress, so the cards' progress bars come from here.
  final ReaderLocalStorage readerStorage;

  LibraryBooksCubit(this.dataSource, {ReaderLocalStorage? readerStorage})
    : readerStorage = readerStorage ?? ReaderLocalStorageImpl(),
      super(const LibraryBooksState());

  /// The reader entry for an owned book's file (null if it has none). Keep
  /// using this so the id matches the progress saved by the reader.
  static ReaderBook? readerBookOf(LibraryBookModel book) => ReaderBook.fromFile(
    id: book.id,
    title: book.title,
    fileUrl: book.fileUrl,
    fileType: book.fileType,
  );

  /// Re-reads saved reading progress — call after returning from the reader.
  Future<void> syncProgress() async {
    final updated = await _withLocalProgress(state.books);
    if (!isClosed) emit(state.copyWith(books: updated));
  }

  Future<List<LibraryBookModel>> _withLocalProgress(
    List<LibraryBookModel> books,
  ) {
    return Future.wait(
      books.map((b) async {
        final reader = readerBookOf(b);
        if (reader == null) return b;
        final saved = await readerStorage.loadProgress(reader.id);
        if (saved.totalPages <= 0) return b;
        return b.copyWith(
          progress: (saved.lastPage / saved.totalPages).clamp(0.0, 1.0),
        );
      }),
    );
  }

  bool _isFetching = false;

  Future<void> load() => _fetch(page: 1, reset: true);

  /// Pull-to-refresh: re-fetches page 1 but keeps the current list on
  /// screen (no full-screen loader) until the new page arrives.
  Future<void> refresh() => _fetch(page: 1, reset: true, silent: true);

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore) return;
    final next = (state.meta?.currentPage ?? 1) + 1;
    await _fetch(page: next, reset: false);
  }

  /// Local removal — no delete endpoint is available yet.
  void remove(String id) {
    final updated = state.books.where((b) => b.id != id).toList();
    emit(
      state.copyWith(
        books: updated,
        status: updated.isEmpty && state.status == LibraryBooksStatus.success
            ? LibraryBooksStatus.empty
            : state.status,
      ),
    );
  }

  Future<void> _fetch({
    required int page,
    required bool reset,
    bool silent = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (!silent) {
      emit(
        state.copyWith(
          status: reset
              ? LibraryBooksStatus.loading
              : LibraryBooksStatus.loadingMore,
          error: null,
        ),
      );
    }

    try {
      final result = await dataSource.getBooks(page: page);
      final items = await _withLocalProgress(result.items);
      final merged = reset ? items : [...state.books, ...items];

      emit(
        state.copyWith(
          status: merged.isEmpty
              ? LibraryBooksStatus.empty
              : LibraryBooksStatus.success,
          books: merged,
          meta: result.meta,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: state.books.isEmpty
              ? LibraryBooksStatus.failure
              : LibraryBooksStatus.success,
          error: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }
}
