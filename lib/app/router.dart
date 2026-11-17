import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/markets')) {
      currentIndex = 1;
    } else if (location.startsWith('/settings')) {
      currentIndex = 2;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      body: child,
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
                      width: 48,
                      height: 48,
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
                          size: 30,
                          color: Color(0xFF0C0E12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 4. Settings
              _NavBarItem(
                icon: Icons.tune_outlined,
                activeIcon: Icons.tune_rounded,
                label: isAmharic ? 'ማስተካከያ' : 'Settings',
                isSelected: currentIndex == 2,
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

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFB2D15A) : const Color(0xFF8E9BAE);
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
            constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 24,
                    color: color,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                    ),
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
