import 'package:my_private_photo_album/home.dart';
import 'package:my_private_photo_album/photo_api.dart';
import 'package:my_private_photo_album/photo.dart';
import 'package:my_private_photo_album/photo_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'photo_form.dart';

class PhotoDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context);

    _onPhotoDeleted(Photo photo) {
      Navigator.pop(context);
      photoNotifier.deletePhoto(photo);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(photoNotifier.currentPhoto.name),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return HomePage();
                  }));
                },
                child: Icon(Icons.settings),
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                Image.network(
                  photoNotifier.currentPhoto.image != null
                      ? photoNotifier.currentPhoto.image
                      : 'https://www.testingxperts.com/wp-content/uploads/2019/02/placeholder-img.jpg',
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(height: 24),
                Text(
                  photoNotifier.currentPhoto.name,
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
                Text(
                  'Category: ${photoNotifier.currentPhoto.folder}',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  'Description: ${photoNotifier.currentPhoto.description}',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  'Location: ${photoNotifier.currentPhoto.location}',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'button1',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return PhotoForm(
                    isUpdating: true,
                  );
                }),
              );
            },
            child: Icon(Icons.edit),
            foregroundColor: Colors.white,
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            heroTag: 'button2',
            onPressed: () =>
                deletePhoto(photoNotifier.currentPhoto, _onPhotoDeleted),
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
