// ============================================
// FILE: lib/fatures/reader/screens/reader_screen.dart
// ============================================
//
// In-app PDF reader, ported from the E-Book app's DocumentScreen and styled
// with Albayan's colors. Open it with:
//
//   ReaderScreen.open(ReaderBook(id: ..., title: ..., pdfUrl: ...));
//
// Features: download + on-device cache, resume at the last page, search
// with next/previous, bookmarks, text highlights (saved per book), copy,
// zoom, go-to-page, page slider, continuous / page-by-page and vertical /
// horizontal scrolling, and a tap-to-hide immersive mode.

import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/models/reader_models.dart';
import '../data/reader_local_storage.dart';
import 'cubit/reader_cubit.dart';

/// Text highlight color — Albayan's terracotta accent.
const _highlightColor = AppColors.accentLight;

class ReaderScreen extends StatelessWidget {
  final ReaderBook book;

  const ReaderScreen({super.key, required this.book});

  /// Opens [book] in the reader.
  static Future<void> open(ReaderBook book) =>
      AppNavigator.push(ReaderScreen(book: book));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReaderCubit(ReaderLocalStorageImpl(), book: book)..load(),
      child: _ReaderView(book: book),
    );
  }
}

class _ReaderView extends StatefulWidget {
  final ReaderBook book;
  const _ReaderView({required this.book});

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  final _pdf = PdfViewerController();
  final _viewerKey = GlobalKey<SfPdfViewerState>();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  PdfTextSearchResult? _search;
  OverlayEntry? _selectionMenu;
  bool _searchOpen = false;
  bool _showUI = true;

  /// The page being dragged to on the slider (null when not dragging).
  double? _sliderPage;

  ReaderCubit get _cubit => context.read<ReaderCubit>();

  @override
  void dispose() {
    _removeSelectionMenu();
    _search?.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _pdf.dispose();
    super.dispose();
  }

  // ── Search ──────────────────────────────────────────────

  void _openSearch() {
    setState(() {
      _searchOpen = true;
      _showUI = true;
    });
    _searchFocus.requestFocus();
  }

  void _runSearch(String query) {
    _clearSearchResult();
    if (query.trim().isEmpty) return;
    _search = _pdf.searchText(query.trim())..addListener(_onSearchChanged);
    setState(() {});
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  void _clearSearchResult() {
    _search?.removeListener(_onSearchChanged);
    _search?.clear();
    _search = null;
  }

  void _closeSearch() {
    _clearSearchResult();
    _searchCtrl.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _searchOpen = false);
  }

  // ── Zoom / navigation ───────────────────────────────────

  void _zoomBy(double delta) {
    _pdf.zoomLevel = (_pdf.zoomLevel + delta).clamp(1.0, 3.0);
  }

  void _toggleBookmark() {
    final added = _cubit.toggleBookmark();
    AppNavigator.showSnackBar(
      added
          ? AppStrings.readerBookmarkAdded.tr()
          : AppStrings.readerBookmarkRemoved.tr(),
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.primary,
    );
  }

  // ── Highlights ──────────────────────────────────────────

  /// Draws every saved highlight on the document.
  void _applyHighlights(List<ReaderHighlight> highlights) {
    _pdf.removeAllAnnotations();
    for (final h in highlights) {
      if (h.bounds.length != 4) continue;
      final line = PdfTextLine(
        Rect.fromLTRB(h.bounds[0], h.bounds[1], h.bounds[2], h.bounds[3]),
        h.text,
        h.page,
      );
      _pdf.addAnnotation(
        HighlightAnnotation(textBoundsCollection: [line])
          ..color = _highlightColor,
      );
    }
  }

  void _highlightSelection(String selectedText) {
    final lines = _viewerKey.currentState?.getSelectedTextLines() ?? [];
    _removeSelectionMenu();
    if (lines.isEmpty) return;

    _pdf.addAnnotation(
      HighlightAnnotation(textBoundsCollection: lines)..color = _highlightColor,
    );

    var left = lines.first.bounds.left;
    var top = lines.first.bounds.top;
    var right = lines.first.bounds.right;
    var bottom = lines.first.bounds.bottom;
    for (final l in lines) {
      left = math.min(left, l.bounds.left);
      top = math.min(top, l.bounds.top);
      right = math.max(right, l.bounds.right);
      bottom = math.max(bottom, l.bounds.bottom);
    }
    _cubit.addHighlight(ReaderHighlight(
      page: lines.first.pageNumber,
      text: selectedText,
      bounds: [left, top, right, bottom],
    ));
    _pdf.clearSelection();
    AppNavigator.showSnackBar(
      AppStrings.readerHighlightAdded.tr(),
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.primary,
    );
  }

  // ── Selection menu (copy / highlight) ───────────────────

  void _removeSelectionMenu() {
    _selectionMenu?.remove();
    _selectionMenu = null;
  }

  void _onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    final text = details.selectedText;
    final region = details.globalSelectedRegion;
    if (text == null || text.trim().isEmpty || region == null) {
      _removeSelectionMenu();
      return;
    }
    _showSelectionMenu(text, region);
  }

  void _showSelectionMenu(String text, Rect region) {
    _removeSelectionMenu();
    final screen = MediaQuery.of(context).size;
    const menuWidth = 210.0;
    const menuHeight = 48.0;

    var left = (region.center.dx - menuWidth / 2)
        .clamp(16.0, screen.width - menuWidth - 16);
    var top = region.top - menuHeight - 12;
    if (top < MediaQuery.of(context).padding.top + 8) {
      top = region.bottom + 12; // no room above — show it below
    }

    _selectionMenu = OverlayEntry(
      builder: (_) => Positioned(
        left: left.toDouble(),
        top: top,
        child: Material(
          color: AppColors.primary,
          elevation: 6,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuAction(
                icon: Icons.copy_rounded,
                label: AppStrings.readerCopy.tr(),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: text));
                  _pdf.clearSelection();
                  _removeSelectionMenu();
                  AppNavigator.showSnackBar(
                    AppStrings.readerCopied.tr(),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.primary,
                  );
                },
              ),
              Container(width: 1, height: 24, color: Colors.white24),
              _MenuAction(
                icon: Icons.border_color_rounded,
                label: AppStrings.readerHighlight.tr(),
                onTap: () => _highlightSelection(text),
              ),
            ],
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_selectionMenu!);
  }

  // ── Build ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReaderCubit, ReaderState>(
      listenWhen: (a, b) => a.highlights.length != b.highlights.length,
      // A removed highlight has to disappear from the page too.
      listener: (_, state) => _applyHighlights(state.highlights),
      builder: (context, state) {
        final ready = state.status == ReaderStatus.ready;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: (_showUI || !ready) ? _appBar(state) : null,
          body: switch (state.status) {
            ReaderStatus.downloading => _DownloadingView(
                title: widget.book.title,
                progress: state.progress,
              ),
            ReaderStatus.failure => EmptyStateWidget(
                icon: Icons.menu_book_outlined,
                message: AppStrings.readerOpenFailed.tr(),
                message2: state.error,
                actionText: AppStrings.retry.tr(),
                onAction: _cubit.load,
              ),
            ReaderStatus.ready => _readerBody(state),
          },
        );
      },
    );
  }

  PreferredSizeWidget _appBar(ReaderState state) {
    final ready = state.status == ReaderStatus.ready;
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => AppNavigator.pop(),
      ),
      titleSpacing: 0,
      title: Text(
        widget.book.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        if (ready) ...[
          _CircleIconButton(icon: Icons.search_rounded, onTap: _openSearch),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: state.isCurrentPageBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            onTap: _toggleBookmark,
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.more_horiz_rounded,
            onTap: () => _showMenuSheet(),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
        ],
      ],
      bottom: (ready && _searchOpen)
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: _searchBar(),
            )
          : null,
    );
  }

  Widget _searchBar() {
    final result = _search;
    String? counter;
    if (result != null && result.isSearchCompleted) {
      counter = result.totalInstanceCount == 0
          ? AppStrings.readerNoMatches.tr()
          : '${result.currentInstanceIndex}/${result.totalInstanceCount}';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                onSubmitted: _runSearch,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: AppStrings.readerSearchHint.tr(),
                  hintStyle: const TextStyle(color: AppColors.textLight),
                ),
              ),
            ),
            if (counter != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: Text(
                  counter,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            if (result != null && result.hasResult) ...[
              _SmallIcon(
                icon: Icons.keyboard_arrow_up_rounded,
                onTap: result.previousInstance,
              ),
              _SmallIcon(
                icon: Icons.keyboard_arrow_down_rounded,
                onTap: result.nextInstance,
              ),
            ],
            _SmallIcon(icon: Icons.close_rounded, onTap: _closeSearch),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  Widget _readerBody(ReaderState state) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: Theme(
            // Tints the viewer's own chrome (scroll head, selection
            // handles, page gutter) with Albayan's palette.
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: AppColors.primary,
                surface: AppColors.surfaceVariant,
                onSurface: AppColors.textPrimary,
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: _highlightColor.withValues(alpha: 0.4),
                selectionHandleColor: AppColors.primary,
              ),
            ),
            child: SfPdfViewer.file(
              state.file!,
              key: _viewerKey,
              controller: _pdf,
              initialPageNumber: state.currentPage,
              pageSpacing: 6,
              enableTextSelection: true,
              canShowTextSelectionMenu: false,
              canShowScrollHead: false,
              canShowPaginationDialog: false,
              enableDocumentLinkAnnotation: true,
              pageLayoutMode: state.settings.isContinuous
                  ? PdfPageLayoutMode.continuous
                  : PdfPageLayoutMode.single,
              scrollDirection: state.settings.isHorizontal
                  ? PdfScrollDirection.horizontal
                  : PdfScrollDirection.vertical,
              onDocumentLoaded: (details) {
                _cubit.onDocumentLoaded(details.document.pages.count);
                _applyHighlights(state.highlights);
              },
              onDocumentLoadFailed: (details) =>
                  _cubit.onDocumentLoadFailed(details.description),
              onPageChanged: (details) =>
                  _cubit.onPageChanged(details.newPageNumber),
              onTextSelectionChanged: _onTextSelectionChanged,
              onTap: (_) {
                if (_selectionMenu != null) return;
                setState(() => _showUI = !_showUI);
              },
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          left: 0,
          right: 0,
          bottom: _showUI ? 0 : -160,
          child: _bottomBar(state),
        ),
      ],
    );
  }

  Widget _bottomBar(ReaderState state) {
    final total = state.totalPages;
    final shownPage = _sliderPage?.round() ?? state.currentPage;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.zoom_out_rounded,
                    onTap: () => _zoomBy(-0.25),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: total > 1 ? () => _showGoToPage(total) : null,
                      child: Text(
                        total > 0
                            ? AppStrings.readerPageOf.tr(namedArgs: {
                                'page': '$shownPage',
                                'total': '$total',
                              })
                            : '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.zoom_in_rounded,
                    onTap: () => _zoomBy(0.25),
                  ),
                ],
              ),
              if (total > 1)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.surfaceVariant,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.12),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    min: 1,
                    max: total.toDouble(),
                    value: (_sliderPage ?? state.currentPage.toDouble())
                        .clamp(1, total.toDouble()),
                    onChanged: (v) => setState(() => _sliderPage = v),
                    onChangeEnd: (v) {
                      _pdf.jumpToPage(v.round());
                      setState(() => _sliderPage = null);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sheets & dialogs ────────────────────────────────────

  Future<void> _showGoToPage(int total) async {
    final ctrl = TextEditingController();
    final page = await showDialog<int>(
      context: context,
      builder: (ctx) {
        void submit() {
          final p = int.tryParse(ctrl.text.trim());
          if (p != null && p >= 1 && p <= total) Navigator.of(ctx).pop(p);
        }

        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          title: Text(
            AppStrings.readerGoToPage.tr(),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cursorColor: AppColors.primary,
            onSubmitted: (_) => submit(),
            decoration: InputDecoration(
              hintText: '1 - $total',
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppStrings.cancel.tr(),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: submit,
              child: Text(
                AppStrings.readerGo.tr(),
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
    ctrl.dispose();
    if (page != null) _pdf.jumpToPage(page);
  }

  Future<T?> _sheet<T>({required String title, required Widget child}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 14),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenuSheet() {
    _sheet(
      title: widget.book.title,
      child: BlocBuilder<ReaderCubit, ReaderState>(
        builder: (context, state) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          children: [
            _SheetTile(
              icon: Icons.bookmarks_outlined,
              title: AppStrings.readerBookmarks.tr(),
              trailing: '${state.bookmarks.length}',
              onTap: () {
                Navigator.of(context).pop();
                _showBookmarksSheet();
              },
            ),
            _SheetTile(
              icon: Icons.border_color_outlined,
              title: AppStrings.readerHighlights.tr(),
              trailing: '${state.highlights.length}',
              onTap: () {
                Navigator.of(context).pop();
                _showHighlightsSheet();
              },
            ),
            if (state.totalPages > 1)
              _SheetTile(
                icon: Icons.find_in_page_outlined,
                title: AppStrings.readerGoToPage.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  _showGoToPage(state.totalPages);
                },
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Text(
                AppStrings.readerViewOptions.tr(),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _ChoiceRow(
              options: [
                AppStrings.readerContinuous.tr(),
                AppStrings.readerSinglePage.tr(),
              ],
              selected: state.settings.isContinuous ? 0 : 1,
              onChanged: (i) {
                if ((i == 0) != state.settings.isContinuous) {
                  _cubit.toggleLayout();
                }
              },
            ),
            const SizedBox(height: 8),
            _ChoiceRow(
              options: [
                AppStrings.readerVertical.tr(),
                AppStrings.readerHorizontal.tr(),
              ],
              selected: state.settings.isHorizontal ? 1 : 0,
              onChanged: (i) {
                if ((i == 1) != state.settings.isHorizontal) {
                  _cubit.toggleDirection();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarksSheet() {
    _sheet(
      title: AppStrings.readerBookmarks.tr(),
      child: BlocBuilder<ReaderCubit, ReaderState>(
        builder: (context, state) {
          if (state.bookmarks.isEmpty) {
            return _SheetEmpty(text: AppStrings.readerNoBookmarks.tr());
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            itemCount: state.bookmarks.length,
            itemBuilder: (_, i) {
              final b = state.bookmarks[i];
              return _SheetTile(
                icon: Icons.bookmark_rounded,
                title: AppStrings.readerPage
                    .tr(namedArgs: {'page': '${b.page}'}),
                subtitle: DateFormat('MMM d, yyyy').format(b.createdAt),
                onTap: () {
                  Navigator.of(context).pop();
                  _pdf.jumpToPage(b.page);
                },
                onDelete: () => _cubit.removeBookmark(b),
              );
            },
          );
        },
      ),
    );
  }

  void _showHighlightsSheet() {
    _sheet(
      title: AppStrings.readerHighlights.tr(),
      child: BlocBuilder<ReaderCubit, ReaderState>(
        builder: (context, state) {
          if (state.highlights.isEmpty) {
            return _SheetEmpty(text: AppStrings.readerNoHighlights.tr());
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            itemCount: state.highlights.length,
            itemBuilder: (_, i) {
              final h = state.highlights[i];
              return _SheetTile(
                icon: Icons.border_color_rounded,
                title: h.text,
                titleMaxLines: 3,
                subtitle: AppStrings.readerPage
                    .tr(namedArgs: {'page': '${h.page}'}),
                onTap: () {
                  Navigator.of(context).pop();
                  _pdf.jumpToPage(h.page);
                },
                onDelete: () => _cubit.removeHighlightAt(i),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================
// Small Albayan-styled pieces
// ============================================

class _DownloadingView extends StatelessWidget {
  final String title;
  final double progress;

  const _DownloadingView({required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.accentPale,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeLarge,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                // Indeterminate until the server reports a size.
                value: progress > 0 ? progress : null,
                minHeight: 6,
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.readerDownloading
                  .tr(namedArgs: {'percent': '$percent'}),
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeSmall,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.accentPale,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 21, color: AppColors.primary),
      ),
    );
  }
}

class _SmallIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 22, color: AppColors.primary),
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeMedium,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int titleMaxLines;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _SheetTile({
    required this.icon,
    required this.title,
    this.titleMaxLines = 1,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.accentPale,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(
        title,
        maxLines: titleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeSmall,
                color: AppColors.textSecondary,
              ),
            ),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textLight,
              ),
              onPressed: onDelete,
            )
          : (trailing == null
              ? null
              : Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    color: AppColors.primary,
                  ),
                )),
    );
  }
}

class _SheetEmpty extends StatelessWidget {
  final String text;
  const _SheetEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: AppDimensions.fontSizeMedium,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Two-option pill switch (e.g. Continuous | Page by page).
class _ChoiceRow extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const _ChoiceRow({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Text(
                      options[i],
                      style: TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        color: i == selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
