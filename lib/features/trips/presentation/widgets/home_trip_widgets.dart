import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/date_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/models/trip.dart';
import '../../../../shared/models/trip_status.dart';
import '../../../../shared/widgets/pressable_scale.dart';
import '../../../../shared/widgets/status_badge.dart';

class HomeHeroTrip extends StatelessWidget {
  const HomeHeroTrip({
    super.key,
    required this.trip,
    required this.strings,
    required this.onTap,
  });

  final Trip trip;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = TripStatus.visibleFlow.length;
    final progress =
        ((trip.status.progressIndex + 1) / total).clamp(0.12, 1.0);
    final date = _tripDate(context, trip);

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _LivePulse(),
                const SizedBox(width: 6),
                Text(
                  strings.t('home.live'),
                  style: AppText.caption.copyWith(color: AppColors.primaryDark),
                ),
                const Spacer(),
                StatusBadge(
                  status: trip.status,
                  label: strings.t(trip.status.labelKey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(trip.reference, style: AppText.heading),
            if (date != null) ...[
              const SizedBox(height: 6),
              _TripDateLine(
                label: strings.t('trip.date'),
                value: date,
              ),
            ],
            if (trip.truck?.plateNumber != null) ...[
              const SizedBox(height: 4),
              Text(
                trip.truck!.plateNumber!,
                style: AppText.label.copyWith(color: AppColors.ink),
              ),
            ],
            const SizedBox(height: 16),
            _RouteMap(
              pickupCity: _placeName(trip.pickupCity, trip.pickupLabel),
              deliveryCity: _placeName(trip.deliveryCity, trip.deliveryLabel),
              pickupLabel: strings.t('trip.pickup'),
              deliveryLabel: strings.t('trip.delivery'),
              progress: progress,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    strings.t('home.open_trip'),
                    style: AppText.button.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(width: 8),
                  const _ForwardIcon(color: AppColors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeEmptyTrip extends StatelessWidget {
  const HomeEmptyTrip({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const _IdleRouteArt(),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: AppText.title),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: AppText.bodyMuted),
        ],
      ),
    );
  }
}

class _RouteMap extends StatelessWidget {
  const _RouteMap({
    required this.pickupCity,
    required this.deliveryCity,
    required this.pickupLabel,
    required this.deliveryLabel,
    required this.progress,
  });

  final String pickupCity;
  final String deliveryCity;
  final String pickupLabel;
  final String deliveryLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _RouteEnd(
                  label: pickupLabel,
                  city: pickupCity,
                  alignEnd: false,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: _ForwardIcon(color: AppColors.muted, size: 16),
              ),
              Expanded(
                child: _RouteEnd(
                  label: deliveryLabel,
                  city: deliveryCity,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RouteTrack(progress: progress),
        ],
      ),
    );
  }
}

class _RouteEnd extends StatelessWidget {
  const _RouteEnd({
    required this.label,
    required this.city,
    required this.alignEnd,
  });

  final String label;
  final String city;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.caption,
        ),
        const SizedBox(height: 2),
        Text(
          city,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: AppText.title,
        ),
      ],
    );
  }
}

class _RouteTrack extends StatelessWidget {
  const _RouteTrack({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                height: 8,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: AppColors.primaryMuted),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.12, 1.0),
                        child: const ColoredBox(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Row(
            children: [
              _StopDot(filled: true),
              Spacer(),
              _StopDot(filled: false),
            ],
          ),
          const _DrivingTruck(),
        ],
      ),
    );
  }
}

class _StopDot extends StatelessWidget {
  const _StopDot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? AppColors.primary : AppColors.ink,
          width: 2.2,
        ),
      ),
    );
  }
}

class _TruckMark extends StatelessWidget {
  const _TruckMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: _Facing(
        child: const Icon(
          Icons.local_shipping_rounded,
          color: AppColors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _IdleRouteArt extends StatelessWidget {
  const _IdleRouteArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: AppColors.primaryMuted,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StopDot(filled: true),
              _TruckMark(),
              _StopDot(filled: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrivingTruck extends StatefulWidget {
  const _DrivingTruck();

  @override
  State<_DrivingTruck> createState() => _DrivingTruckState();
}

class _DrivingTruckState extends State<_DrivingTruck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drive = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _drive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _drive,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_drive.value);
        return Align(
          alignment: AlignmentDirectional(-1 + (2 * t), 0),
          child: child,
        );
      },
      child: const _TruckMark(),
    );
  }
}

class _LivePulse extends StatefulWidget {
  const _LivePulse();

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.75, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 9,
        height: 9,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _Facing extends StatelessWidget {
  const _Facing({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    if (!rtl) return child;
    return Transform.flip(flipX: true, child: child);
  }
}

class _ForwardIcon extends StatelessWidget {
  const _ForwardIcon({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_forward_rounded, color: color, size: size);
  }
}

String _placeName(String? city, String label) {
  final trimmed = city?.trim() ?? '';
  if (trimmed.isNotEmpty) return trimmed;
  if (label.trim().isEmpty) return '—';
  return label.split(',').last.trim();
}

String? _tripDate(BuildContext context, Trip trip) {
  return formatTripDate(
    trip.tripDateRaw,
    Localizations.localeOf(context).languageCode,
  );
}

class _TripDateLine extends StatelessWidget {
  const _TripDateLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.event_outlined,
          size: 16,
          color: AppColors.muted,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '$label · $value',
            style: AppText.label.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}
