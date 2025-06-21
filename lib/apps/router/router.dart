import 'package:chillwave/apps/router/router_name.dart';
import 'package:chillwave/pages/home/home_center.dart';
import 'package:chillwave/pages/home/home_page.dart';
import 'package:chillwave/pages/profile/user_profile_page.dart';
import 'package:chillwave/pages/register/register_page.dart';
import 'package:chillwave/pages/login/login_page.dart';
import 'package:chillwave/pages/select_artist/select_artist_page.dart';
import 'package:chillwave/pages/upload_data_to_firebase.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:chillwave/pages/search/search_page.dart';
import 'package:chillwave/pages/forgot_password/password_reset_controller.dart';

class RouterCustum {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouterName.login,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeCenter();
        },
      ),
      GoRoute(
        path: '/register',
        name: RouterName.register,
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: '/select',
        name: RouterName.select,
        builder: (BuildContext context, GoRouterState state) {
          return const SelectArtistPage();
        },
      ),
      GoRoute(
        path: '/homecenter',
        name: 'homecenter',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeCenter();
        },
      ),
      GoRoute(
        path: '/home',
        name: RouterName.home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouterName.forgotPassword,
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordPage();
        },
      ),
      GoRoute(
        path: '/Profile-page',
        name: RouterName.profile,
        builder: (BuildContext context, GoRouterState state) {
          return const UserProfilePage();
        },
      ),
    ],
  );
}
