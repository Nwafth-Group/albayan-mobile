// ============================================
// FILE: lib/fatures/library/utils/add_to_library_mixin.dart
// ============================================
//
// "Read Now" on free content: adds the item to My Library directly
// (`POST /reader/my-library/toggle`, no checkout) and refreshes the library.
//
// The endpoint *toggles*, so it's only called when the item isn't already
// in the library — callers pass the API's `is_owned` / `is_bought` flag,
// and items added during this session are remembered so a second tap
// can't remove them.

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
  static final Set<String> _addedThisSession = {};

  final LibraryRemoteDataSource _libraryDataSource =
      LibraryRemoteDataSourceImpl(ApiService());

  bool _addingToLibrary = false;
  bool get isAddingToLibrary => _addingToLibrary;

  /// Makes sure a free item is in My Library. Returns true when it is (or
  /// already was); false if the request failed (the error is already shown
  /// by ApiService). Never removes an item.
  Future<bool> addFreeToLibrary({
    required LibraryItemType type,
    required String id,
    required bool alreadyInLibrary,
  }) async {
    final key = '${type.name}:$id';
    if (alreadyInLibrary || _addedThisSession.contains(key)) return true;
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
      _addedThisSession.add(key);
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
}
