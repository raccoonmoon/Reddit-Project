import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logOut();
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(user.profilePic),
          ),
          SizedBox(height: 10),
          Text(
            'u/${user.name}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Divider(),
          ListTile(
            title: Text('My Profile'),
            leading: Icon(Icons.person),
            onTap: () => navigateToUserProfile(context, user.uid),
          ),
          ListTile(
            title: Text('Logout'),
            leading: Icon(
              Icons.logout,
              color: Pallete.redColor,
            ),
            onTap: () {
              logOut(
                  ref); //we passed ref here because we are using ref in logOut function.and we are using ref in logOut function because we are using authControllerProvider.notifier in logOut function.
            },
          ),
          Switch.adaptive(
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey,
            value: ref.watch(themeNotifierProvider.notifier).mode == ThemeMode.dark,
            onChanged: (value) {toggleTheme(ref);},
          )
        ],
      )),
    );
  }
}
