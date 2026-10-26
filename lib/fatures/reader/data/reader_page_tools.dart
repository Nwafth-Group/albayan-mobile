// ============================================
// FILE: lib/fatures/reader/data/reader_page_tools.dart
// ============================================
//
// Per-page helpers for an open PDF: small page images for the thumbnail
// strip (pdfx) and plain page text for read-aloud (syncfusion_flutter_pdf).

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import 'reader_local_storage.dart';

class ReaderPageTools {
  final File file;

  ReaderPageTools(this.file);

  pdfx.PdfDocument? _renderDoc;
  sf.PdfDocument? _textDoc;
  bool _disposed = false;

  final Map<int, Uint8List> _thumbs = {};
  final Map<int, Future<Uint8List?>> _pending = {};

  /// Renders run one at a time — pdfx can't render pages of one document
  /// in parallel.
  Future<void> _queue = Future.value();

  Uint8List? cachedThumbnail(int page) => _thumbs[page];

  /// A small JPEG of [page] (1-based), or null if it can't be rendered.
  Future<Uint8List?> thumbnail(int page, {double width = 140}) {
    final cached = _thumbs[page];
    if (cached != null) return Future.value(cached);
    return _pending[page] ??= _enqueue(
      () => _render(page, width).timeout(
        _renderTimeout,
        onTimeout: () {
          readerLog('✖ thumbnail $page timed out');
          return null;
        },
      ),
    ).whenComplete(() => _pending.remove(page));
  }

  /// A single stuck render must not block every thumbnail queued after it.
  static const _renderTimeout = Duration(seconds: 15);

  Future<T> _enqueue<T>(Future<T> Function() task) {
    final result = _queue.then((_) => task());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<Uint8List?> _render(int page, double width) async {
    if (_disposed) return null;
    try {
      final doc = _renderDoc ??= await pdfx.PdfDocument.openFile(file.path);
      if (page < 1 || page > doc.pagesCount) return null;
      final p = await doc.getPage(page);
      try {
        final scale = width / p.width;
        final image = await p.render(
          width: p.width * scale,
          height: p.height * scale,
          format: pdfx.PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
          quality: 70,
        );
        final bytes = image?.bytes;
        if (bytes != null && !_disposed) _thumbs[page] = bytes;
        return bytes;
      } finally {
        await p.close();
      }
    } catch (e, st) {
      readerLog('✖ thumbnail $page failed', error: e, stackTrace: st);
      return null;
    }
  }

  /// The text on [page] (1-based), for read-aloud. Empty for scanned pages
  /// that are images only.
  Future<String> pageText(int page) async {
    try {
      final doc = _textDoc ??= sf.PdfDocument(
        inputBytes: await file.readAsBytes(),
      );
      if (page < 1 || page > doc.pages.count) return '';
      final text = sf.PdfTextExtractor(doc).extractText(
        startPageIndex: page - 1,
        endPageIndex: page - 1,
      );
      return text.replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (e, st) {
      readerLog('✖ text extraction on page $page failed',
          error: e, stackTrace: st);
      return '';
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _thumbs.clear();
    _textDoc?.dispose();
    _textDoc = null;
    final doc = _renderDoc;
    _renderDoc = null;
    // Close after any render still in the queue.
    await _queue;
    await doc?.close();
  }
}
