
// ============================================
// FILE: lib/fatures/offers/data/offers_mock_data.dart
// ============================================
//
// Placeholder data source. Swap this out for a real API call once an
// offers endpoint is available — everything downstream (screens, cubits-to
// -be) only depends on `OfferModel`, so the change is localized to here.

import 'models/offer_model.dart';

const _darwishCover =
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac43562e_book1.jpg';
const _book2Cover =
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac440a79_book2.jpg';
const _book3Cover =
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac44aa1e_book3.jpg';
const _book4Cover =
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac4569bd_book4.jpg';

List<OfferModel> mockOffers() {
  final now = DateTime.now();

  final packageItems = [
    const OfferPackageItem(
      id: 'pkg-item-1',
      image: null,
      title: 'Dark woods, 0904',
      author: 'Dr. Ahmad Hassan',
      price: 35.09,
      rate: 5,
    ),
    OfferPackageItem(
      id: 'pkg-item-2',
      image: _darwishCover,
      title: 'Dark woods, 0904',
      author: 'Dr. Ahmad Hassan',
      price: 35.09,
      rate: 5,
    ),
    const OfferPackageItem(
      id: 'pkg-item-3',
      image: null,
      title: 'Dark woods, 0904',
      author: 'Dr. Ahmad Hassan',
      price: 35.09,
      rate: 5,
    ),
    const OfferPackageItem(
      id: 'pkg-item-4',
      image: null,
      title: 'Dark woods, 0904',
      author: 'Dr. Ahmad Hassan',
      price: 35.09,
      rate: 5,
    ),
  ];

  final indexItems = [
    const OfferIndexItem(
      titleAr: 'الافتتاحية',
      description: 'Adobe abandons \$20 billion acquisition of Figma',
      author: 'Dr. Ahmad Hassan',
      image: null,
    ),
    const OfferIndexItem(
      titleAr: 'العقيدة والشريعة',
      description: 'Adobe abandons \$20 billion acquisition of Figma',
      author: 'Dr. Ahmad Hassan',
      image: null,
    ),
    const OfferIndexItem(
      titleAr: 'الباب المفتوح',
      description: 'Adobe abandons \$20 billion acquisition of Figma',
      author: 'Dr. Ahmad Hassan',
      image: null,
    ),
  ];

  const overviewText =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
      'ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut '
      'aliquip ex ea commodo consequat nisi ut aliquip ex ea commodo '
      'consequat m ipsum dolor sit amet, consectetur adipiscing elit, sed '
      'do eius\n\n'
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
      'ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut '
      'aliquip ex ea commodo consequat nisi ut aliquip ex ea commodo '
      'consequat m ipsum dolor sit amet, consectetur adipiscing';

  return [
    OfferModel(
      id: 'offer-book-1',
      type: OfferType.book,
      name: 'Adobe abandons \$20 billion acquisition of Figma - book name',
      image: _darwishCover,
      discountPercent: 25,
      oldPrice: 340,
      newPrice: 300,
      date: DateTime(2026, 5, 6),
      endsAt: now.add(const Duration(hours: 12, minutes: 14, seconds: 56)),
      author: 'Dr. Ahmad Hassan',
      pagesCount: 345,
      rate: 5,
      overview: overviewText,
    ),
    OfferModel(
      id: 'offer-package-1',
      type: OfferType.package,
      name: 'Eid Offer',
      image: null,
      discountPercent: 25,
      oldPrice: 340,
      newPrice: 300,
      date: DateTime(2026, 5, 6),
      endsAt: now.add(const Duration(hours: 12, minutes: 14, seconds: 56)),
      booksCount: 4,
      packageItems: packageItems,
    ),
    OfferModel(
      id: 'offer-article-1',
      type: OfferType.article,
      name: 'Adobe abandons \$20 billion acquisition of Figma',
      image: _book3Cover,
      discountPercent: 35,
      oldPrice: 340,
      newPrice: 300,
      date: DateTime(2026, 5, 6),
      endsAt: now.add(const Duration(hours: 12, minutes: 14, seconds: 56)),
      author: 'Dr. Ahmad Hassan',
      rate: 4,
      overview: overviewText,
    ),
    OfferModel(
      id: 'offer-package-2',
      type: OfferType.package,
      name: 'Offer Name',
      image: null,
      discountPercent: 25,
      oldPrice: 340,
      newPrice: 300,
      date: DateTime(2026, 5, 6),
      endsAt: now.add(const Duration(hours: 12, minutes: 14, seconds: 56)),
      booksCount: 4,
      packageItems: packageItems,
    ),
    OfferModel(
      id: 'offer-article-2',
      type: OfferType.article,
      name: 'Adobe abandons \$20 billion acquisition of Figma',
      image: _book3Cover,
      discountPercent: 35,
      oldPrice: 340,
      newPrice: 300,
      date: DateTime(2026, 5, 6),
      endsAt: now.add(const Duration(hours: 12, minutes: 14, seconds: 56)),
      author: 'Dr. Ahmad Hassan',
      rate: 4,
      overview: overviewText,
    ),
    OfferModel(
      id: 'offer-book-2',
      type: OfferType.book,
      name: 'Offer Name',
      image: _book4Cover,
      discountPercent: 25,
      oldPrice: 340,
      newPrice: 300,
      date: DateTime(2026, 5, 6),
      endsAt: now.add(const Duration(hours: 12, minutes: 14, seconds: 56)),
      author: 'Dr. Ahmad Hassan',
      pagesCount: 280,
      rate: 4.5,
      overview: overviewText,
    ),
    OfferModel(
      id: 'offer-issue-1',
      type: OfferType.issue,
      name: 'Dark woods, 0904',
      image: _book2Cover,
      discountPercent: 25,
      oldPrice: 0,
      newPrice: 35.09,
      date: DateTime(2026, 5, 3),
      endsAt: now.add(
        const Duration(days: 1, hours: 3, minutes: 14, seconds: 56),
      ),
      shortWordTitle: 'Lorem Title',
      shortWordSummary: overviewText,
      indexItems: indexItems,
    ),
    OfferModel(
      id: 'offer-issue-2',
      type: OfferType.issue,
      name: 'Dark woods, 0904',
      image: _book2Cover,
      discountPercent: 25,
      oldPrice: 0,
      newPrice: 35.09,
      date: DateTime(2026, 5, 6),
      endsAt: now.add(
        const Duration(days: 1, hours: 3, minutes: 14, seconds: 56),
      ),
      shortWordTitle: 'Lorem Title',
      shortWordSummary: overviewText,
      indexItems: indexItems,
    ),
  ];
}
