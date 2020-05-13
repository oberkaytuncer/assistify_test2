import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_messaging_app/services/storage_base.dart';

class FirebaseStorageService implements StorageBase {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  StorageReference _storageReference;

  @override
  Future<String> uploadFile(
    String userID,
    String fileType,
    File willUploadFile,
  ) async {
    _storageReference = _firebaseStorage.ref().child(userID).child(fileType).child(fileType + '.png');
    var uploadTask = _storageReference.putFile(willUploadFile);

    var url = await (await uploadTask.onComplete).ref.getDownloadURL();

    return url;
  }
}
