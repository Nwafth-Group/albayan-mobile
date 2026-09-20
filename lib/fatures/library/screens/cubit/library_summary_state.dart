
// ============================================
// FILE: lib/fatures/library/screens/cubit/library_summary_state.dart
// ============================================

part of 'library_summary_cubit.dart';

enum LibrarySummaryStatus { initial, loading, success, failure }

class LibrarySummaryState extends Equatable {
  final LibrarySummaryStatus status;
  final LibrarySummaryModel summary;
  final String? error;

  const LibrarySummaryState({
    this.status = LibrarySummaryStatus.initial,
    this.summary = LibrarySummaryModel.empty,
    this.error,
  });

  bool get isLoading => status == LibrarySummaryStatus.loading;

  LibrarySummaryState copyWith({
    LibrarySummaryStatus? status,
    LibrarySummaryModel? summary,
    String? error,
  }) {
    return LibrarySummaryState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, summary, error];
}
