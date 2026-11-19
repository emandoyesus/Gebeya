import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/basket/presentation/basket_provider.dart';
import '../features/basket/presentation/screens/basket_screen.dart';
import '../features/basket/presentation/widgets/floating_basket_bar.dart';
import '../features/items/presentation/screens/home_screen.dart';
import '../features/items/presentation/screens/item_detail_screen.dart';
import '../features/markets/presentation/screens/markets_screen.dart';
import '../features/reporting/presentation/screens/add_report_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/settings_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/markets',
            builder: (context, state) => const MarketsScreen(),
          ),
          GoRoute(
            path: '/basket',
            builder: (context, state) => const BasketScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/item/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ItemDetailScreen(itemId: id);
        },
      ),
      GoRoute(
        path: '/report',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final itemId = state.uri.queryParameters['itemId'];
          return AddReportScreen(initialItemId: itemId);
        },
      ),
    ],
  );
});

class _ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const _ScaffoldWithNavBar({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final basketCount = ref.watch(basketTotalCountProvider);
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/markets')) {
      currentIndex = 1;
    } else if (location.startsWith('/basket')) {
      currentIndex = 2;
    } else if (location.startsWith('/settings')) {
      currentIndex = 3;
    }

    final isBasketRoute = location.startsWith('/basket');

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      body: Stack(
        children: [
          child,
          if (!isBasketRoute)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingBasketBar(),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0C0E12),
          border: Border(top: BorderSide(color: Color(0xFF1E232B), width: 1)),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Prices / Catalog
              _NavBarItem(
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront_rounded,
                label: isAmharic ? 'ዋጋዎች' : 'Prices',
                isSelected: currentIndex == 0,
                onTap: () => context.go('/'),
              ),
              // 2. Markets / Locations
              _NavBarItem(
                icon: Icons.location_city_outlined,
                activeIcon: Icons.location_city_rounded,
                label: isAmharic ? 'ገበያዎች' : 'Markets',
                isSelected: currentIndex == 1,
                onTap: () => context.go('/markets'),
              ),
              // 3. Central Neon Add Action
              Tooltip(
                message: isAmharic ? 'ዋጋ ያስመዝግቡ' : 'Report price',
                child: Semantics(
                  button: true,
                  label: isAmharic ? 'ዋጋ ያስመዝግቡ' : 'Report price',
                  child: InkWell(
                    onTap: () => context.push('/report'),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2D15A),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB2D15A).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          size: 28,
                          color: Color(0xFF0C0E12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 4. Quick Grocery Basket
              _NavBarItem(
                icon: Icons.shopping_basket_outlined,
                activeIcon: Icons.shopping_basket_rounded,
                label: isAmharic ? 'ቅርጫት' : 'Basket',
                isSelected: currentIndex == 2,
                badgeCount: basketCount,
                onTap: () => context.go('/basket'),
              ),
              // 5. Settings
              _NavBarItem(
                icon: Icons.tune_outlined,
                activeIcon: Icons.tune_rounded,
                label: isAmharic ? 'ማስተካከያ' : 'Settings',
                isSelected: currentIndex == 3,
                onTap: () => context.go('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFB2D15A) : const Color(0xFF8E9BAE);
    final hasBadge = badgeCount != null && badgeCount! > 0;

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        selected: isSelected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 50, minHeight: 46),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        scale: isSelected ? 1.12 : 1.0,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Icon(
                            isSelected ? activeIcon : icon,
                            key: ValueKey<bool>(isSelected),
                            size: 22,
                            color: color,
                          ),
                        ),
                      ),
                      if (hasBadge)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2D15A),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB2D15A).withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              badgeCount! > 99 ? '99+' : '$badgeCount',
                              style: const TextStyle(
                                color: Color(0xFF0C0E12),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
