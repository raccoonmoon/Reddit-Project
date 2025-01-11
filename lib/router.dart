import 'package:flutter/material.dart';
import 'package:reddit/features/auth/screens/login_screen.dart';
import 'package:reddit/features/community/screen/add_mods_screen.dart';
import 'package:reddit/features/community/screen/community_screen.dart';
import 'package:reddit/features/community/screen/create_community_screen.dart';
import 'package:reddit/features/community/screen/edit_community_screen.dart';
import 'package:reddit/features/community/screen/mod_tools_screen.dart';
import 'package:reddit/features/home/screen/home_screen.dart';
import 'package:reddit/features/post/screens/add_post_type_screen.dart';
import 'package:reddit/features/post/screens/comment_screen.dart';
import 'package:reddit/features/user_profile/screens/edit_profile_screen.dart';
import 'package:reddit/features/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(
        child: LoginScreen(),
      ),
});

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: HomeScreen(),
        ),
    '/create-community': (_) => MaterialPage(
          child: const CreateCommunityScreen(),
        ),
    '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
            name: route.pathParameters['name']!,
          ),
        ),
    '/mod-tools/:name': (routeData) => MaterialPage(
          child: ModToolsScreen(name: routeData.pathParameters['name']!),
        ),
    '/edit-community/:name': (routeData) => MaterialPage(
          child: EditCommunityScreen(name: routeData.pathParameters['name']!),
        ),
    '/add-mods/:name': (routeData) => MaterialPage(
          //here '/add-mods/:name' is the route name and AddModsScreen is the screen that will be displayed when this route is called.
          child: AddModsScreen(name: routeData.pathParameters['name']!),
        ),
    '/u/:uid': (routeData) => MaterialPage(
          child: UserProfileScreen(uid: routeData.pathParameters['uid']!),
        ),
    '/edit-profile/:uid': (routeData) => MaterialPage(
          child: EditProfileScreen(uid: routeData.pathParameters['uid']!),
        ),
    '/add-post/:type': (routeData) => MaterialPage(
          child: AddPostTypeScreen(type: routeData.pathParameters['type']!),
        ),
    '/post/:postId/comments': (route) => MaterialPage(
          child: CommentScreen(postId: route.pathParameters['postId']!),
        ),
  },
);
