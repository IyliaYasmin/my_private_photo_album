import 'dart:io';

import 'package:my_private_photo_album/photo.dart';
import 'package:my_private_photo_album/photo_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

getPhotos(PhotoNotifier photoNotifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('Photos')
      .orderBy("createdAt", descending: true)
      .getDocuments();

  List<Photo> _photoList = [];

  snapshot.documents.forEach((document) {
    Photo photo = Photo.fromMap(document.data);
    _photoList.add(photo);
  });

  photoNotifier.photoList = _photoList;
}

uploadPhotoAndImage(Photo photo, bool isUpdating, File localFile,
    Function photoUploaded) async {
  if (localFile != null) {
    print("uploading image");

    var fileExtension = path.extension(localFile.path);
    print(fileExtension);

    var uuid = Uuid().v4();

    final StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('photos/images/$uuid$fileExtension');

    await firebaseStorageRef
        .putFile(localFile)
        .onComplete
        .catchError((onError) {
      print(onError);
      return false;
    });

    String url = await firebaseStorageRef.getDownloadURL();
    print("download url: $url");
    _uploadPhoto(photo, isUpdating, photoUploaded, imageUrl: url);
  } else {
    print('...skipping image upload');
    _uploadPhoto(photo, isUpdating, photoUploaded);
  }
}

_uploadPhoto(Photo photo, bool isUpdating, Function photoUploaded,
    {String imageUrl}) async {
  CollectionReference photoRef = Firestore.instance.collection('Photos');

  if (imageUrl != null) {
    photo.image = imageUrl;
  }

  if (isUpdating) {
    photo.updatedAt = Timestamp.now();

    await photoRef.document(photo.id).updateData(photo.toMap());

    photoUploaded(photo);
    print('updated photo with id: ${photo.id}');
  } else {
    photo.createdAt = Timestamp.now();

    DocumentReference documentRef = await photoRef.add(photo.toMap());

    photo.id = documentRef.documentID;

    print('uploaded photo successfully: ${photo.toString()}');

    await documentRef.setData(photo.toMap(), merge: true);

    photoUploaded(photo);
  }
}

deletePhoto(Photo photo, Function photoDeleted) async {
  if (photo.image != null) {
    StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl(photo.image);

    print(storageReference.path);

    await storageReference.delete();

    print('image deleted');
  }

  await Firestore.instance.collection('Photos').document(photo.id).delete();
  photoDeleted(photo);
}
