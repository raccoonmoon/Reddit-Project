import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/provider/firebase_provider.dart';
import 'package:reddit/core/type_defs.dart';


final storageRepositoryProvider = Provider((ref) {//storageRepositoryProvider is the class that we have created which will allow us to store a file without having to write more code.
  return StorageRepository(firebaseStorage: ref.watch(storageProvider));//storageProvider is the instance of firebase storage. a class which allow us to store files in firebase storage
}); 

class StorageRepository {
  final FirebaseStorage _firebaseStorage;
  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  //when we upload image to firebase storage we get a download url back which will be used to store the image in firestore
  //here we are returning a FutureEither which is a custom type that we created to handle errors and success because
  FutureEither<String> storeFile(
      {required String path, required String id, required File? file}) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child(id);
      UploadTask uploadTask = ref.putFile(file!);
      final snapshot = await uploadTask;
      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
