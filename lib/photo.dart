import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  String id;
  String name;
  String folder;
  String image;
  String description;
  String location;
  Timestamp createdAt;
  Timestamp updatedAt;

  Photo();

  Photo.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    folder = data['folder'];
    image = data['image'];
    description = data['description'];
    location = data['location'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'folder': folder,
      'image': image,
      'description': description,
      'location': location,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }
}
