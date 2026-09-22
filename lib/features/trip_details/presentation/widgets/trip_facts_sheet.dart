import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/date_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/models/shipment.dart';
import '../../../../shared/models/trip.dart';
import '../../../../shared/models/truck.dart';

class TripFactsSheet extends StatelessWidget {
  const TripFactsSheet({super.key, required this.trip, required this.strings});

  final Trip trip;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final shipment = trip.job?.shipment;
    final cargoLines = _cargoLines(shipment);
    final notes = shipment?.notes?.trim();
    final facts = _facts(context);
    final hasCargo =
        cargoLines.isNotEmpty || (notes != null && notes.isNotEmpty);

    if (!hasCargo && facts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCargo)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('trip.cargo'), style: AppText.caption),
                  if (cargoLines.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(cargoLines.first, style: AppText.title),
                    for (final line in cargoLines.skip(1)) ...[
                      const SizedBox(height: 4),
                      Text(line, style: AppText.body),
                    ],
                  ],
                  if (notes != null && notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Text(notes, style: AppText.bodyMuted),
                    ),
                  ],
                ],
              ),
            ),
          if (hasCargo && facts.isNotEmpty)
            const Divider(height: 1, thickness: 1, color: AppColors.line),
          for (var i = 0; i < facts.length; i++) ...[
            _FactRow(label: facts[i].label, value: facts[i].value),
            if (i < facts.length - 1)
              const Divider(height: 1, thickness: 1, color: AppColors.line),
          ],
        ],
      ),
    );
  }

  List<String> _cargoLines(Shipment? shipment) {
    if (shipment == null) return const [];
    return [shipment.cargoType, shipment.cargoDescription]
        .whereType<String>()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<_Fact> _facts(BuildContext context) {
    final facts = <_Fact>[];
    final date = formatTripDate(
      trip.tripDateRaw,
      Localizations.localeOf(context).languageCode,
    );
    if (date != null) {
      facts.add(_Fact(strings.t('trip.date'), date));
    }

    facts.add(_Fact(strings.t('trip.planned'), _qty(trip.plannedQuantity)));
    if (trip.deliveredQuantity != null) {
      facts.add(
        _Fact(strings.t('trip.delivered_qty'), _qty(trip.deliveredQuantity)),
      );
    }

    final truck = trip.truck;
    final plate = truck?.plateNumber?.trim();
    if (plate != null && plate.isNotEmpty) {
      facts.add(_Fact(strings.t('trip.plate'), plate));
    }
    final vehicle = truck == null ? null : _vehicleLine(truck);
    if (vehicle != null) {
      facts.add(_Fact(strings.t('trip.truck'), vehicle));
    }

    final organization = trip.job?.customer;
    if (organization != null) {
      final customerName = organization
          .displayName(Localizations.localeOf(context).languageCode)
          .trim();
      if (customerName.isNotEmpty) {
        facts.add(_Fact(strings.t('trip.customer'), customerName));
      }
    }

    return facts;
  }

  String? _vehicleLine(Truck truck) {
    final name = [truck.make, truck.model]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
    final type = truck.type?.trim() ?? '';
    if (name.isEmpty && type.isEmpty) return null;
    if (name.isEmpty) return type;
    if (type.isEmpty) return name;
    return '$name ($type)';
  }

  String _qty(double? value) {
    if (value == null) return strings.t('common.dash');
    final unit = trip.job?.shipment?.quantityUnit?.trim();
    final amount = value.toStringAsFixed(
      value.truncateToDouble() == value ? 0 : 2,
    );
    if (unit == null || unit.isEmpty) return amount;
    return '$amount $unit';
  }
}

class _Fact {
  const _Fact(this.label, this.value);

  final String label;
  final String value;
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: AppText.bodyMuted)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppText.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
