import 'dart:io';

// import 'package:private_photo_album/photo_api.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_private_photo_album/photo.dart';
import 'package:my_private_photo_album/photo_api.dart';
import 'package:my_private_photo_album/photo_notifier.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class PhotoForm extends StatefulWidget {
  final bool isUpdating;

  PhotoForm({@required this.isUpdating});

  @override
  _PhotoFormState createState() => _PhotoFormState();
}

class _PhotoFormState extends State<PhotoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;

  Photo _currentPhoto;
  String _imageUrl;
  File _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    PhotoNotifier photoNotifier =
        Provider.of<PhotoNotifier>(context, listen: false);

    if (photoNotifier.currentPhoto != null) {
      _currentPhoto = photoNotifier.currentPhoto;
    } else {
      _currentPhoto = Photo();
    }

    _imageUrl = _currentPhoto.image;
  }

  _showImage() {
    if (_imageFile == null && _imageUrl == null) {
      return Text("No image inserted");
    } else if (_imageFile != null) {
      print('showing image from local file');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.file(
            _imageFile,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400),
            ),
            onPressed: () => _showPicker(context),
          )
        ],
      );
    } else if (_imageUrl != null) {
      print('showing image from url');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.network(
            _imageUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400),
            ),
            onPressed: () => _showPicker(context),
          )
        ],
      );
    }
  }

  _showPicker(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _getLocalImageFromGallery(context);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _getLocalImageFromCamera(context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _getLocalImageFromGallery(BuildContext context) async {
    final pickedFile = await _picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 400);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile?.path);
      });
    }

    // File imageFile = File(pickedFile.path);

    // if (imageFile != null) {
    //   setState(() {
    //     _imageFile = imageFile;
    //   });
    // }
  }

  _getLocalImageFromCamera(BuildContext context) async {
    final pickedFile = await _picker.getImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 400);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile?.path);
      });
    }

    // File imageFile = File(pickedFile.path);

    // if (imageFile != null) {
    //   setState(() {
    //     _imageFile = imageFile;
    //   });
    // }
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      initialValue: _currentPhoto.name,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is required';
        }

        if (value.length < 3 || value.length > 20) {
          return 'Name must be more than 3 and less than 20';
        }

        return null;
      },
      onSaved: (String value) {
        _currentPhoto.name = value;
      },
    );
  }

  Widget _buildFolderField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Folder'),
      initialValue: _currentPhoto.folder,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Folder is required';
        }

        if (value.length < 3 || value.length > 20) {
          return 'Folder must be more than 3 and less than 20';
        }

        return null;
      },
      onSaved: (String value) {
        _currentPhoto.folder = value;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Description'),
      initialValue: _currentPhoto.description,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Description is required';
        }

        if (value.length < 3 || value.length > 30) {
          return 'Description must be more than 3 and less than 30';
        }

        return null;
      },
      onSaved: (String value) {
        _currentPhoto.description = value;
      },
    );
  }

  Widget _buildLocationField() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Location'),
          initialValue: _currentPhoto.location,
          onSaved: (String value) {
            _currentPhoto.location = _currentAddress;
          },
        ),
        FlatButton(
          onPressed: () {
            _getCurrentLocation();
          },
          color: Colors.green,
          child: Text("Find Location"),
        )
      ],
    );
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _onPhotoUploaded(Photo photo) {
    PhotoNotifier photoNotifier =
        Provider.of<PhotoNotifier>(context, listen: false);
    photoNotifier.addPhoto(photo);
    Navigator.pop(context);
  }

  _savePhoto() {
    print('savePhoto Called');
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    print('form saved');

    uploadPhotoAndImage(
        _currentPhoto, widget.isUpdating, _imageFile, _onPhotoUploaded);

    print("name: ${_currentPhoto.name}");
    print("folder: ${_currentPhoto.folder}");
    print("description: ${_currentPhoto.description}");
    print("location: ${_currentPhoto.location}");
    print("_imageFile ${_imageFile.toString()}");
    print("_imageUrl $_imageUrl");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Photo Form')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(children: <Widget>[
            _showImage(),
            SizedBox(height: 16),
            Text(
              widget.isUpdating ? "Edit Photo" : "Create Photo",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 16),
            _imageFile == null && _imageUrl == null
                ? ButtonTheme(
                    child: RaisedButton(
                      onPressed: () => _showPicker(context),
                      child: Text(
                        'Add Photo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : SizedBox(height: 0),
            _buildNameField(),
            _buildFolderField(),
            _buildDescriptionField(),
            _buildLocationField(),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          _savePhoto();
          // Uploader(file: _imageFile);
        },
        child: Icon(Icons.save),
        foregroundColor: Colors.white,
      ),
    );
  }
}
