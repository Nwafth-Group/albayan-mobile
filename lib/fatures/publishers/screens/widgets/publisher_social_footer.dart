
// ============================================
// FILE: lib/fatures/publishers/screens/widgets/publisher_social_footer.dart
// ============================================

import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

/// Renders whichever social platforms are present in [socialLinks], plus the
/// publisher email underneath. Only known platforms get an icon; anything
/// else is skipped rather than guessed at.
class PublisherSocialFooter extends StatelessWidget {
  final Map<String, String> socialLinks;
  final String? email;
  final void Function(String url)? onTapLink;

  const PublisherSocialFooter({
    super.key,
    required this.socialLinks,
    required this.email,
    this.onTapLink,
  });

  static const _order = ['facebook', 'twitter', 'x', 'instagram', 'linkedin'];

  @override
  Widget build(BuildContext context) {
    final entries = _order
        .where((k) => socialLinks.containsKey(k))
        .map((k) => MapEntry(k, socialLinks[k]!))
        .toList();

    if (entries.isEmpty && (email == null || email!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (entries.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _SocialBadge(
                    platform: e.key,
                    onTap: () => onTapLink?.call(e.value),
                  ),
                ),
            ],
          ),
        if (email != null && email!.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            email!,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textLight,
            ),
          ),
        ],
      ],
    );
  }
}

class _SocialBadge extends StatelessWidget {
  final String platform;
  final VoidCallback? onTap;
  const _SocialBadge({required this.platform, this.onTap});

  @override
  Widget build(BuildContext context) {
    final spec = _spec(platform);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: spec.color,
          shape: BoxShape.circle,
        ),
        child: spec.icon != null
            ? Icon(spec.icon, size: 18, color: Colors.white)
            : Text(
                spec.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  _BadgeSpec _spec(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return _BadgeSpec(icon: Icons.facebook, color: const Color(0xFF1877F2));
      case 'twitter':
      case 'x':
        return _BadgeSpec(label: 'X', color: Colors.black);
      case 'instagram':
        return _BadgeSpec(
          icon: Icons.camera_alt_outlined,
          color: const Color(0xFFC13584),
        );
      case 'linkedin':
        return _BadgeSpec(label: 'in', color: const Color(0xFF0A66C2));
      default:
        return _BadgeSpec(icon: Icons.link, color: AppColors.primary);
    }
  }
}

class _BadgeSpec {
  final IconData? icon;
  final String label;
  final Color color;
  _BadgeSpec({this.icon, this.label = '', required this.color});
}
