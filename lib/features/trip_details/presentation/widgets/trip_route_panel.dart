import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/maps/google_maps_links.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/models/trip.dart';
import '../../../../shared/models/trip_status.dart';
import '../../../../shared/widgets/app_button.dart';

class TripRoutePanel extends StatelessWidget {
  const TripRoutePanel({super.key, required this.trip, required this.strings});

  final Trip trip;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final pickupDone = _passed(TripStatus.loaded);
    final deliveryDone = _passed(TripStatus.delivered);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _RouteStop(
            label: strings.t('trip.pickup'),
            city: trip.pickupCity,
            address: trip.pickupAddress,
            fallback: trip.pickupLabel,
            emptyLabel: strings.t('common.dash'),
            lat: trip.pickupLat,
            lng: trip.pickupLng,
            navigateLabel: strings.t('action.navigate'),
            done: pickupDone,
            focused: _focus == _StopFocus.pickup,
          ),
          _RouteStop(
            label: strings.t('trip.delivery'),
            city: trip.deliveryCity,
            address: trip.deliveryAddress,
            fallback: trip.deliveryLabel,
            emptyLabel: strings.t('common.dash'),
            lat: trip.deliveryLat,
            lng: trip.deliveryLng,
            navigateLabel: strings.t('action.navigate'),
            done: deliveryDone,
            focused: _focus == _StopFocus.delivery,
            isLast: true,
          ),
        ],
      ),
    );
  }

  bool _passed(TripStatus stage) {
    if (trip.status == TripStatus.cancelled) return false;
    return trip.status.progressIndex >= stage.progressIndex;
  }

  _StopFocus get _focus {
    return switch (trip.status) {
      TripStatus.assigned || TripStatus.arrivedAtPickup => _StopFocus.pickup,
      TripStatus.loaded ||
      TripStatus.inTransit ||
      TripStatus.arrived => _StopFocus.delivery,
      _ => _StopFocus.none,
    };
  }
}

enum _StopFocus { none, pickup, delivery }

class _RouteStop extends StatelessWidget {
  const _RouteStop({
    required this.label,
    required this.fallback,
    required this.emptyLabel,
    required this.navigateLabel,
    required this.done,
    required this.focused,
    this.city,
    this.address,
    this.lat,
    this.lng,
    this.isLast = false,
  });

  final String label;
  final String? city;
  final String? address;
  final String fallback;
  final String emptyLabel;
  final String navigateLabel;
  final double? lat;
  final double? lng;
  final bool done;
  final bool focused;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final place = _place(city, address, fallback, emptyLabel);
    final hasCoords = lat != null && lng != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _StopMark(done: done, focused: focused),
                if (!isLast)
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 2,
                        height: double.infinity,
                        child: ColoredBox(
                          color: done
                              ? AppColors.primary
                              : AppColors.primaryMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.caption),
                  const SizedBox(height: 2),
                  Text(place.headline, style: AppText.title),
                  if (place.detail != null) ...[
                    const SizedBox(height: 4),
                    Text(place.detail!, style: AppText.bodyMuted),
                  ],
                  if (hasCoords) ...[
                    const SizedBox(height: 12),
                    AppButton(
                      label: navigateLabel,
                      icon: Icons.navigation_rounded,
                      tone: focused
                          ? AppButtonTone.primary
                          : AppButtonTone.ghost,
                      onPressed: () => GoogleMapsLinks.open(
                        lat: lat!,
                        lng: lng!,
                        navigate: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Place {
  const _Place(this.headline, this.detail);

  final String headline;
  final String? detail;
}

_Place _place(
  String? city,
  String? address,
  String fallback,
  String emptyLabel,
) {
  final cityText = city?.trim() ?? '';
  final addressText = address?.trim() ?? '';

  if (cityText.isNotEmpty &&
      addressText.isNotEmpty &&
      addressText != cityText) {
    return _Place(cityText, addressText);
  }
  if (cityText.isNotEmpty) return _Place(cityText, null);
  if (addressText.isNotEmpty) return _Place(addressText, null);
  if (fallback.trim().isNotEmpty) return _Place(fallback.trim(), null);
  return _Place(emptyLabel, null);
}

class _StopMark extends StatelessWidget {
  const _StopMark({required this.done, required this.focused});

  final bool done;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    if (focused) {
      return Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    if (done) {
      return Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.only(top: 3),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 11,
          color: AppColors.white,
        ),
      );
    }

    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: 2),
      ),
    );
  }
}
