import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/appear.dart';
import '../../../shared/widgets/async_states.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/models/trip.dart';
import '../../auth/providers/auth_controller.dart';
import '../../tracking/providers/background_tracking_controller.dart';
import '../providers/trips_providers.dart';
import 'widgets/home_trip_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final locale = ref.watch(localeControllerProvider).locale;

    // Keep automatic background location sharing aligned with the active trip.
    ref.listen<AsyncValue<List<Trip>>>(tripsListProvider, (_, next) {
      final items = next.valueOrNull;
      if (items == null) return;
      ref
          .read(backgroundTrackingProvider)
          .syncActiveTrip(splitHomeTrips(items).current);
    });

    final trips = ref.watch(tripsListProvider);
    final dashboard = ref.watch(dashboardProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final offline = trips.hasError &&
        errorMessageFor(trips.error!, strings.t('state.offline'), '') ==
            strings.t('state.offline');
    final firstName = (user?.name ?? '').trim().split(RegExp(r'\s+')).first;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PageHeader.overlay,
      child: Scaffold(
        backgroundColor: AppColors.surface,
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
                  final card = home.current == null
                      ? HomeEmptyTrip(
                          title: strings.t('home.no_current'),
                          subtitle: strings.t('home.no_current_hint'),
                        )
                      : HomeHeroTrip(
                          trip: home.current!,
                          strings: strings,
                          onTap: () => context.push(
                            '/trips/${home.current!.id}',
                          ),
                        );
                  return Column(
                    children: [
                      Appear(
                        child: PageHeader(
                          title: strings.t(_greetingKey(), {
                            'name': firstName,
                          }),
                          subtitle: DateFormat.MMMEd(locale.languageCode)
                              .format(DateTime.now()),
                          subtitleAbove: true,
                          largeTitle: true,
                          extra: home.activeCount > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white
                                        .withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    strings.t('home.active_count', {
                                      'count': '${home.activeCount}',
                                    }),
                                    style: AppText.caption.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.white,
                          onRefresh: () {
                            ref.invalidate(dashboardProvider);
                            return ref.refresh(tripsListProvider.future);
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        AppSpacing.lg,
                                        16,
                                        AppSpacing.lg,
                                        24,
                                      ),
                                      child: card,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _greetingKey() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'home.greeting_morning';
  if (hour < 17) return 'home.greeting_afternoon';
  return 'home.greeting_evening';
}
