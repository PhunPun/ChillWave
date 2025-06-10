import 'package:chillwave/apps/router/router_name.dart';
import 'package:chillwave/pages/home/home_page.dart';
import 'package:chillwave/pages/profile/user_profile_page.dart';
import 'package:chillwave/pages/login/login_page.dart';
import 'package:chillwave/pages/forgot_password/forgot_password_page.dart';
import 'package:chillwave/pages/register/register_page.dart';
import 'package:chillwave/pages/select_artist.dart/select_artist_page.dart';
import 'package:chillwave/pages/upload_data_to_firebase.dart';
import 'package:chillwave/widgets/collection_card.dart';
import 'package:chillwave/widgets/collection_list.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:chillwave/pages/search/search_page.dart';
import 'package:chillwave/pages/welcome/welcome_page.dart';

class RouterCustum {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouterName.welcome,
        builder: (BuildContext context, GoRouterState state) {
          return RegisterPage();
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
        path: '/select',
        name: RouterName.select,
        builder: (BuildContext context, GoRouterState state) {
          return const SelectArtistPage();
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