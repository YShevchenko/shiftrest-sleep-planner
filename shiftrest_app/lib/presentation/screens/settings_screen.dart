import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/shift.dart';
import '../../services/health_service.dart';
import '../../domain/models/sleep_block.dart';
import '../../domain/models/sleep_plan.dart';
import '../../services/iap_service.dart';
import '../providers/settings_provider.dart';
import '../providers/shift_provider.dart';
import '../providers/sleep_plan_provider.dart';

/// App settings screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // Pro upgrade section
              Consumer<IapService>(
                builder: (context, iap, _) {
                  if (iap.isPro) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(context, 'SHIFTREST PRO'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Pro unlocked. Thank you for your support!',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(context, 'SHIFTREST PRO'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.sleepGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to Pro',
                              style:
                                  Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.onPrimaryContainer,
                                        fontWeight: FontWeight.w800,
                                      ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'One-time purchase — no subscription',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                            const SizedBox(height: 16),
                            if (iap.error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  iap.error!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.error),
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: iap.isPending
                                        ? null
                                        : () => iap.purchasePro(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.onPrimaryContainer,
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: iap.isPending
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            iap.product != null
                                                ? 'Upgrade — ${iap.product!.price}'
                                                : 'Upgrade to Pro — \$4.99',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: iap.isPending
                                      ? null
                                      : () => iap.restorePurchases(),
                                  child: Text(
                                    'Restore',
                                    style: TextStyle(
                                      color: AppColors.onPrimaryContainer
                                          .withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),

              // Schedule defaults section
              _sectionHeader(context, 'SCHEDULE DEFAULTS'),
              const SizedBox(height: 16),

              // Commute time
              _settingTile(
                context,
                icon: Icons.directions_car,
                title: 'Commute Time',
                subtitle: '${settings.commuteMinutes} minutes',
                onTap: () => _showCommuteDialog(context, settings),
              ),

              // Prep time
              _settingTile(
                context,
                icon: Icons.timer_outlined,
                title: 'Prep Time',
                subtitle: '${settings.prepMinutes} minutes',
                onTap: () => _showPrepDialog(context, settings),
              ),

              // Default shift type
              _settingTile(
                context,
                icon: Icons.work_outline,
                title: 'Default Shift Type',
                subtitle: settings.defaultShiftType.toUpperCase(),
                onTap: () => _showShiftTypeDialog(context, settings),
              ),

              const SizedBox(height: 32),
              _sectionHeader(context, 'DISPLAY'),
              const SizedBox(height: 16),

              // 24h format
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  title: Text(
                    '24-Hour Format',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    settings.use24HourFormat ? '14:00' : '2:00 PM',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  value: settings.use24HourFormat,
                  onChanged: (v) => settings.setUse24HourFormat(v),
                  activeTrackColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),

              // Language
              _settingTile(
                context,
                icon: Icons.language,
                title: 'Language',
                subtitle: _localeName(settings.locale),
                onTap: () => _showLocaleDialog(context, settings),
              ),

              // ── HEALTH CONNECT SECTION ───────────────────────────────
              const SizedBox(height: 32),
              _sectionHeader(context, 'HEALTH CONNECT'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  secondary: const Icon(Icons.favorite_outline,
                      color: AppColors.onSurfaceVariant),
                  title: Text(
                    'Sync to Health Connect',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    'Write sleep sessions to Google Fit, Samsung Health, etc.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  value: settings.healthSync,
                  onChanged: (v) async {
                    if (v) {
                      final granted = await HealthService.requestPermissions();
                      if (granted) {
                        await settings.setHealthSync(true);
                      }
                    } else {
                      await settings.setHealthSync(false);
                    }
                  },
                  activeTrackColor: AppColors.primary,
                ),
              ),

              // ── DATA SECTION ──────────────────────────────────────────
              const SizedBox(height: 32),
              _sectionHeader(context, 'DATA'),
              const SizedBox(height: 16),

              // Export Data
              _actionTile(
                context,
                icon: Icons.upload_outlined,
                title: 'Export Data',
                subtitle: 'Save shifts & sleep plans as JSON',
                isLoading: _isExporting,
                onTap: () => _confirmExport(context),
              ),

              const SizedBox(height: 8),

              // Import Data
              _actionTile(
                context,
                icon: Icons.download_outlined,
                title: 'Import Data',
                subtitle: 'Load shifts & sleep plans from JSON file',
                isLoading: _isImporting,
                onTap: () => _confirmImport(context),
              ),

              const SizedBox(height: 8),

              // Delete All Data
              _actionTile(
                context,
                icon: Icons.delete_forever_outlined,
                title: 'Delete All Data',
                subtitle: 'Remove all shifts and sleep plans',
                isLoading: false,
                isDestructive: true,
                onTap: () => _confirmDeleteAll(context),
              ),

              // ── ABOUT SECTION ─────────────────────────────────────────
              const SizedBox(height: 32),
              _sectionHeader(context, 'ABOUT'),
              const SizedBox(height: 16),

              _settingTile(
                context,
                icon: Icons.info_outline,
                title: 'ShiftRest',
                subtitle: 'Version 1.0.1',
                onTap: () {},
              ),

              _settingTile(
                context,
                icon: Icons.shield_outlined,
                title: 'Privacy',
                subtitle: '100% offline. No data leaves this device.',
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // Copyright
              Center(
                child: Text(
                  '(c) 2026 Heldig Lab',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.primary.withValues(alpha: 0.7),
            letterSpacing: 3.0,
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _settingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.onSurfaceVariant),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Icon(Icons.chevron_right, color: AppColors.outlineVariant),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.onSurfaceVariant;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Icon(icon, color: color),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDestructive ? AppColors.error : null,
              ),
        ),
        subtitle:
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        onTap: isLoading ? null : onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ── EXPORT ──────────────────────────────────────────────────────────

  void _confirmExport(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Export all your shifts and sleep plans as a JSON file? '
          'You can use this to back up or transfer your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _doExport(context);
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _doExport(BuildContext context) async {
    setState(() => _isExporting = true);

    // Capture context-dependent objects before async gaps
    final shiftProvider = context.read<ShiftProvider>();
    final planProvider = context.read<SleepPlanProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Load current data
      final shifts = shiftProvider.shifts;
      final plans = planProvider.plans;

      // Build JSON payload
      final payload = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'shifts': shifts.map((s) => s.toMap()).toList(),
        'sleepPlans': plans.map((p) {
          final map = p.toMap();
          map['sleepBlocks'] = p.sleepBlocks.map((b) => b.toMap()).toList();
          return map;
        }).toList(),
      };

      final json = const JsonEncoder.withIndent('  ').convert(payload);

      // Write to Documents directory
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final file = File('${dir.path}/shiftrest_export_$timestamp.json');
      await file.writeAsString(json);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ShiftRest data export',
      );

      messenger.showSnackBar(
        const SnackBar(content: Text('Data exported successfully.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ── IMPORT ──────────────────────────────────────────────────────────

  void _confirmImport(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'Pick a ShiftRest JSON export file to import. '
          'This will ADD the imported data on top of your existing data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _doImport(context);
            },
            child: const Text('Pick File'),
          ),
        ],
      ),
    );
  }

  Future<void> _doImport(BuildContext context) async {
    setState(() => _isImporting = true);

    // Capture context-dependent objects before async gaps
    final shiftProvider = context.read<ShiftProvider>();
    final planProvider = context.read<SleepPlanProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isImporting = false);
        return;
      }

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        throw Exception('Could not read file contents');
      }

      final json = utf8.decode(bytes);
      final payload = jsonDecode(json) as Map<String, dynamic>;

      // Parse shifts
      final rawShifts = (payload['shifts'] as List<dynamic>?) ?? [];
      final shifts = rawShifts
          .map((m) => Shift.fromMap(m as Map<String, dynamic>))
          .toList();

      // Parse sleep plans
      final rawPlans = (payload['sleepPlans'] as List<dynamic>?) ?? [];
      final plans = rawPlans.map((m) {
        final planMap = m as Map<String, dynamic>;
        final rawBlocks = (planMap['sleepBlocks'] as List<dynamic>?) ?? [];
        final blocks = rawBlocks
            .map((b) => SleepBlock.fromMap(b as Map<String, dynamic>))
            .toList();
        return SleepPlan.fromMap(planMap, blocks);
      }).toList();

      for (final shift in shifts) {
        await shiftProvider.addShift(shift);
      }
      for (final plan in plans) {
        await planProvider.savePlan(plan);
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${shifts.length} shift(s) and ${plans.length} sleep plan(s).',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  // ── DELETE ALL ───────────────────────────────────────────────────────

  void _confirmDeleteAll(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text('Delete all shifts and sleep data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmDeleteAllFinal(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAllFinal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are You Sure?'),
        content: const Text(
          'This cannot be undone. All shifts and sleep plans will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _doDeleteAll(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _doDeleteAll(BuildContext context) async {
    final shiftProvider = context.read<ShiftProvider>();
    final planProvider = context.read<SleepPlanProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await shiftProvider.deleteAllShifts();
      await planProvider.deleteAllPlans();

      messenger.showSnackBar(
        const SnackBar(content: Text('All data deleted.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  // ── DIALOGS ───────────────────────────────────────────────────────────

  void _showCommuteDialog(BuildContext context, SettingsProvider settings) {
    double value = settings.commuteMinutes.toDouble();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Commute Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${value.round()} minutes'),
              Slider(
                value: value,
                min: 0,
                max: 120,
                divisions: 24,
                onChanged: (v) => setState(() => value = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                settings.setCommuteMinutes(value.round());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrepDialog(BuildContext context, SettingsProvider settings) {
    double value = settings.prepMinutes.toDouble();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Prep Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${value.round()} minutes'),
              Slider(
                value: value,
                min: 0,
                max: 60,
                divisions: 12,
                onChanged: (v) => setState(() => value = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                settings.setPrepMinutes(value.round());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showShiftTypeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Default Shift Type'),
        children: ['day', 'evening', 'night'].map((type) {
          return SimpleDialogOption(
            onPressed: () {
              settings.setDefaultShiftType(type);
              Navigator.of(ctx).pop();
            },
            child: Text(type[0].toUpperCase() + type.substring(1)),
          );
        }).toList(),
      ),
    );
  }

  void _showLocaleDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Language'),
        children: [
          {'code': 'en', 'name': 'English'},
          {'code': 'de', 'name': 'Deutsch'},
          {'code': 'es', 'name': 'Espanol'},
          {'code': 'uk', 'name': 'Ukrainian'},
        ].map((locale) {
          return SimpleDialogOption(
            onPressed: () {
              settings.setLocale(locale['code']!);
              Navigator.of(ctx).pop();
            },
            child: Text(locale['name']!),
          );
        }).toList(),
      ),
    );
  }

  String _localeName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Espanol';
      case 'uk':
        return 'Ukrainian';
      default:
        return code;
    }
  }
}
