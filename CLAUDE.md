# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Albayan is a Flutter application (Dart SDK ^3.11.4) for a digital publishing/magazine platform — issues, articles, books, authors, publishers, a cart/checkout flow, and a library of owned content. It targets iOS, Android, and Windows.

## Commands

```bash
flutter pub get                 # install dependencies after touching pubspec.yaml
flutter run                     # run on a connected device/simulator
flutter analyze                 # static analysis (uses analysis_options.yaml / flutter_lints)
flutter test                    # run all tests
flutter test test/widget_test.dart   # run a single test file
flutter build ios / apk / windows    # platform builds
```

There is no custom lint config beyond the default `flutter_lints` ruleset (`analysis_options.yaml`). There is currently only one test file (`test/widget_test.dart`); most features have no test coverage yet.

CocoaPods (`ios/Podfile.lock`) is tracked as an untracked/new file in git status — check whether it should be committed before assuming it's ignored.

## Architecture

### Feature-first structure

All app code lives under `lib/fatures/<feature>/` (note: "fatures", not "features" — this typo is baked into every import path throughout the codebase; match it exactly). Each feature follows the same internal layout:

```
lib/fatures/<feature>/
  data/
    datasource/   # abstract class + *Impl calling ApiService, e.g. BooksRemoteDataSource / BooksRemoteDataSourceImpl
    models/       # plain Dart model classes with fromJson/toJson, response wrappers (e.g. BooksResponse.fromData)
  screens/
    <feature>_screen.dart        # widget, wraps itself in a BlocProvider
    cubit/
      <name>_cubit.dart          # extends Cubit<State>, `part 'xxx_state.dart'`
      <name>_state.dart          # `part of` the cubit file, extends Equatable, has copyWith
    widgets/                     # screen-local widgets
```

Not every feature has every subfolder (e.g. `cart`, `home`, `main`, `settings` are lighter-weight).

### State management (Cubit, no service locator)

- State management is `flutter_bloc` Cubits, not Blocs — one cubit per screen/concern.
- State classes are `Equatable`, immutable, with a `copyWith`, and typically a `status` enum (`initial/loading/loadingMore/success/empty/failure`) plus pagination fields (see `PaginationMeta`, `hasMore`).
- **There is no dependency injection container.** Screens construct their own dependency chain inline where they build the `BlocProvider`:
  ```dart
  BlocProvider(
    create: (_) => BooksListCubit(BooksRemoteDataSourceImpl(ApiService())),
    ...
  )
  ```
  Follow this pattern for new screens rather than introducing a service locator/GetIt/Provider-of-services layer.
- List cubits generally implement `load`, `refresh`, `loadMore` (via `PaginationMeta`), and debounced `search` (via `Timer`) with an `_isFetching` guard against concurrent fetches — mirror this shape for new paginated lists.

### Networking

- All HTTP goes through `lib/utils/api_client.dart`'s `ApiService`, a thin Dio wrapper with request/response/error logging interceptors, automatic `Authorization: Bearer <token>` injection from `SharedPrefHelper`, and a `_handleError` that turns `DioException`s into user-facing message strings (also surfacing field-level `params` validation errors via `Helpers.showError`).
- Endpoint paths are centralized as string constants in `lib/utils/constants.dart` (`ApiConstants`), grouped by feature (auth, issues, corners, articles, authors, books, publishers, etc.). Add new endpoints there rather than inlining path strings in datasources.
- Datasources are abstract-class + `Impl` pairs taking an `ApiService` and returning typed models built from `response['data']`.

### Cross-cutting utils (`lib/utils/`)

- `constants.dart` — `ApiConstants` (endpoints), `AppColors`, `AppImages`, `AppDimensions`, `StorageKeys`, `AppStrings` (all `easy_localization` translation keys used across the app — add new copy here rather than hardcoding strings).
- `api_client.dart` — `ApiService` (see Networking above).
- `shared_pref_helper.dart` — static wrapper around `SharedPreferences`; holds auth token, cached `UserModel`, login state, selected language, and first-launch flag. Must be initialized once in `main()` via `SharedPrefHelper.init(prefs)` before `runApp`.
- `app_navigator.dart` — global-key-based navigation/snackbar/dialog helper (`AppNavigator.push/pop/showSnackBar/...`) usable without a `BuildContext`, wired via `navigatorKey` on `MaterialApp`. Note some screens (e.g. `splash_screen.dart`) still navigate directly with `Navigator.pushReplacement` instead of `AppNavigator` — prefer `AppNavigator` for new code for consistency.
- `helpers.dart`, `theme.dart` — misc formatting helpers and theming.

Shared, reusable UI widgets (buttons, cards, dialogs, empty states, app bar, bottom nav) live in `lib/widgets/` (not per-feature).

### Localization

Uses `easy_localization` with `en` and `ar` locales, translation JSON in `assets/translations/{en,ar}.json`, loaded/wrapped around `MyApp` in `main.dart`. All user-facing strings should be added as keys in both JSON files and referenced via `AppStrings` constants + `.tr()`.

### App entry / startup flow

`main.dart` initializes `WidgetsFlutterBinding`, `EasyLocalization`, and `SharedPreferences`/`SharedPrefHelper` before `runApp`. `SplashScreen` then routes based on `SharedPrefHelper.hasLaunchedBefore()` and `isLoggedIn()` to either language selection, login, or `MainScreen` (the bottom-nav shell for home/library/search/cart/settings).
