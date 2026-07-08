import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/services/data_export_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/settings_usecases.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required this._getSettings, required this._updateSettings, required this._exportService, required this._clearAllData})
    : super(const SettingsState());

  final GetSettings _getSettings;
  final UpdateSettings _updateSettings;
  final DataExportService _exportService;
  final ClearAllData _clearAllData;

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final settings = await _getSettings(const NoParams());
    emit(state.copyWith(status: SettingsStatus.loaded, settings: settings));
  }

  Future<void> update(AppSettings settings) async {
    await _updateSettings(settings);
    emit(state.copyWith(settings: settings));
  }

  Future<void> exportJson() => _exportService.exportJson();
  Future<void> exportCsv() => _exportService.exportCsv();

  Future<void> importJson(String content) async {
    await _exportService.importJson(content);
    await load();
  }

  Future<void> clearAll() async {
    await _clearAllData();
    await load();
  }
}
