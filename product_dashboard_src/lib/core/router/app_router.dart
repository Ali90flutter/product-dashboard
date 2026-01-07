import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/product/presentation/pages/product_details_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/products',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/products',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProductListPage()),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return ProductDetailsPage(productId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: Center(child: Text('Settings (placeholder)')),
          ),
        ),
      ],
    ),
  ],
);
