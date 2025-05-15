import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';

import '../features/authentication/data/auth_repository.dart';
import '../features/authentication/presentation/login_screen.dart';
import '../features/authentication/presentation/register_screen.dart';
import '../features/home/objects/fahrzeug.dart';
import '../features/home/presentation/editFahrzeug_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/scaffold_with_navbar.dart';
import '../features/map/presentation/karte_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

///Für jeden neuen Screen hier einen Namen anlegen
enum AppRoute {
  login,
  register,
  home,
  map,
  profile,
  editFahrzeug,
  activity,
  // redirect,
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionNavigatorKey1 = GlobalKey<NavigatorState>();
final _sectionNavigatorKey2 = GlobalKey<NavigatorState>();
final _sectionNavigatorKey3 = GlobalKey<NavigatorState>();

///Routing in der App. Für jeden Screen muss eine Route angelegt werden.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: false,
    initialLocation: '/login',
    /// redirect an dieser Stelle zu benutzen gibt Probleme mit Routen die in einer shellroute sind (home screen)
    // redirect: (context, state) {
    //   final isLoggedIn = ref.watch(LoginStatusProvider).value != null;
    //   if (!isLoggedIn) {
    //     return '/login';
    //   }
    //   if (isLoggedIn) {
    //     return '/redirect';
    //   }
    //   return null;
    // },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        name: AppRoute.login.name,
        redirect: (context, state) {
          // final isLoggedIn = ref.watch(LoginStatusProvider).value != null;
          /// LOGIN VON ERP APP ÜBERNEHMEN
          // final isLoggedIn = true;
          // if (!isLoggedIn) {
          //   return '/login';
          // }
          // if (isLoggedIn) {
          //   return '/home';
          // }
          // return null;
          /////////////////////////////////////////////
          final authState = ref.watch(authProvider);

          if (authState.isLoading) return null; // Prevent redirects while checking login state
          if (authState.value != AuthStatus.signedIn) {
            return '/login';
          }
          return '/home'; // Allow navigation to proceed
          //////////////////////////////////////////////
          return '/home';
        },
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Return the widget that implements the custom shell (e.g a BottomNavigationBar).
          // The [StatefulNavigationShell] is passed to be able to navigate to other branches in a stateful way.
          return ScaffoldWithNavbar(navigationShell);
        },
        branches: [
          // The route branch for the 1º Tab
          StatefulShellBranch(
            initialLocation: '/home',
            navigatorKey: _sectionNavigatorKey1,
            // Add this branch routes
            // each routes with its sub routes if available e.g feed/uuid/details
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'editFahrzeug',
                    parentNavigatorKey: _sectionNavigatorKey1,
                    builder: (context, state) {
                      Fahrzeug fahrzeug = state.extra as Fahrzeug;
                      return EditFahrzeugScreen(diesesFahrzeug: fahrzeug);
                    },
                  ),
                  // GoRoute(
                  //   path: 'activity',
                  //   parentNavigatorKey: _sectionNavigatorKey1,
                  //   builder: (context, state) {
                  //     Tracker tracker = state.extra as Tracker;
                  //     return ActivityScreen(dieserTracker: tracker);
                  //   },
                  // )
                ],
              ),
            ],
          ),

          // The route branch for 2º Tab
          StatefulShellBranch(
            navigatorKey: _sectionNavigatorKey2,
            routes: <RouteBase>[
              GoRoute(
                path: '/map',
                builder: (context, state) => const KarteScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionNavigatorKey3,
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilScreen(),
              ),
            ],
          ),
        ],
      ),
      // GoRoute(
      //   path: '/',
      //   name: AppRoute.home.name,
      //   builder: (context, state) => const HomeScreen(),
      //   routes: [
      // GoRoute(
      //     path: '/map',
      //     name: AppRoute.map.name,
      //     builder: (context, state) => const KarteScreen(),
      // ),
      // GoRoute(
      //     path: '/profile',
      //     name: AppRoute.profile.name,
      //     builder: (context, state) => const ProfilScreen(),
      // )
      // ///Subrouten vom Hauptscreen hier hinzufügen
    ],
  );
  //   ],
  // );
});