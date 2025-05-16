import 'package:chillwave/apps/router/router_name.dart';
import 'package:chillwave/pages/home/home_page.dart';
import 'package:chillwave/pages/welcome/welcome_page.dart';
import 'package:chillwave/pages/login/login_page.dart';
import 'package:chillwave/pages/forgot_password/forgot_password_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class RouterCustum {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouterName.welcome,
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
      GoRoute(
        path: '/login',
        name: RouterName.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouterName.forgotPassword,
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordPage();
        },
      ),
      
      
    ],
  );
}