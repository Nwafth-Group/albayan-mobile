// ============================================
// FILE: lib/fatures/library/utils/add_to_library_mixin.dart
// ============================================
//
// My Library membership via `POST /reader/my-library/toggle`:
// - [addFreeToLibrary] — "Read Now" on free content: makes sure the item is
//   in the library (never removes it).
// - [toggleLibrary] — the header book icon: adds or removes the item.
//
// The loaded details aren't refetched afterwards, so the latest in/out
// state of each item is remembered for the session.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../data/datasource/library_remote_data_source.dart';
import 'library_events.dart';

/// The `type` values the toggle endpoint accepts.
enum LibraryItemType { book, issue, article }

mixin AddToLibraryStateMixin<T extends StatefulWidget> on State<T> {
  /// `type:id` → in My Library, for items toggled this session.
  static final Map<String, bool> _sessionState = {};

  final LibraryRemoteDataSource _libraryDataSource =
      LibraryRemoteDataSourceImpl(ApiService());

  bool _addingToLibrary = false;
  bool get isAddingToLibrary => _addingToLibrary;

  /// Whether the item is in My Library: its latest state this session, else
  /// the loaded details' flag ([owned]).
  bool isInLibrary({
    required LibraryItemType type,
    required String id,
    required bool owned,
  }) => _sessionState['${type.name}:$id'] ?? owned;

  /// Makes sure a free item is in My Library. Returns true when it is (or
  /// already was); false if the request failed (the error is already shown
  /// by ApiService). Never removes an item.
  Future<bool> addFreeToLibrary({
    required LibraryItemType type,
    required String id,
    required bool alreadyInLibrary,
  }) async {
    final key = '${type.name}:$id';
    if (_sessionState[key] ?? alreadyInLibrary) return true;
    if (_addingToLibrary) return false;

    setState(() => _addingToLibrary = true);
    try {
      var inLibrary = await _libraryDataSource.toggleLibraryItem(
        type: type.name,
        id: id,
      );
      // It was in the library after all and just got toggled out — add back.
      if (inLibrary == false) {
        inLibrary = await _libraryDataSource.toggleLibraryItem(
          type: type.name,
          id: id,
        );
      }
      _sessionState[key] = true;
      LibraryEvents.notifyChanged();
      AppNavigator.showSuccessSnackBar(AppStrings.addedToLibrary.tr());
      return true;
    } catch (_) {
      // ApiService already surfaced the error via a snackbar.
      return false;
    } finally {
      if (mounted) setState(() => _addingToLibrary = false);
    }
  }

  /// Adds the item to My Library, or removes it if it's already there.
  /// Returns whether it's in the library now, or null if the request failed
  /// (the error is already shown by ApiService).
  Future<bool?> toggleLibrary({
    required LibraryItemType type,
    required String id,
    required bool inLibrary,
  }) async {
    if (_addingToLibrary) return null;
    final key = '${type.name}:$id';
    final current = _sessionState[key] ?? inLibrary;

    setState(() => _addingToLibrary = true);
    try {
      final result = await _libraryDataSource.toggleLibraryItem(
        type: type.name,
        id: id,
      );
      // No state in the response → it flipped.
      final nowInLibrary = result ?? !current;
      _sessionState[key] = nowInLibrary;
      LibraryEvents.notifyChanged();
      AppNavigator.showSuccessSnackBar(
        (nowInLibrary
                ? AppStrings.addedToLibrary
                : AppStrings.removedFromLibrary)
            .tr(),
      );
      return nowInLibrary;
    } catch (_) {
      // ApiService already surfaced the error via a snackbar.
      return null;
    } finally {
      if (mounted) setState(() => _addingToLibrary = false);
    }
  }
}
