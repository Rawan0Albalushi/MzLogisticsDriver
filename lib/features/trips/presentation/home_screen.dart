import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/async_states.dart';
import '../../auth/providers/auth_controller.dart';
import '../providers/trips_providers.dart';
import 'widgets/trip_summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final trips = ref.watch(tripsListProvider);
    final dashboard = ref.watch(dashboardProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final offline = trips.hasError &&
        errorMessageFor(trips.error!, strings.t('state.offline'), '') ==
            strings.t('state.offline');

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.t('app.name')),
      ),
      body: Column(
        children: [
          if (offline) OfflineBanner(message: strings.t('state.offline')),
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
                onRetry: () {
                  ref.invalidate(tripsListProvider);
                  ref.invalidate(dashboardProvider);
                },
              ),
              data: (items) {
                final home = splitHomeTrips(
                  items,
                  dashboardActive: dashboard.valueOrNull?.tripsActive,
                );
                return RefreshIndicator(
                  color: AppColors.navy,
                  onRefresh: () {
                    ref.invalidate(dashboardProvider);
                    return ref.refresh(tripsListProvider.future);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      Text(
                        strings.t('home.greeting', {'name': user?.name ?? ''}),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (home.activeCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          strings.t('home.active_count', {
                            'count': '${home.activeCount}',
                          }),
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        strings.t('home.current_trip'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (home.current == null)
                        EmptyState(
                          title: strings.t('home.no_current'),
                          subtitle: strings.t('home.no_current_hint'),
                        )
                      else
                        TripSummaryCard(
                          trip: home.current!,
                          strings: strings,
                          emphasized: true,
                          onTap: () => context.push('/trips/${home.current!.id}'),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        strings.t('home.assigned'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (home.assigned.isEmpty)
                        Text(
                          strings.t('home.no_assigned'),
                          style: const TextStyle(color: AppColors.muted),
                        )
                      else
                        ...home.assigned.map(
                          (trip) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TripSummaryCard(
                              trip: trip,
                              strings: strings,
                              onTap: () => context.push('/trips/${trip.id}'),
                            ),
                          ),
                        ),
                    ],
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
