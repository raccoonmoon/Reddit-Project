import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/provider/firebase_provider.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/comment_model.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.read(firestoreProvider));
} //this firebase instance is coming from firebase_provider.dart file.
    );

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  FutureVoid addPost(Post post) async {
    try {
      return right(
        _posts.doc(post.id).set(
              post.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _posts
        .where('communityName',
            whereIn: communities
                .map((e) => e.name)
                .toList()) //from here This filters the posts to only include those that belong to the specified communities. It does this by checking if the community field in the posts matches any of the community name in the provided list.
        .orderBy('createdAt', descending: true)
        .snapshots() //This returns a stream of snapshots, providing real-time updates whenever the data changes.
        .map(
          //This transforms each snapshot into a list of Post objects.
          (event) => event
              .docs // This converts each document in the snapshot into a Post object using the Post.fromMap method and collects them into a list.
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        ); //this method will return a stream of list of posts.what it does is it will fetch list of post from Community in firestore.
    //It returns a Stream of List<Post>, which means it provides real-time updates of a list of posts.
    //fetchUserPosts: Fetches posts from Firestore for the specified communities.
    // Real-time Updates: Returns a stream that provides real-time updates of the list of posts.
    // Filtering: Only includes posts that belong to the specified communities.
    // Transformation: Converts Firestore documents into Post objects.
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _posts.orderBy('createdAt', descending: true).limit(10).snapshots().map(
          (event) => event.docs
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(Post post, String userId) {
    //we put this logic in here not in controller because its a feature logic.
    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update(
        {
          'downvotes': FieldValue.arrayRemove([userId])
        },
      );
    }
    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update(
        {
          'upvotes': FieldValue.arrayRemove([userId])
        },
      );
    } else {
      _posts.doc(post.id).update(
        {
          'upvotes': FieldValue.arrayUnion([userId])
        },
      );
    }
  }

  void downVote(Post post, String userId) {
    //we put this logic in here not in controller because its a feature logic.
    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update(
        {
          'upvotes': FieldValue.arrayRemove([userId])
        },
      );
    }
    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update(
        {
          'downvotes': FieldValue.arrayRemove([userId])
        },
      );
    } else {
      _posts.doc(post.id).update(
        {
          'downvotes': FieldValue.arrayUnion([userId])
        },
      );
    }
  }

  Stream<Post> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((events) => Post.fromMap(events.data() as Map<String, dynamic>));
  }

  FutureVoid addComments(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());
      return right(_posts
          .doc(comment.postId)
          .update({'commentCount': FieldValue.increment(1)}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentsOfpost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Comment.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid awardPost(Post post, String award, String senderId) async {
    try {
      _posts.doc(post.id).update({
        'awards': FieldValue.arrayUnion([award])
      });
      _users.doc(senderId).update({
        'awards': FieldValue.arrayRemove([award])
      });
      return right(
        _users.doc(post.uid).update(
          {
            'awards': FieldValue.arrayUnion([award])
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
