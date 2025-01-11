import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/features/post/widget/comment_card.dart';
import 'package:reddit/models/post_model.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
        context: context, text: commentController.text.trim(), post: post);
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (post) {
              return Column(
                children: [
                  PostCard(
                    post: post,
                  ),
                  if(!isGuest)
                  TextField(
                    onSubmitted: (val) => addComment(post),
                    controller: commentController,
                    decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        filled: true,
                        border: InputBorder.none),
                  ),
                  Expanded(
                    child: ref
                        .watch(getPostCommentProvider(widget.postId))
                        .when(
                          data: (data) {
                            return ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = data[index];
                                return CommentCard(comment: comment);
                              },
                            );
                          },
                          error: (error, stackTrace) {
                            return ErrorText(
                              error: error.toString(),
                            );
                          },
                          loading: () => const Loader(),
                        ),
                  ),
                ],
              );
            },
            error: (error, stackTrace) {
              return ErrorText(
                error: error.toString(),
              );
            },
            loading: () => const Loader(),
          ),
    );
  }
}
