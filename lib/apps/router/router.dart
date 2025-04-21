
import 'package:chillwave/apps/router/router_name.dart';
import 'package:chillwave/pages/welcome/welcome_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class RouterCustum{
  static final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: RouterName.welcome,
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomePage();
      },
      // routes: <RouteBase>[
      //   GoRoute(
      //     path: 'login',
      //     name: RouterName.login,
      //     builder: (BuildContext context, GoRouterState state) {
      //       return const LoginPage();
      //     },
      //     routes: [
      //       GoRoute(
      //         path: 'home',
      //         name: RouterName.home,
      //         builder: (BuildContext context, GoRouterState state) {
      //           return const HomePage();
      //         },
      //       ),
      //     ]
      //   ),
      //   GoRoute(
      //     path: 'register',
      //     name: RouterName.register,
      //     builder: (BuildContext context, GoRouterState state) {
      //       return const RegisterPage();
      //     },
      //   ),
      // ],
    ),
  ],
);
}