import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().load();
  }

  Future<void> _toggleBiometric(AppSettings settings, bool value) async {
    if (!value && settings.isBiometricEnabled) {
      final authBloc = context.read<AuthBloc>();
      authBloc.add(const AuthenticateRequested());
      await authBloc.stream.firstWhere((s) => s is AuthSuccess || s is AuthFailure);
      if (!mounted) return;
      if (authBloc.state is! AuthSuccess) return;
    }
    await context.read<SettingsCubit>().update(settings.copyWith(isBiometricEnabled: value));
  }

  Future<void> _toggleReminder(AppSettings settings, bool value) async {
    await context.read<SettingsCubit>().update(settings.copyWith(isReminderEnabled: value));
    final notificationService = sl<NotificationService>();
    if (value) {
      await notificationService.scheduleDailyReminder();
    } else {
      await notificationService.cancelAll();
    }
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result != null && result.files.single.path != null) {
      final content = await File(result.files.single.path!).readAsString();
      if (mounted) {
        await context.read<SettingsCubit>().importJson(content);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.status == SettingsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = state.settings;

          return ListView(
            children: [
              SwitchListTile(
                title: Text(AppStrings.biometricLock, style: AppTextStyles.bodyLarge),
                subtitle: Text(AppStrings.biometricLockSubtitle, style: AppTextStyles.bodySmall),
                value: settings.isBiometricEnabled,
                onChanged: (v) => _toggleBiometric(settings, v),
              ),
              SwitchListTile(
                title: Text(AppStrings.reminderNotification, style: AppTextStyles.bodyLarge),
                subtitle: Text(AppStrings.reminderNotificationSubtitle, style: AppTextStyles.bodySmall),
                value: settings.isReminderEnabled,
                onChanged: (v) => _toggleReminder(settings, v),
              ),
              ListTile(
                title: Text(AppStrings.baseCurrency, style: AppTextStyles.bodyLarge),
                trailing: DropdownButton<String>(
                  value: settings.baseCurrency,
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      context.read<SettingsCubit>().update(settings.copyWith(baseCurrency: v));
                    }
                  },
                ),
              ),
              ListTile(
                title: Text(AppStrings.startingBalance, style: AppTextStyles.bodyLarge),
                subtitle: Text(settings.startingBalance?.toString() ?? '—', style: AppTextStyles.bodySmall),
                onTap: () => _showNumberDialog(
                  title: AppStrings.startingBalance,
                  initial: settings.startingBalance,
                  onSave: (v) => context.read<SettingsCubit>().update(settings.copyWith(startingBalance: v)),
                ),
              ),
              ListTile(
                title: Text(AppStrings.defaultRiskPercent, style: AppTextStyles.bodyLarge),
                subtitle: Text('${settings.defaultRiskPercent ?? 1.0}%', style: AppTextStyles.bodySmall),
                onTap: () => _showNumberDialog(
                  title: AppStrings.defaultRiskPercent,
                  initial: settings.defaultRiskPercent,
                  onSave: (v) => context.read<SettingsCubit>().update(settings.copyWith(defaultRiskPercent: v)),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(AppStrings.manageStrategies, style: AppTextStyles.bodyLarge),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/strategies'),
              ),
              ListTile(
                title: Text(AppStrings.exportJson, style: AppTextStyles.bodyLarge),
                onTap: () => context.read<SettingsCubit>().exportJson(),
              ),
              ListTile(
                title: Text(AppStrings.exportCsv, style: AppTextStyles.bodyLarge),
                onTap: () => context.read<SettingsCubit>().exportCsv(),
              ),
              ListTile(
                title: Text(AppStrings.importData, style: AppTextStyles.bodyLarge),
                onTap: _importData,
              ),
              ListTile(
                title: Text(AppStrings.clearAllData, style: AppTextStyles.bodyLarge.copyWith(color: Colors.red)),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(AppStrings.clearAllData),
                      content: const Text(AppStrings.clearAllDataConfirm),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.cancel)),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.confirm)),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<SettingsCubit>().clearAll();
                  }
                },
              ),
              const Divider(),
              ListTile(
                title: Text(AppStrings.about, style: AppTextStyles.bodyLarge),
                subtitle: Text('${AppStrings.version} 1.0.0', style: AppTextStyles.bodySmall),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showNumberDialog({
    required String title,
    required double? initial,
    required ValueChanged<double?> onSave,
  }) async {
    final controller = TextEditingController(text: initial?.toString() ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.save)),
        ],
      ),
    );
    if (saved == true) {
      onSave(double.tryParse(controller.text));
    }
  }
}
