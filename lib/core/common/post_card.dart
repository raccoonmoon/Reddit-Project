import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void navigateToUserProfile(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
     final isGuest = !user.isAuthenticated;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: currentTheme.drawerTheme.backgroundColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 16)
                            .copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => navigateToCommunity(context),
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(
                                          post.communityProfilePic,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'r/${post.communityName}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                navigateToUserProfile(context),
                                            child: Text(
                                              'u/${post.username}',
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (post.uid == user.uid)
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Pallete.redColor),
                                    onPressed: () => deletePost(ref, context),
                                  ),
                              ],
                            ),
                            if (post.awards.isNotEmpty) ...[
                              SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                height: 25,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Image.asset(
                                      Constants.awards[post.awards[index]]!,
                                      height: 23,
                                    );
                                  },
                                ),
                              )
                            ],
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                post.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isTypeImage)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                child: Image.network(
                                  post.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isTypeLink)
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18),
                                  child: AnyLinkPreview(
                                    displayDirection:
                                        UIDirection.uiDirectionHorizontal,
                                    link: post.link!,
                                  )),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Text(
                                    post.description!,
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed:isGuest?(){}: () => upvotePost(ref),
                                      icon: Icon(Constants.up,
                                          size: 30,
                                          color: post.upvotes.contains(user.uid)
                                              ? Pallete.redColor
                                              : null),
                                    ),
                                    Text(
                                      '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote ' : post.upvotes.length - post.downvotes.length}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      onPressed:isGuest?(){}: () => downvotePost(ref),
                                      icon: Icon(Constants.down,
                                          size: 30,
                                          color:
                                              post.downvotes.contains(user.uid)
                                                  ? Pallete.blueColor
                                                  : null),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          navigateToComments(context),
                                      icon: Icon(Icons.comment),
                                    ),
                                    Text(
                                      '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    ref
                                        .watch(getCommunityByNameProvider(
                                            post.communityName))
                                        .when(
                                          data: (data) {
                                            if (data.mods.contains(user.uid)) {
                                              return IconButton(
                                                onPressed: () =>
                                                    deletePost(ref, context),
                                                icon: Icon(
                                                    Icons.admin_panel_settings),
                                              );
                                            }
                                            return SizedBox();
                                          },
                                          error: (error, stackTrace) =>
                                              ErrorText(
                                                  error: error.toString()),
                                          loading: () => Loader(),
                                        ),
                                    IconButton(
                                        onPressed:isGuest?(){}: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                  ),
                                                  itemCount: user.awards.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    final award =
                                                        user.awards[index];
                                                    return GestureDetector(
                                                      onTap: () => awardPost(
                                                          ref, award, context),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.8),
                                                        child: Image.asset(
                                                            Constants.awards[
                                                                award]!),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        icon:
                                            Icon(Icons.card_giftcard_outlined)),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
