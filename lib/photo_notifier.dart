import 'dart:collection';

import 'package:my_private_photo_album/photo.dart';
import 'package:flutter/cupertino.dart';

class PhotoNotifier with ChangeNotifier {
  List<Photo> _photoList = [];
  Photo _currentPhoto;

  UnmodifiableListView<Photo> get photoList => UnmodifiableListView(_photoList);

  Photo get currentPhoto => _currentPhoto;

  set photoList(List<Photo> photoList) {
    _photoList = photoList;
    notifyListeners();
  }

  set currentPhoto(Photo photo) {
    _currentPhoto = photo;
    notifyListeners();
  }

  addPhoto(Photo photo) {
    _photoList.insert(0, photo);
    notifyListeners();
  }

  deletePhoto(Photo photo) {
    _photoList.removeWhere((_photo) => _photo.id == photo.id);
    notifyListeners();
  }
}
