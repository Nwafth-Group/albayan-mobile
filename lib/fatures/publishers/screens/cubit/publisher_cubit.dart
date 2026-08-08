
// ============================================
// FILE: lib/fatures/publishers/screens/cubit/publisher_cubit.dart
// ============================================

import 'package:albayan/fatures/authors/data/models/book_model.dart';
import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/publishers_remote_data_source.dart';
import '../../data/models/publisher_detail_model.dart';

part 'publisher_state.dart';

class PublisherCubit extends Cubit<PublisherState> {
  final PublishersRemoteDataSource dataSource;
  final String publisherId;

  bool _fetchingBooks = false;

  PublisherCubit(this.dataSource, {required this.publisherId})
      : super(const PublisherState());

  /// Loads the publisher detail, then the first page of their books.
  Future<void> load() async {
    emit(state.copyWith(status: PublisherStatus.loading, error: null));
    try {
      final publisher = await dataSource.getPublisher(publisherId);
      emit(state.copyWith(status: PublisherStatus.success, publisher: publisher));
      await _fetchBooks(page: 1, reset: true);
    } catch (e) {
      emit(state.copyWith(status: PublisherStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadMoreBooks() async {
    if (_fetchingBooks || !state.booksHasMore) return;
    final next = (state.booksMeta?.currentPage ?? 1) + 1;
    await _fetchBooks(page: next, reset: false);
  }

  Future<void> _fetchBooks({required int page, required bool reset}) async {
    if (_fetchingBooks) return;
    _fetchingBooks = true;
    emit(state.copyWith(
      booksStatus: reset ? ListStatus.loading : ListStatus.loadingMore,
    ));
    try {
      final res = await dataSource.getBooks(id: publisherId, page: page);
      final merged = reset ? res.items : [...state.books, ...res.items];
      emit(state.copyWith(
        booksStatus: merged.isEmpty ? ListStatus.empty : ListStatus.success,
        books: merged,
        booksMeta: res.meta,
      ));
    } catch (_) {
      emit(state.copyWith(
        booksStatus:
            state.books.isEmpty ? ListStatus.failure : ListStatus.success,
      ));
    } finally {
      _fetchingBooks = false;
    }
  }
}
