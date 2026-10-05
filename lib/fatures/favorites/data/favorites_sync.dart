
// ============================================
// FILE: lib/fatures/favorites/data/favorites_sync.dart
// ============================================
//
// App-wide favorites. Every heart in the app toggles through here, and every
// confirmed change is broadcast on [FavoritesSync.changes] so any other
// screen showing the same item (a list behind a detail page, the Library's
// Favorites tab) updates its heart without a reload.
//
// This is a notification channel, not a service locator: cubits still get
// their own datasources the usual way and just subscribe to this stream.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/shared_pref_helper.dart';
import '../../auth/screens/login_screen.dart';
import 'datasource/favorites_remote_data_source.dart';
import 'models/favorite_item_model.dart';

class FavoriteChange {
  final FavoriteType type;
  final String id;
  final bool isFavorite;

  const FavoriteChange({
    required this.type,
    required this.id,
    required this.isFavorite,
  });

  bool matches(FavoriteType type, String id) =>
      this.type == type && this.id == id;
}

class FavoritesSync {
  FavoritesSync._();

  static final _changes = StreamController<FavoriteChange>.broadcast();
  static final _inFlight = <String>{};

  /// Every favorite state the server confirms, from anywhere in the app.
  static Stream<FavoriteChange> get changes => _changes.stream;

  /// Replaced only in tests; the app always talks to the real API.
  @visibleForTesting
  static FavoritesRemoteDataSource Function() dataSourceFactory =
      () => FavoritesRemoteDataSourceImpl(ApiService());

  static FavoritesRemoteDataSource _dataSource() => dataSourceFactory();

  static String _key(FavoriteType type, String id) => '${type.name}:$id';

  static bool isPending(FavoriteType type, String id) =>
      _inFlight.contains(_key(type, id));

  /// True for a logged-in reader; for a guest, shows a "log in" prompt and
  /// returns false (favorites live on the reader's account).
  static bool requireLogin() {
    if (SharedPrefHelper.isLoggedIn()) return true;
    AppNavigator.showSnackBar(
      AppStrings.loginToUseFavorites.tr(),
      action: SnackBarAction(
        label: AppStrings.login.tr(),
        textColor: AppColors.accentLight,
        onPressed: () => AppNavigator.push(const LoginScreen()),
      ),
    );
    return false;
  }

  /// Toggles [id] on the server and returns its new state, or null when
  /// nothing changed — the request failed (`ApiService` already showed the
  /// error) or the same item's toggle was already in flight.
  static Future<bool?> toggle(FavoriteType type, String id) async {
    final key = _key(type, id);
    if (!_inFlight.add(key)) return null;
    try {
      final isFavorite = await _dataSource().toggle(type: type, id: id);
      _changes.add(FavoriteChange(type: type, id: id, isFavorite: isFavorite));
      return isFavorite;
    } catch (_) {
      return null;
    } finally {
      _inFlight.remove(key);
    }
  }

  /// The toggle every cubit uses: flips the heart right away through
  /// [apply], then settles on the server's answer — or reverts to [current]
  /// if the request failed. Does nothing for a guest or a double tap.
  static Future<void> toggleOptimistic({
    required FavoriteType type,
    required String id,
    required bool current,
    required void Function(bool isFavorite) apply,
  }) async {
    if (id.isEmpty || !requireLogin() || isPending(type, id)) return;
    apply(!current);
    final result = await toggle(type, id);
    apply(result ?? current);
  }
}
