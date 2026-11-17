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
      currentIndex = 3;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0C0E12),
          border: Border(top: BorderSide(color: Color(0xFF1E232B), width: 1)),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Today / Prices
              _NavBarItem(
                icon: Icons.wb_sunny_outlined,
                activeIcon: Icons.wb_sunny_rounded,
                label: isAmharic ? 'ዛሬ' : 'Today',
                isSelected: currentIndex == 0,
                onTap: () => context.go('/'),
              ),
              // 2. Markets / Log
              _NavBarItem(
                icon: Icons.list_alt_rounded,
                activeIcon: Icons.list_alt_rounded,
                label: isAmharic ? 'ገበያዎች' : 'Markets',
                isSelected: currentIndex == 1,
                onTap: () => context.go('/markets'),
              ),
              // 3. Central Neon Floating Action Button (+)
              GestureDetector(
                onTap: () => context.push('/report'),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7F33B),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC7F33B).withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 32,
                      color: Color(0xFF0C0E12),
                    ),
                  ),
                ),
              ),
              // 4. Progress / Trends
              _NavBarItem(
                icon: Icons.bar_chart_rounded,
                activeIcon: Icons.bar_chart_rounded,
                label: isAmharic ? 'እንቅስቃሴ' : 'Trends',
                isSelected: currentIndex == 2,
                onTap: () => context.go('/'),
              ),
              // 5. Settings / Learn
              _NavBarItem(
                icon: Icons.menu_book_rounded,
                activeIcon: Icons.menu_book_rounded,
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

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFC7F33B) : const Color(0xFF566171);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 4),
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
    );
  }
}
