import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/models/trip_status.dart';

class TripProgressTrack extends StatelessWidget {
  const TripProgressTrack({
    super.key,
    required this.status,
    required this.strings,
  });

  final TripStatus status;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    if (status == TripStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final stages = TripStatus.visibleFlow;
    final current = status.progressIndex;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stages.length; i++)
          Expanded(
            child: _Stage(
              label: strings.t(stages[i].labelKey),
              state: i < current
                  ? _StageState.done
                  : i == current
                  ? _StageState.current
                  : _StageState.upcoming,
              leading: i > 0,
              trailing: i < stages.length - 1,
              leadingFilled: i <= current,
              trailingFilled: i < current,
            ),
          ),
      ],
    );
  }
}

enum _StageState { done, current, upcoming }

class _Stage extends StatelessWidget {
  const _Stage({
    required this.label,
    required this.state,
    required this.leading,
    required this.trailing,
    required this.leadingFilled,
    required this.trailingFilled,
  });

  final String label;
  final _StageState state;
  final bool leading;
  final bool trailing;
  final bool leadingFilled;
  final bool trailingFilled;

  @override
  Widget build(BuildContext context) {
    final labelColor = switch (state) {
      _StageState.current => AppColors.ink,
      _StageState.done => AppColors.ink,
      _StageState.upcoming => AppColors.muted,
    };

    return Column(
      children: [
        SizedBox(
          height: 22,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: leading
                        ? _Rail(filled: leadingFilled)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: trailing
                        ? _Rail(filled: trailingFilled)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              _Mark(state: state),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppText.caption.copyWith(
            color: labelColor,
            fontWeight: state == _StageState.upcoming
                ? FontWeight.w500
                : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      color: filled ? AppColors.primary : AppColors.primaryMuted,
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.state});

  final _StageState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      _StageState.done => Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 10,
          color: AppColors.white,
        ),
      ),
      _StageState.current => Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 3),
        ),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
      _StageState.upcoming => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.navyMuted, width: 2),
        ),
      ),
    };
  }
}
