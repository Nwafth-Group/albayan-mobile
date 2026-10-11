// ============================================
// FILE: lib/widgets/web_view_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/constants.dart';
import 'custom_app_bar.dart';
import 'empty_state_widget.dart';

/// In-app reader that renders a web page (e.g. an article's `url`).
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, this.title = ''});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onWebResourceError: (error) {
            // Only a failure of the main page should blank the reader.
            if (error.isForMainFrame == true && mounted) {
              setState(() => _failed = true);
            }
          },
        ),
      );
    _load();
  }

  void _load() {
    setState(() {
      _failed = false;
      _progress = 0;
    });
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: widget.title),
      body: SafeArea(
        child: _failed
            ? EmptyStateWidget(
                icon: Icons.wifi_off_rounded,
                message: AppStrings.somethingWentWrong.tr(),
                actionText: AppStrings.retry.tr(),
                onAction: _load,
              )
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_progress < 100)
                    LinearProgressIndicator(
                      value: _progress == 0 ? null : _progress / 100,
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceVariant,
                      minHeight: 2,
                    ),
                ],
              ),
      ),
    );
  }
}
