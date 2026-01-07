import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/product/presentation/blocs/product_cubit.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isWide = constraints.maxWidth >= 980;

        final body = Row(
          children: [
            if (isWide) const _SidebarRail(),
            Expanded(
              child: Column(
                children: [
                  _TopBar(isWide: isWide),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        return Scaffold(
          drawer: isWide ? null : const Drawer(child: _SidebarDrawer()),
          body: body,
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isWide;
  const _TopBar({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            if (!isWide)
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            const Text(
              'Product Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search products...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => context.read<ProductCubit>().setSearch(v),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => context.read<ProductCubit>().load(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarRail extends StatelessWidget {
  const _SidebarRail();

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final index = loc.startsWith('/settings') ? 1 : 0;

    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: (i) {
        if (i == 0) context.go('/products');
        if (i == 1) context.go('/settings');
      },
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: Text('Products'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }
}

class _SidebarDrawer extends StatelessWidget {
  const _SidebarDrawer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const ListTile(
          title: Text(
            'Product Dashboard',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: const Text('Products'),
          onTap: () {
            Navigator.pop(context);
            context.go('/products');
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            context.go('/settings');
          },
        ),
      ],
    );
  }
}
