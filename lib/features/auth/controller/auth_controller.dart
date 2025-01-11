import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/repository/auth_repository.dart';
import 'package:reddit/models/user_model.dart';

//provider is the read only widget that can read but cannot modify/update the state
final userProvider = StateProvider<UserModel?>((ref) => null);

//we need to change auth controller provider to state notifier provider as it no longer provided using provider class its provided using state notifier class.
final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    //read changed to watch because in case we change auth repository provider ,we do not want to restart the app.
    ref: ref,
    //here provider ref and final ref down there in authcontroller are similar things so we give like this.
  ),
);

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  //here statenotifier is the class that is used to update the state of the provider.and it will be passed through super.
  //statenotifier will notify all providers that are listening to it that the state has been updated.
  //or every widget that will have provider that will be listening to it will be updated.
  //super will have the type of the state that we want to update.
  //we do not need to notify listeners as statenotifier will do it for us.

  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);
  //here false will show that state is not update yet and is loading and initially  loading is not happening.

  Stream<User?> get authStateChange => _authRepository.authStateChange;
  //here we are getting the stream of user from the auth repository.this user coming from firebase auth state change.

  void signInWithGoogle(BuildContext context,bool isFromLogin) async {
    state =
        true; //here we are updating the state to true which means loading is happening.
    final user = await _authRepository.signInWithGoogle(isFromLogin);
    state =
        false; //in case of success or failure we will update the state to false.
    user.fold(
      //here l means left which is failure and r means right which is success.
      (l) => showSnackBar(context, l.message),
      //here we are updating the userProvider state with the user model.
      //.notifier give us function to update the state.
      //here state is the before updated state and userModel is the new state.
      (userModel) =>
          _ref.read(userProvider.notifier).update((state) => userModel),
    );
  }

  void signInAsGuest(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInAsGuest();
    state = false;
    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) =>
          _ref.read(userProvider.notifier).update((state) => userModel),
    );
  }

//here we are getting the user data from the auth repository
  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void logOut() {
    _authRepository.logOut();
  }
}
