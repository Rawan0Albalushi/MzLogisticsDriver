import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/notifications/providers/notifications_providers.dart';
import '../../../shared/widgets/large_screen_frame.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final unread = ref.watch(notificationsListProvider).maybeWhen(
          data: (items) => items.where((item) => item.isUnread).length,
          orElse: () => 0,
        );

    return LargeScreenFrame(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              HapticFeedback.selectionClick();
              navigationShell.goBranch(index);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.local_shipping_outlined),
                selectedIcon: const Icon(Icons.local_shipping_rounded),
                label: strings.t('nav.trips'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_rounded),
                selectedIcon: const Icon(Icons.history_rounded),
                label: strings.t('nav.history'),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                selectedIcon: Badge(
                  isLabelVisible: unread > 0,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_rounded),
                ),
                label: strings.t('nav.notifications'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: strings.t('nav.profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
