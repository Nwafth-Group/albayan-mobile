
// ============================================
// FILE: lib/fatures/offers/screens/cubit/offer_details_cubit.dart
// ============================================
//
// Loads what an offer's page shows beyond the list item itself. The list
// item's `id` is the discounted thing's own id, so the content comes from
// that thing's endpoint: a package's books from `/public/packages/{id}`, an
// issue's short word + index from `/public/issues/{id}`, a book's overview
// from `/public/books/{id}`, an article's from `/public/articles/{id}`.
//
// A whole campaign opened from `/public/offers/{offerId}` (the urgent
// offer) arrives with its content already loaded, so nothing is fetched.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/api_client.dart';
import '../../../articles/data/datasource/articles_remote_data_source.dart';
import '../../../books/data/datasource/books_remote_data_source.dart';
import '../../../issues/data/datasource/issues_remote_data_source.dart';
import '../../data/datasource/offers_remote_data_source.dart';
import '../../data/models/offer_model.dart';

part 'offer_details_state.dart';

class OfferDetailsCubit extends Cubit<OfferDetailsState> {
  final OfferModel offer;
  final OffersRemoteDataSource offersDataSource;
  final IssuesRemoteDataSource issuesDataSource;
  final BooksRemoteDataSource booksDataSource;
  final ArticlesRemoteDataSource articlesDataSource;

  OfferDetailsCubit({
    required this.offer,
    OfferContent? initialContent,
    required this.offersDataSource,
    required this.issuesDataSource,
    required this.booksDataSource,
    required this.articlesDataSource,
  }) : super(
          initialContent != null
              ? OfferDetailsState(
                  status: OfferDetailsStatus.success,
                  content: initialContent,
                )
              : OfferDetailsState(content: OfferContent.fallback(offer)),
        );

  /// Builds the cubit with its datasources, following the app's
  /// construct-inline pattern (no service locator).
  factory OfferDetailsCubit.create(
    OfferModel offer, {
    OfferContent? initialContent,
  }) {
    final api = ApiService();
    return OfferDetailsCubit(
      offer: offer,
      initialContent: initialContent,
      offersDataSource: OffersRemoteDataSourceImpl(api),
      issuesDataSource: IssuesRemoteDataSourceImpl(api),
      booksDataSource: BooksRemoteDataSourceImpl(api),
      articlesDataSource: ArticlesRemoteDataSourceImpl(api),
    );
  }

  Future<void> load() async {
    // A campaign's content came with it; its id isn't a package/issue/book
    // /article id, so there's nothing else to fetch.
    if (offer.isCampaign) return;

    emit(state.copyWith(status: OfferDetailsStatus.loading, error: null));
    try {
      final content = await _loadContent();
      emit(state.copyWith(
        status: OfferDetailsStatus.success,
        content: content,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OfferDetailsStatus.failure,
        content: OfferContent.fallback(offer),
        error: e.toString(),
      ));
    }
  }

  Future<OfferContent> _loadContent() async {
    switch (offer.type) {
      case OfferType.package:
        final items = await offersDataSource.getPackageItems(offer.id);
        return OfferContent(packageItems: items);

      case OfferType.issue:
        final issue = await issuesDataSource.getIssueDetails(offer.id);
        return OfferContent(
          publishedAt: issue.publishedAt,
          shortWordTitle: issue.shortIntroduction?.title,
          shortWordSummary: issue.shortIntroduction?.summary,
          indexItems: issue.indexPreview
              .map((i) => OfferIndexItem(
                    titleAr: i.corner?.name ?? '',
                    description: i.article?.title ?? '',
                    author: i.author?.displayName ?? '',
                    image: i.article?.image,
                  ))
              .toList(),
        );

      case OfferType.book:
        final book = await booksDataSource.getBook(offer.id);
        return OfferContent(
          author: book.author?.displayName ?? offer.extraInfo,
          pagesCount: book.version.pagesTotal > 0
              ? book.version.pagesTotal
              : null,
          rate: book.rate,
          overview: book.version.description,
        );

      case OfferType.article:
        final article = await articlesDataSource.getArticle(offer.id);
        return OfferContent(
          author: article.author?.displayName,
          rate: article.rate,
          overview: (article.summary?.trim().isNotEmpty ?? false)
              ? article.summary
              : offer.extraInfo,
        );
    }
  }
}
