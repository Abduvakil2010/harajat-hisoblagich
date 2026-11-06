import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/widgets/app_card.dart';

final _packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final info = ref.watch(_packageInfoProvider).value;
    final version = info == null
        ? '—'
        : '${info.version} (${info.buildNumber})';

    Widget block(IconData icon, String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: Insets.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: context.colors.primary, size: 20),
                const SizedBox(width: Insets.sm),
                Expanded(child: Text(title, style: context.text.titleSmall)),
              ],
            ),
            const SizedBox(height: Insets.sm),
            Text(
              body,
              style: context.text.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.privacyAndAbout)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.lg,
          Insets.sm,
          Insets.lg,
          Insets.xxxl,
        ),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [context.colors.primary, context.palette.accent],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: Insets.md),
                Text('HisobAI', style: context.text.headlineSmall),
                Text('${l.version} $version', style: context.text.bodySmall),
                const SizedBox(height: Insets.sm),
                Text(
                  l.aboutTagline,
                  style: context.text.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.xl),
          block(
            Icons.phone_android_rounded,
            l.privacyLocalTitle,
            l.privacyLocalBody,
          ),
          block(
            Icons.no_accounts_rounded,
            l.privacyNoAccountTitle,
            l.privacyNoAccountBody,
          ),
          block(Icons.cloud_rounded, l.privacyCloudTitle, l.privacyCloudBody),
          block(
            Icons.lock_outline_rounded,
            l.privacySecurityTitle,
            l.privacySecurityBody,
          ),
          block(Icons.auto_awesome, l.privacyAiTitle, l.privacyAiBody),
          block(Icons.gavel_rounded, l.disclaimerTitle, l.disclaimerBody),
          const SizedBox(height: Insets.md),
          Center(
            child: TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'HisobAI',
                applicationVersion: version,
              ),
              child: Text(l.openSourceLicenses),
            ),
          ),
        ],
      ),
    );
  }
}
