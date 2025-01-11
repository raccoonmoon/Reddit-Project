import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/provider/firebase_provider.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/user_model.dart';

//authRepositoryProvider is a provider that creates an instance of AuthRepository.authRepositoryProvider can be used throughout the application to access the AuthRepository instance.
final authRepositoryProvider = Provider(
  //The Provider takes a function that receives a ref parameter, which is used to read other providers.
  (ref) => AuthRepository(
    //ref.read(firestoreProvider) reads the firestoreProvider to get an instance of FirebaseFirestore.same for other two.
    firestore: ref.read(firestoreProvider),
    //^instance defined in constructor.
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignIn),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  CollectionReference get _user =>
      _firestore.collection(FirebaseConstants.usersCollection);

  //authStateChange is a getter that returns a stream of User objects. This stream emits the current user when the authentication state changes.
  //authentication state changes when a user signs in or signs out.
  Stream<User?> get authStateChange => _auth.authStateChanges();

  AuthRepository({
    //These instances are then passed to the AuthRepository constructor to create an AuthRepository instance.
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

//if we want to return user model from it then we can use FutureEither<UserModel> signInWithGoogle() async.
//FutureEither is a type that we have defined in type_defs.dart file.
//in case of syntax change later on we can change it in one place only.which is type_defs.dart file.
  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      //for access to google user account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential;
      if (isFromLogin) {
       userCredential = await _auth.signInWithCredential(credential);
      }else{
userCredential = await _auth.currentUser!.linkWithCredential (credential);
      }
      // Sign in to Firebase and data is going to be stored in console
     

      UserModel userModel;
      //if the user is new we are storing it to db and if not new then else statement will be used .
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
            name: userCredential.user!.displayName ?? 'Untitled',
            profilePic:
                userCredential.user!.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: [
              'awesomeAns',
              'gold',
              'platinum',
              'helpful',
              'plusone',
              'rocket',
              'thankyou',
              'til'
            ]);
        await _user.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();

      UserModel userModel = UserModel(
          name: 'Guest',
          profilePic: Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: false,
          karma: 0,
          awards: []);
      await _user.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

//stream is basically a listener that listens to the changes in the data.
//stream provides real-time updates whenever the document or collection changes
//snapshots() returns a stream of DocumentSnapshot objects. Each DocumentSnapshot contains the data of the document at a specific point in time.
//this maptransforms each DocumentSnapshot into a UserModel instance by mapping the document data to the UserModel
  Stream<UserModel> getUserData(String uid) {
    return _user.doc(uid).snapshots().map((event) {
      return UserModel.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
