import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/appear.dart';
import '../../../shared/widgets/async_states.dart';
import '../../../shared/widgets/page_header.dart';
import '../providers/trips_providers.dart';
import 'widgets/trip_summary_card.dart';

class TripHistoryScreen extends ConsumerWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final trips = ref.watch(completedTripsProvider);

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: strings.t('history.title'),
          ),
          Expanded(
            child: trips.when(
              loading: () => LoadingState(message: strings.t('state.loading')),
              error: (error, _) => ErrorState(
                message: errorMessageFor(
                  error,
                  strings.t('state.offline'),
                  strings.t('state.error'),
                ),
                retryLabel: strings.t('state.retry'),
                onRetry: () => ref.invalidate(completedTripsProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    title: strings.t('history.empty'),
                    icon: Icons.history_rounded,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.refresh(completedTripsProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final trip = items[index];
                      return Appear.stagger(
                        index: index,
                        child: TripSummaryCard(
                          trip: trip,
                          strings: strings,
                          onTap: () => context.push('/trips/${trip.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
