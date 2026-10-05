// ============================================
// FILE: lib/fatures/settings/screens/widgets/content_page.dart
// ============================================
//
// Text page layout shared by Privacy Policy and Terms & Conditions:
// headings, paragraphs and bullet lists.

import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import 'settings_widgets.dart';

sealed class ContentBlock {
  const ContentBlock();
}

class ContentHeading extends ContentBlock {
  final String text;
  const ContentHeading(this.text);
}

class ContentParagraph extends ContentBlock {
  final String text;

  /// The larger lead paragraph at the top of Privacy Policy.
  final bool lead;

  const ContentParagraph(this.text, {this.lead = false});
}

class ContentBullets extends ContentBlock {
  final List<String> items;
  const ContentBullets(this.items);
}

class ContentPage extends StatelessWidget {
  final String title;
  final List<ContentBlock> blocks;

  const ContentPage({super.key, required this.title, required this.blocks});

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(
      fontSize: 13,
      color: AppColors.textSecondary,
      height: 1.55,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(title: title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          for (final block in blocks)
            switch (block) {
              ContentHeading(:final text) => Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ContentParagraph(:final text, :final lead) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  text,
                  style: lead ? body.copyWith(fontSize: 15) : body,
                ),
              ),
              ContentBullets(:final items) => Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 8,
                        bottom: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: CircleAvatar(
                              radius: 2,
                              backgroundColor: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item, style: body)),
                        ],
                      ),
                    ),
                ],
              ),
            },
        ],
      ),
    );
  }
}
