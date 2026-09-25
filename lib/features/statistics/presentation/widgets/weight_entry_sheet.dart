import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/forms/yam_number_field.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class WeightEntryChange {
  const WeightEntryChange.save(this.day, this.kg) : delete = false;
  const WeightEntryChange.delete() : day = null, kg = null, delete = true;

  final DateTime? day;
  final double? kg;
  final bool delete;
}

Future<WeightEntryChange?> showWeightEntrySheet({
  required BuildContext context,
  required DateTime today,
  WeightRecord? record,
}) => showModalBottomSheet<WeightEntryChange>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  constraints: const BoxConstraints(maxWidth: 480),
  builder: (context) => _WeightEntrySheet(today: today, record: record),
);

class _WeightEntrySheet extends StatefulWidget {
  const _WeightEntrySheet({required this.today, required this.record});

  final DateTime today;
  final WeightRecord? record;

  @override
  State<_WeightEntrySheet> createState() => _WeightEntrySheetState();
}

class _WeightEntrySheetState extends State<_WeightEntrySheet> {
  late final TextEditingController _weight;
  late DateTime _day;
  bool _attempted = false;
  bool _localized = false;

  @override
  void initState() {
    super.initState();
    _day = widget.record?.day ?? widget.today;
    _weight = TextEditingController(
      text:
          widget.record?.kg.toString().replaceFirst(RegExp(r'\.0$'), '') ?? '',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localized) return;
    _localized = true;
    final separator = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    ).symbols.DECIMAL_SEP;
    if (separator != '.') {
      _weight.text = _weight.text.replaceAll('.', separator);
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  Future<void> _chooseDay() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(1900),
      lastDate: widget.today,
    );
    if (day != null && mounted) setState(() => _day = day);
  }

  void _save() {
    final kg = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    setState(() => _attempted = true);
    if (kg == null || !kg.isFinite || kg <= 0) return;
    Navigator.of(context).pop(WeightEntryChange.save(_day, kg));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final kg = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.record == null
                          ? l10n.statsAddWeight
                          : l10n.statsEditWeight,
                      style: AppTypography.sectionTitle.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  if (widget.record != null)
                    YamIconButton(
                      icon: Icons.delete_outline_rounded,
                      tooltip: l10n.statsDeleteWeight,
                      destructive: true,
                      visualSize: 32,
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(const WeightEntryChange.delete()),
                    ),
                  YamIconButton(
                    icon: Icons.close_rounded,
                      tooltip: l10n.statsWeightClose,
                    surface: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              YamNumberField(
                fieldKey: const ValueKey('statistics-weight-value'),
                label: l10n.statsWeight,
                unit: l10n.unitKilograms,
                decimal: true,
                controller: _weight,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.done,
                errorText: _attempted && (kg == null || !kg.isFinite || kg <= 0)
                    ? l10n.statsInvalidWeight
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.statsWeightDate,
                style: AppTypography.label.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              YamSecondaryButton(
                label: DateFormat.yMMMd(locale).format(_day),
                icon: Icons.calendar_month_rounded,
                onPressed: _chooseDay,
              ),
              const SizedBox(height: AppSpacing.lg),
              YamPrimaryButton(
                key: const ValueKey('statistics-weight-save'),
                label: l10n.statsSaveWeight,
                expanded: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
