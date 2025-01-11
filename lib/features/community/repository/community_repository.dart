import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/provider/firebase_provider.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.read(firestoreProvider));
} //this firebase instance is coming from firebase_provider.dart file.
    );

//This is a class that handles operations related to communities.
class CommunityRepository {
  final FirebaseFirestore _firestore;
//private variable that holds an instance of FirebaseFirestore, which is used to interact with Firestore database.
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;
//The constructor takes a FirebaseFirestore instance as a required parameter and assigns it to the _firestore variable.

//this is communities collection reference.we created a private variable _communities ( we do not want it to be accessible outside this class because firebase calls are made to be in repository part)that holds a reference to the communities collection in Firestore.
//here CollectionReference is a class from the cloud_firestore package that represents a reference to a Firestore collection.
//The get keyword is used to create a getter method that returns the value of the _communities variable.
//FireConstants.communitiesCollection is a constant string that holds the name of the communities collection in Firestore.
  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
      
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

//custom type representing a future that either completes with a value or an error.
//this method creates a new community in the Firestore database.
//this Community parameter is the community object that we want to create in controller class and  it will create in the firestore database.
  FutureVoid createCommunity(Community community) async {
    try {
      //communityDoc: variable holds the document reference for the community with the given name
      var communityDoc = await _communities
          .doc(community.name)
          .get(); //the document id in this case is the name of the community.
      //.doc() method is used to get a reference to a document in a collection.it is from the cloud_firestore package.
      //checks if a community with the same name already exists in the Firestore database.
      if (communityDoc.exists) {
        //if exists, it throws an error message.
        throw 'Community with same name already exists!';
      }
      return right(
        _communities.doc(community.name).set(
              community.toMap(),
            ), //this method is used to create a new document in the communities collection with the given community name and the data from the community object.
      );
    } on FirebaseException catch (e) {
      //on FirebaseException catch (e): This block catches any FirebaseException errors and returns a Failure object with the error message from Firebase.
      return left(Failure(e
          .message!)); //This block catches any other errors (including the custom error message) and returns a Failure object with the error message.
      // FirebaseException is a specific type of exception that comes from Firebase operations. It has a message property that provides a human-readable description of the error.FirebaseException Handling: Uses e.message to provide a specific error message from Firebase.If e.message is null, it provides a default error message.! is used to assert that e.message is not null.
    } catch (e) {
      //The Failure class is imported from the failure.dart file in the core directory of your project
      return left(
        Failure(
          //e.toString(): This is a general catch-all for any other types of exceptions that might occur. Calling toString() on an exception provides a string representation of the error, which includes the error message and possibly other details.General Exception Handling: Uses e.toString() to capture and return the complete error information for any other types of exceptions.
          e.toString(),
        ),
      );
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update(
          {
            'members': FieldValue.arrayUnion(
              [userId],
            ) //firebase give us this method to add a value in an array field.
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update(
          {
            'members': FieldValue.arrayRemove(
              [userId],
            ) //firebase give us this method to add a value in an array field.
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members',
            arrayContains:
                uid) //arrayContains is a method that checks if the given value is present in the array field of a document.
        .snapshots() //snapshots() method is used to listen for changes in the query results and returns a stream of QuerySnapshot objects. and query is the communities collection where the members array contains the given uid.QuerySnapshot is a collection of documents that match the query criteria.
        .map((event) {
      //event is a QuerySnapshot object that contains the documents that match the query criteria.
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities; //returns a list of communities that the user is a member of.
    }); //This method returns a stream of communities that the user with the given uid is a member of.
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities
        .doc(name)
        .snapshots() //snapshots() method is used to listen for changes in the document and returns a stream of DocumentSnapshot objects.
        .map(
            (event) => Community.fromMap(event.data() as Map<String, dynamic>));
    //event is a DocumentSnapshot object that contains the data of the document.
    //This method returns a stream of the community with the given name.
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(
        _communities.doc(community.name).update(
              community.toMap(),
            ), //This method is used to update the data of the document with the given community name in the communities collection.
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities
            .add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }
  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(
        _communities.doc(communityName).update(
             {
              'mods': uids,
             }
            ), //This method is used to update the data of the document with the given community name in the communities collection.
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Stream<List<Post>> getCommunityPosts(String name) {
    return _posts
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }
}

/*we always create models in controller class and then pass it through parameters.
but in auth repository we created model that is because we the .user property 
is coming from the UserCredential object returned by the Firebase Authentication method
 signInWithCredential.we need to sign in to get data.This property provides access to the authenticated user's information.
 and don't know how to to sign in and then throw that information in controller.
 but but but here we can create community just by passing it in the controller because except 
 for community name.
 */
