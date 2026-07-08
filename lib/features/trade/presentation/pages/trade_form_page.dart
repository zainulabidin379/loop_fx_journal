import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../trade/domain/entities/trade.dart';
import '../bloc/trade_form_bloc.dart';

class TradeFormPage extends StatefulWidget {
  const TradeFormPage({super.key, this.tradeId});

  final String? tradeId;

  @override
  State<TradeFormPage> createState() => _TradeFormPageState();
}

class _TradeFormPageState extends State<TradeFormPage> {
  final _entryController = TextEditingController();
  final _exitController = TextEditingController();
  final _slController = TextEditingController();
  final _tpController = TextEditingController();
  final _lotController = TextEditingController();
  final _notesController = TextEditingController();
  final _customInstrumentController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TradeFormBloc>().add(TradeFormInit(tradeId: widget.tradeId));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _exitController.dispose();
    _slController.dispose();
    _tpController.dispose();
    _lotController.dispose();
    _notesController.dispose();
    _customInstrumentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _syncControllers(TradeFormState state) {
    if (_entryController.text != state.entryPrice) _entryController.text = state.entryPrice;
    if (_exitController.text != state.exitPrice) _exitController.text = state.exitPrice;
    if (_slController.text != state.stopLoss) _slController.text = state.stopLoss;
    if (_tpController.text != state.takeProfit) _tpController.text = state.takeProfit;
    if (_lotController.text != state.lotSize) _lotController.text = state.lotSize;
    if (_notesController.text != state.notes) _notesController.text = state.notes;
  }

  Future<void> _pickScreenshot(TradeFormState state) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      context.read<TradeFormBloc>().add(
            TradeFormFieldChanged(
              screenshotPaths: [...state.screenshotPaths, image.path],
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tradeId == null ? AppStrings.addTrade : AppStrings.editTrade),
      ),
      body: BlocConsumer<TradeFormBloc, TradeFormState>(
        listener: (context, state) {
          if (state.status == TradeFormStatus.saved) {
            context.pop();
          }
        },
        builder: (context, state) {
          if (state.status == TradeFormStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          _syncControllers(state);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.instrument, style: AppTextStyles.labelMedium),
                const SizedBox(height: AppDimens.spacingSm),
                Wrap(
                  spacing: AppDimens.spacingSm,
                  children: TradeInstrument.values.map((instrument) {
                    return ChoiceChip(
                      label: Text(instrument.label),
                      selected: state.instrument == instrument,
                      onSelected: (_) => context.read<TradeFormBloc>().add(
                            TradeFormFieldChanged(instrument: instrument),
                          ),
                    );
                  }).toList(),
                ),
                if (state.instrument == TradeInstrument.custom) ...[
                  const SizedBox(height: AppDimens.spacingMd),
                  AppTextField(
                    label: AppStrings.customInstrument,
                    controller: _customInstrumentController,
                    onChanged: (v) => context.read<TradeFormBloc>().add(
                          TradeFormFieldChanged(customInstrument: v),
                        ),
                  ),
                ],
                const SizedBox(height: AppDimens.spacingLg),
                Text(AppStrings.direction, style: AppTextStyles.labelMedium),
                const SizedBox(height: AppDimens.spacingSm),
                SegmentedButton<TradeDirection>(
                  segments: const [
                    ButtonSegment(value: TradeDirection.long, label: Text(AppStrings.long)),
                    ButtonSegment(value: TradeDirection.short, label: Text(AppStrings.short)),
                  ],
                  selected: {state.direction},
                  onSelectionChanged: (v) => context.read<TradeFormBloc>().add(
                        TradeFormFieldChanged(direction: v.first),
                      ),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                AppTextField(
                  label: AppStrings.entryPrice,
                  controller: _entryController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => context.read<TradeFormBloc>().add(TradeFormFieldChanged(entryPrice: v)),
                ),
                const SizedBox(height: AppDimens.spacingMd),
                AppTextField(
                  label: AppStrings.stopLoss,
                  controller: _slController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => context.read<TradeFormBloc>().add(TradeFormFieldChanged(stopLoss: v)),
                ),
                const SizedBox(height: AppDimens.spacingMd),
                AppTextField(
                  label: AppStrings.takeProfit,
                  controller: _tpController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => context.read<TradeFormBloc>().add(TradeFormFieldChanged(takeProfit: v)),
                ),
                const SizedBox(height: AppDimens.spacingMd),
                AppTextField(
                  label: AppStrings.lotSize,
                  controller: _lotController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => context.read<TradeFormBloc>().add(TradeFormFieldChanged(lotSize: v)),
                ),
                if (state.plannedRR != null) ...[
                  const SizedBox(height: AppDimens.spacingSm),
                  Text('${AppStrings.plannedRR}: ${CurrencyFormatter.formatRatio(state.plannedRR)}',
                      style: AppTextStyles.bodySmall),
                ],
                if (state.suggestedLot != null) ...[
                  const SizedBox(height: AppDimens.spacingSm),
                  Text(
                    '${AppStrings.suggestedLotSize}: ${state.suggestedLot!.toStringAsFixed(2)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                const SizedBox(height: AppDimens.spacingLg),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.entryDate, style: AppTextStyles.labelMedium),
                  subtitle: Text(
                    state.entryDateTime != null
                        ? DateFormatter.formatDateTime(state.entryDateTime!)
                        : '—',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: state.entryDateTime ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (date != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(state.entryDateTime ?? DateTime.now()),
                      );
                      if (time != null && context.mounted) {
                        context.read<TradeFormBloc>().add(
                              TradeFormFieldChanged(
                                entryDateTime: DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                ),
                              ),
                            );
                      }
                    }
                  },
                ),
                const SizedBox(height: AppDimens.spacingMd),
                DropdownButtonFormField<String?>(
                  initialValue: state.strategyId,
                  decoration: const InputDecoration(labelText: AppStrings.strategy),
                  items: [
                    const DropdownMenuItem(value: null, child: Text(AppStrings.noStrategy)),
                    ...state.strategies.map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ),
                  ],
                  onChanged: (v) => context.read<TradeFormBloc>().add(TradeFormFieldChanged(strategyId: v)),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.closeTrade, style: AppTextStyles.bodyMedium),
                  value: state.isClosed,
                  onChanged: (v) => context.read<TradeFormBloc>().add(TradeFormFieldChanged(isClosed: v)),
                ),
                if (state.isClosed) ...[
                  AppTextField(
                    label: AppStrings.exitPrice,
                    controller: _exitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => context.read<TradeFormBloc>().add(TradeFormFieldChanged(exitPrice: v)),
                  ),
                ],
                const SizedBox(height: AppDimens.spacingLg),
                AppTextField(
                  label: AppStrings.notes,
                  controller: _notesController,
                  maxLines: 4,
                  onChanged: (v) => context.read<TradeFormBloc>().add(TradeFormFieldChanged(notes: v)),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                Text(AppStrings.emotionBefore, style: AppTextStyles.labelMedium),
                const SizedBox(height: AppDimens.spacingSm),
                Wrap(
                  spacing: AppDimens.spacingSm,
                  children: EmotionBefore.values.map((e) {
                    return ChoiceChip(
                      label: Text(e.label),
                      selected: state.emotionBefore == e,
                      onSelected: (_) => context.read<TradeFormBloc>().add(
                            TradeFormFieldChanged(emotionBefore: e),
                          ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                Text(AppStrings.emotionAfter, style: AppTextStyles.labelMedium),
                const SizedBox(height: AppDimens.spacingSm),
                Wrap(
                  spacing: AppDimens.spacingSm,
                  children: EmotionAfter.values.map((e) {
                    return ChoiceChip(
                      label: Text(e.label),
                      selected: state.emotionAfter == e,
                      onSelected: (_) => context.read<TradeFormBloc>().add(
                            TradeFormFieldChanged(emotionAfter: e),
                          ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                Text(AppStrings.tags, style: AppTextStyles.labelMedium),
                const SizedBox(height: AppDimens.spacingSm),
                Wrap(
                  spacing: AppDimens.spacingSm,
                  children: [
                    ...state.tags.map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () {
                            final tags = [...state.tags]..remove(tag);
                            context.read<TradeFormBloc>().add(TradeFormFieldChanged(tags: tags));
                          },
                        )),
                    ActionChip(
                      label: const Text(AppStrings.addTag),
                      onPressed: () async {
                        final tag = await showDialog<String>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text(AppStrings.addTag),
                              content: TextField(controller: _tagController),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, _tagController.text),
                                  child: const Text(AppStrings.save),
                                ),
                              ],
                            );
                          },
                        );
                        if (tag != null && tag.isNotEmpty) {
                          if (!context.mounted) return;
                          context.read<TradeFormBloc>().add(
                                TradeFormFieldChanged(tags: [...state.tags, tag]),
                              );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spacingLg),
                OutlinedButton.icon(
                  onPressed: () => _pickScreenshot(state),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text(AppStrings.addScreenshot),
                ),
                if (state.screenshotPaths.isNotEmpty)
                  Text('${state.screenshotPaths.length} screenshot(s) attached',
                      style: AppTextStyles.bodySmall),
                const SizedBox(height: AppDimens.spacingXl),
                AppButton(
                  label: state.isClosed ? AppStrings.saveTrade : AppStrings.saveAsOpen,
                  isLoading: state.status == TradeFormStatus.saving,
                  onPressed: () => context.read<TradeFormBloc>().add(const TradeFormSaveRequested()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
