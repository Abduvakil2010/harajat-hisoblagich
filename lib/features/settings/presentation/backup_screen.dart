import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/localization/l10n.dart';
import '../../../data/repositories/backup_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../recurring_payments/application/recurring_service.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  String get _fileName =>
      'HisobAI_Backup_${DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now())}.json';

  Future<void> _guard(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        showSnack(context, context.l10n.operationFailed, error: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List> _exportBytes() async {
    final json = await ref
        .read(backupRepositoryProvider)
        .exportString(ref.read(settingsProvider));
    return Uint8List.fromList(utf8.encode(json));
  }

  Future<void> _saveFile() => _guard(() async {
    final bytes = await _exportBytes();
    final uri = await FilePicker.saveFile(
      fileName: _fileName,
      bytes: bytes,
      mimeType: 'application/json',
    );
    if (uri != null && mounted) showSnack(context, context.l10n.backupSaved);
  });

  Future<void> _shareFile() => _guard(() async {
    final bytes = await _exportBytes();
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/$_fileName');
    await f.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(f.path, mimeType: 'application/json')]),
    );
  });

  Future<void> _restoreFrom(String raw) async {
    final l = context.l10n;
    final repo = ref.read(backupRepositoryProvider);
    BackupSnapshot snap;
    try {
      snap = repo.parse(raw);
    } on InvalidBackupException {
      if (mounted) showSnack(context, l.invalidBackup, error: true);
      return;
    }
    if (!mounted) return;
    final when = snap.exportedAt == null
        ? '—'
        : context.dates.dayTime(snap.exportedAt!.toLocal());
    final ok = await confirmAction(
      context,
      title: l.restoreBackupTitle,
      message: l.restoreBackupBody(
        when,
        snap.count('transactions'),
        snap.count('savingsGoals'),
        snap.count('debts'),
      ),
      confirmLabel: l.restore,
      destructive: true,
    );
    if (!ok) return;
    await repo.restore(snap);
    final s = snap.settings;
    if (s != null) {
      await ref
          .read(settingsProvider.notifier)
          .update(
            (_) => s.copyWith(
              onboardingDone: true,
              cloudBackupConsent: ref.read(settingsProvider).cloudBackupConsent,
            ),
          );
    }
    await ref.read(recurringServiceProvider).run();
    if (mounted) showSnack(context, l.restoreDone);
  }

  Future<void> _importFile() => _guard(() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return;
    final bytes = await files.first.readAsBytes();
    String raw;
    try {
      raw = utf8.decode(bytes);
    } on FormatException {
      if (mounted) showSnack(context, context.l10n.invalidBackup, error: true);
      return;
    }
    await _restoreFrom(raw);
  });

  Future<void> _cloudBackup() => _guard(() async {
    final cloud = ref.read(cloudBackupServiceProvider);
    final json = await ref
        .read(backupRepositoryProvider)
        .exportString(ref.read(settingsProvider));
    await cloud.upload(json);
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(lastCloudBackupAt: () => DateTime.now()));
    if (mounted) showSnack(context, context.l10n.cloudBackupDone);
  });

  Future<void> _cloudRestore() => _guard(() async {
    final raw = await ref.read(cloudBackupServiceProvider).download();
    if (!mounted) return;
    if (raw == null) {
      showSnack(context, context.l10n.noCloudBackup, error: true);
      return;
    }
    await _restoreFrom(raw);
  });

  Future<void> _cloudDelete() async {
    final l = context.l10n;
    final ok = await confirmAction(
      context,
      title: l.deleteCloudTitle,
      message: l.deleteCloudBody,
      destructive: true,
    );
    if (!ok) return;
    await _guard(() async {
      await ref.read(cloudBackupServiceProvider).deleteRemote();
      await ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(lastCloudBackupAt: () => null));
      if (mounted) showSnack(context, l.cloudDeleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = ref.watch(settingsProvider);
    final cloud = ref.watch(cloudBackupServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.backupAndSync)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Insets.lg,
            Insets.sm,
            Insets.lg,
            Insets.xxxl,
          ),
          children: [
            if (_busy) const LinearProgressIndicator(),
            AppCard(
              color: context.palette.surface2,
              borderless: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.phone_android_rounded,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: Insets.md),
                  Expanded(
                    child: Text(l.localDataNote, style: context.text.bodySmall),
                  ),
                ],
              ),
            ),
            SectionHeader(l.fileBackup),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.fileBackupBody, style: context.text.bodyMedium),
                  const SizedBox(height: Insets.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saveFile,
                          icon: const Icon(Icons.download_rounded),
                          label: Text(l.exportData),
                        ),
                      ),
                      const SizedBox(width: Insets.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareFile,
                          icon: const Icon(Icons.ios_share_rounded),
                          label: Text(l.share),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Insets.md),
                  FilledButton.icon(
                    onPressed: _importFile,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(l.importData),
                  ),
                  const SizedBox(height: Insets.sm),
                  Text(
                    l.backupUnencryptedNote,
                    style: context.text.bodySmall?.copyWith(
                      color: context.palette.warning,
                    ),
                  ),
                ],
              ),
            ),
            SectionHeader(l.cloudBackup),
            if (!cloud.isAvailable)
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      color: context.palette.textSecondary,
                    ),
                    const SizedBox(width: Insets.md),
                    Expanded(
                      child: Text(
                        l.cloudNotConfigured,
                        style: context.text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            else
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.cloudExplain, style: context.text.bodyMedium),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.cloudConsent),
                      value: settings.cloudBackupConsent,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .update((s) => s.copyWith(cloudBackupConsent: v)),
                    ),
                    if (settings.lastCloudBackupAt != null)
                      Text(
                        l.lastBackup(
                          context.dates.dayTime(settings.lastCloudBackupAt!),
                        ),
                        style: context.text.bodySmall,
                      ),
                    const SizedBox(height: Insets.md),
                    FilledButton.icon(
                      onPressed: settings.cloudBackupConsent
                          ? _cloudBackup
                          : null,
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: Text(l.backupNow),
                    ),
                    const SizedBox(height: Insets.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: settings.cloudBackupConsent
                                ? _cloudRestore
                                : null,
                            child: Text(l.restore),
                          ),
                        ),
                        const SizedBox(width: Insets.md),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: settings.cloudBackupConsent
                                ? _cloudDelete
                                : null,
                            child: Text(l.deleteCloudCopy),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
