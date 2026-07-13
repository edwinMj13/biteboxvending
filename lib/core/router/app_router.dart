import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/navigation/presentation/screens/main_layout_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/franchise/presentation/screens/franchise_screen.dart';
import '../../features/advertise/presentation/screens/advertise_screen.dart';
import '../../features/find_us/presentation/screens/find_us_screen.dart';
import '../../features/get_in_touch/presentation/screens/get_in_touch_screen.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayoutScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/franchise',
                builder: (context, state) => const FranchiseScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/advertise',
                builder: (context, state) => const AdvertiseScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/find-us',
                builder: (context, state) => const FindUsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/get-in-touch',
                builder: (context, state) => const GetInTouchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gallery',
                builder: (context, state) => const GalleryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
