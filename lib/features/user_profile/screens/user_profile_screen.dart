import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  void navigateToEditUser(BuildContext context) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      //since its not statefulconsumerwidget we can directly use name.
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (user) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(children: [
                        Positioned.fill(
                            child:
                                Image.network(user.banner, fit: BoxFit.cover)),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: EdgeInsets.all(20).copyWith(bottom: 70),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.profilePic),
                            radius: 45,
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: EdgeInsets.all(20),
                          child: OutlinedButton(
                            onPressed: () => navigateToEditUser(context),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 25),
                            ),
                            child: Text('Edit Profile'),
                          ),
                        ),
                      ]),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('u/${user.name}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text('${user.karma} karma'),
                            ),
                            SizedBox(height: 10),
                            Divider(
                              thickness: 2,
                            ),
                          ],
                        ),
                      ),
                    )
                  ];
                },
                body: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ref.watch(getUserPostProvider(uid)).when(
                          data: (data) {
                            return ListView.builder(
                              itemCount: data
                                  .length, // Use the length of `data`, not `communities`
                              itemBuilder: (BuildContext context, int index) {
                                final post = data[index];
                                return PostCard(post: post);
                              },
                            );
                          },
                          error: (error, stackTrace) {
                            //  print(error.toString()); we used this to print error to enable indexing on firestore.
                            return ErrorText(error: error.toString());
                          },
                          loading: () => Loader(),
                        ))),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => Loader(),
          ),
    );
  }
}
