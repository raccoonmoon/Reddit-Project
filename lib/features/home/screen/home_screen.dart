import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/home/delegates/search_community_delegate.dart';
import 'package:reddit/features/home/drawer/community_list_drawer.dart';
import 'package:reddit/features/home/drawer/profile_drawer.dart';
import 'package:reddit/theme/pallete.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: Builder(builder: (context) {
          return IconButton(
              icon: Icon(Icons.menu), onPressed: () => displayDrawer(context));
        }),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context, delegate: SearchCommunityDelegate(ref));
              }),
          Builder(builder: (context) {
            return IconButton(
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                ),
                onPressed: () {
                  displayEndDrawer(context);
                });
          }),
        ],
      ),
      body: Constants.tabWidgets[_page],
      drawer: CommunityListDrawer(),
      endDrawer: isGuest? null: ProfileDrawer(),
      bottomNavigationBar: isGuest? null:CupertinoTabBar(
        activeColor: currentTheme.iconTheme.color,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
        ],
        onTap: onPageChanged,
        currentIndex: _page,
      ),
    );
  }
}
