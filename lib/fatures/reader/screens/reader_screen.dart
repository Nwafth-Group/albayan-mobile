// ============================================
// FILE: lib/fatures/reader/screens/reader_screen.dart
// ============================================
//
// In-app PDF reader. Open it with:
//
//   ReaderScreen.open(ReaderBook(id: ..., title: ..., pdfUrl: ...));
//
// Layout (per the design): a maroon header with the title, a search pill +
// voice-search mic, and a toolbar (zoom in/out, read aloud, stop, scroll
// direction, menu, current page); the page in the middle; a strip of page
// thumbnails at the bottom. Tapping the page hides the header and strip.
//
// Also: download + on-device cache, resume at the last page, bookmarks,
// text highlights, copy, go-to-page and continuous / page-by-page layout.

import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/datasource/reader_remote_datasource.dart';
import '../data/models/reader_models.dart';
import '../data/reader_local_storage.dart';
import '../data/reader_page_tools.dart';
import 'cubit/reader_cubit.dart';

/// Text highlight color — Albayan's terracotta accent.
const _highlightColor = AppColors.accentLight;

/// Background of the bottom thumbnails strip.
const _stripColor = Color(0xFFC9C9C9);

class ReaderScreen extends StatelessWidget {
  final ReaderBook book;

  const ReaderScreen({super.key, required this.book});

  /// Opens [book] in the reader.
  static Future<void> open(ReaderBook book) =>
      AppNavigator.push(ReaderScreen(book: book));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReaderCubit(
        ReaderLocalStorageImpl(),
        ReaderRemoteDataSourceImpl(ApiService()),
        book: book,
      )..load(),
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
  final _stripScroll = ScrollController();

  PdfTextSearchResult? _search;
  OverlayEntry? _selectionMenu;
  String? _selectedText;
  bool _showUI = true;

  ReaderPageTools? _pages;

  // Read aloud
  final _tts = FlutterTts();
  bool _speaking = false;

  // Voice search
  final _speech = stt.SpeechToText();
  bool? _speechAvailable;
  bool _listening = false;

  ReaderCubit get _cubit => context.read<ReaderCubit>();

  // Thumbnail cell geometry (also used to scroll the strip to a page).
  static const _thumbWidth = 84.0;
  static const _thumbGap = 10.0;

  @override
  void initState() {
    super.initState();
    _tts.setCompletionHandler(() => _setSpeaking(false));
    _tts.setCancelHandler(() => _setSpeaking(false));
    _tts.setErrorHandler((msg) {
      readerLog('✖ read-aloud error: $msg');
      _setSpeaking(false);
    });
  }

  @override
  void dispose() {
    _removeSelectionMenu();
    _search?.removeListener(_onSearchChanged);
    _tts.stop();
    _speech.cancel();
    _pages?.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _stripScroll.dispose();
    _pdf.dispose();
    super.dispose();
  }

  // ── Search ──────────────────────────────────────────────

  void _runSearch(String query) {
    _clearSearchResult();
    if (query.trim().isEmpty) {
      setState(() {});
      return;
    }
    readerLog('search: "$query"');
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

  void _clearSearch() {
    _clearSearchResult();
    _searchCtrl.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {});
  }

  // ── Voice search ────────────────────────────────────────

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    _speechAvailable ??= await _speech.initialize(
      onStatus: (status) {
        readerLog('voice search status: $status');
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (e) {
        readerLog('✖ voice search error: ${e.errorMsg}');
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!mounted) return;
    if (_speechAvailable != true) {
      _snack(AppStrings.readerMicUnavailable.tr());
      _speechAvailable = null; // permission may be granted later — retry
      return;
    }
    _clearSearchResult();
    _searchCtrl.clear();
    setState(() => _listening = true);
    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        localeId: context.locale.languageCode == 'ar' ? 'ar_SA' : 'en_US',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        listenMode: stt.ListenMode.search,
      ),
      onResult: (result) {
        if (!mounted) return;
        _searchCtrl.text = result.recognizedWords;
        if (result.finalResult) {
          setState(() => _listening = false);
          _runSearch(result.recognizedWords);
        }
      },
    );
  }

  // ── Read aloud ──────────────────────────────────────────

  void _setSpeaking(bool value) {
    if (mounted && _speaking != value) setState(() => _speaking = value);
  }

  /// Reads the selected text, or the whole current page.
  Future<void> _speak() async {
    final selected = _selectedText?.trim() ?? '';
    final text = selected.isNotEmpty
        ? selected
        : await (_pages?.pageText(_cubit.state.currentPage) ?? Future.value(''));
    if (!mounted) return;
    if (text.isEmpty) {
      _snack(AppStrings.readerNothingToRead.tr());
      return;
    }
    final arabic = RegExp(r'[؀-ۿ]').hasMatch(text);
    await _tts.stop();
    await _tts.setLanguage(arabic ? 'ar-SA' : 'en-US');
    await _tts.setSpeechRate(0.45);
    readerLog('read aloud: ${text.length} chars (${arabic ? 'ar' : 'en'})');
    _setSpeaking(true);
    await _tts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _tts.stop();
    _setSpeaking(false);
  }

  // ── Zoom / navigation ───────────────────────────────────

  void _zoomBy(double delta) {
    _pdf.zoomLevel = (_pdf.zoomLevel + delta).clamp(1.0, 3.0);
  }

  void _toggleBookmark() {
    final added = _cubit.toggleBookmark();
    _snack(
      added
          ? AppStrings.readerBookmarkAdded.tr()
          : AppStrings.readerBookmarkRemoved.tr(),
    );
  }

  void _snack(String message) => AppNavigator.showSnackBar(
        message,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      );

  /// Keeps the current page's thumbnail centered in the strip.
  void _scrollStripTo(int page) {
    if (!_stripScroll.hasClients) return;
    const cell = _thumbWidth + _thumbGap;
    final viewport = _stripScroll.position.viewportDimension;
    final target = (page - 1) * cell - (viewport - cell) / 2;
    _stripScroll.animateTo(
      target.clamp(0.0, _stripScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
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
    _snack(AppStrings.readerHighlightAdded.tr());
  }

  // ── Selection menu (copy / highlight / read) ────────────

  void _removeSelectionMenu() {
    _selectionMenu?.remove();
    _selectionMenu = null;
  }

  void _onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    final text = details.selectedText;
    final region = details.globalSelectedRegion;
    _selectedText = text;
    if (text == null || text.trim().isEmpty || region == null) {
      _removeSelectionMenu();
      return;
    }
    _showSelectionMenu(text, region);
  }

  void _showSelectionMenu(String text, Rect region) {
    _removeSelectionMenu();
    final screen = MediaQuery.of(context).size;
    const menuWidth = 280.0;
    const menuHeight = 48.0;

    final left = (region.center.dx - menuWidth / 2)
        .clamp(16.0, math.max(16.0, screen.width - menuWidth - 16));
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
                  _snack(AppStrings.readerCopied.tr());
                },
              ),
              Container(width: 1, height: 24, color: Colors.white24),
              _MenuAction(
                icon: Icons.border_color_rounded,
                label: AppStrings.readerHighlight.tr(),
                onTap: () => _highlightSelection(text),
              ),
              Container(width: 1, height: 24, color: Colors.white24),
              _MenuAction(
                icon: Icons.volume_up_rounded,
                label: AppStrings.readerReadAloud.tr(),
                onTap: () {
                  _removeSelectionMenu();
                  _speak();
                },
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status-bar icons over the maroon header.
      value: SystemUiOverlayStyle.light,
      child: BlocConsumer<ReaderCubit, ReaderState>(
        listenWhen: (a, b) =>
            a.highlights.length != b.highlights.length ||
            a.file?.path != b.file?.path ||
            a.currentPage != b.currentPage,
        listener: (_, state) {
          if (state.file != null && _pages?.file.path != state.file!.path) {
            _pages?.dispose();
            _pages = ReaderPageTools(state.file!);
          }
          // A removed highlight has to disappear from the page too.
          _applyHighlights(state.highlights);
          _scrollStripTo(state.currentPage);
        },
        builder: (context, state) {
          final ready = state.status == ReaderStatus.ready;
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: (_showUI || !ready)
                      ? _header(state)
                      : _statusBarSpacer(),
                ),
                Expanded(
                  child: switch (state.status) {
                    ReaderStatus.downloading => _DownloadingView(
                        title: widget.book.title,
                        progress: state.progress,
                      ),
                    ReaderStatus.failure => EmptyStateWidget(
                        icon: Icons.menu_book_outlined,
                        message: AppStrings.readerOpenFailed.tr(),
                        // Debug builds also show the raw error.
                        message2: [
                          if (state.error != null) state.error!,
                          if (kDebugMode && state.debugDetails != null)
                            state.debugDetails!,
                        ].join('\n\n'),
                        actionText: AppStrings.retry.tr(),
                        onAction: _cubit.load,
                      ),
                    ReaderStatus.ready => _readerBody(state),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusBarSpacer() => Container(
        height: MediaQuery.of(context).padding.top,
        color: AppColors.primary,
      );

  // ── Header: title, search + mic, toolbar ────────────────

  Widget _header(ReaderState state) {
    final ready = state.status == ReaderStatus.ready;
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          // Back + title
          SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => AppNavigator.pop(),
                ),
                Flexible(
                  child: Text(
                    widget.book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.book.isSample) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppStrings.readerSampleBadge.tr(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 16),
              ],
            ),
          ),
          if (ready) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  Expanded(child: _searchPill()),
                  const SizedBox(width: 10),
                  _micButton(),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _toolbar(state),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _searchPill() {
    final result = _search;
    String? counter;
    if (result != null && result.isSearchCompleted) {
      counter = result.totalInstanceCount == 0
          ? AppStrings.readerNoMatches.tr()
          : '${result.currentInstanceIndex}/${result.totalInstanceCount}';
    }
    final hasQuery = _searchCtrl.text.isNotEmpty || result != null;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              textInputAction: TextInputAction.search,
              onSubmitted: _runSearch,
              onChanged: (_) => setState(() {}),
              cursorColor: AppColors.primary,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeMedium,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: _listening
                    ? AppStrings.readerListening.tr()
                    : AppStrings.readerSearchHint.tr(),
                hintStyle: const TextStyle(color: AppColors.textLight),
              ),
            ),
          ),
          if (counter != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 2),
              child: Text(
                counter,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeSmall,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (result != null && result.hasResult) ...[
            _PillIcon(
              icon: Icons.keyboard_arrow_up_rounded,
              onTap: result.previousInstance,
            ),
            _PillIcon(
              icon: Icons.keyboard_arrow_down_rounded,
              onTap: result.nextInstance,
            ),
          ],
          if (hasQuery)
            _PillIcon(icon: Icons.close_rounded, onTap: _clearSearch)
          else
            _PillIcon(
              icon: Icons.search_rounded,
              onTap: () => _runSearch(_searchCtrl.text),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _micButton() {
    return Tooltip(
      message: AppStrings.readerVoiceSearch.tr(),
      child: GestureDetector(
        onTap: _toggleListening,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _listening ? AppColors.accent : AppColors.cardColor,
            shape: BoxShape.circle,
            boxShadow: _listening
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.6),
                      blurRadius: 14,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
            color: _listening ? Colors.white : AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _toolbar(ReaderState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ToolIcon(
            icon: Icons.zoom_in_rounded,
            tooltip: AppStrings.readerZoomIn.tr(),
            onTap: () => _zoomBy(0.25),
          ),
          _ToolIcon(
            icon: Icons.zoom_out_rounded,
            tooltip: AppStrings.readerZoomOut.tr(),
            onTap: () => _zoomBy(-0.25),
          ),
          _ToolIcon(
            icon: Icons.volume_up_outlined,
            tooltip: AppStrings.readerReadAloud.tr(),
            active: _speaking,
            onTap: _speak,
          ),
          _ToolIcon(
            icon: Icons.volume_off_outlined,
            tooltip: AppStrings.readerStopReading.tr(),
            onTap: _speaking ? _stopSpeaking : null,
          ),
          _ToolIcon(
            icon: state.settings.isHorizontal
                ? Icons.swap_horiz_rounded
                : Icons.swap_vert_rounded,
            tooltip: AppStrings.readerScrollDirection.tr(),
            onTap: _cubit.toggleDirection,
          ),
          _ToolIcon(
            icon: Icons.menu_rounded,
            tooltip: AppStrings.readerMore.tr(),
            onTap: _showMenuSheet,
          ),
          InkWell(
            onTap: state.totalPages > 1
                ? () => _showGoToPage(state.totalPages)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'P${state.currentPage}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Page + thumbnails strip ─────────────────────────────

  Widget _readerBody(ReaderState state) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: Theme(
            // Tints the viewer's own chrome (selection handles, page gutter)
            // with Albayan's palette.
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: AppColors.primary,
                surface: AppColors.background,
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
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollStripTo(_cubit.state.currentPage),
                );
              },
              onDocumentLoadFailed: (details) => _cubit.onDocumentLoadFailed(
                details.error,
                details.description,
              ),
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
        if (state.totalPages > 0)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _showUI ? 0 : -220,
            child: _thumbnailStrip(state),
          ),
      ],
    );
  }

  Widget _thumbnailStrip(ReaderState state) {
    return Container(
      color: _stripColor.withValues(alpha: 0.95),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 140,
          child: ListView.separated(
            controller: _stripScroll,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: state.totalPages,
            separatorBuilder: (_, _) => const SizedBox(width: _thumbGap),
            itemBuilder: (context, i) {
              final page = i + 1;
              return _Thumbnail(
                key: ValueKey(page),
                page: page,
                width: _thumbWidth,
                selected: page == state.currentPage,
                tools: _pages,
                onTap: () => _pdf.jumpToPage(page),
              );
            },
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
              icon: state.isCurrentPageBookmarked
                  ? Icons.bookmark_remove_outlined
                  : Icons.bookmark_add_outlined,
              title: state.isCurrentPageBookmarked
                  ? AppStrings.readerRemoveBookmark.tr()
                  : AppStrings.readerBookmarkPage.tr(),
              trailing: 'P${state.currentPage}',
              onTap: _toggleBookmark,
            ),
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

/// One page in the bottom strip; renders its image lazily.
class _Thumbnail extends StatefulWidget {
  final int page;
  final double width;
  final bool selected;
  final ReaderPageTools? tools;
  final VoidCallback onTap;

  const _Thumbnail({
    super.key,
    required this.page,
    required this.width,
    required this.selected,
    required this.tools,
    required this.onTap,
  });

  @override
  State<_Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<_Thumbnail> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _Thumbnail old) {
    super.didUpdateWidget(old);
    if (old.tools != widget.tools) _load();
  }

  Future<void> _load() async {
    final tools = widget.tools;
    if (tools == null) return;
    _bytes = tools.cachedThumbnail(widget.page);
    if (_bytes != null) return;
    final bytes = await tools.thumbnail(widget.page, width: widget.width * 2);
    if (mounted && bytes != null) setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: widget.width,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(
                  color: widget.selected ? AppColors.primary : Colors.white,
                  width: widget.selected ? 2.5 : 1,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: _bytes != null
                    ? Image.memory(
                        _bytes!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.page}',
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  widget.selected ? FontWeight.w700 : FontWeight.w400,
              color: widget.selected
                  ? AppColors.primary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// White outlined icon in the maroon toolbar.
class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool active;

  const _ToolIcon({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.white.withValues(alpha: 0.2) : null,
          ),
          child: Icon(
            icon,
            size: 25,
            color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

class _PillIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PillIcon({required this.icon, required this.onTap});

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
