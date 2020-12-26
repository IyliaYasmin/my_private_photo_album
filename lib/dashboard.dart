import 'package:my_private_photo_album/home.dart';
import 'package:my_private_photo_album/photo_api.dart';
import 'package:my_private_photo_album/photo_notifier.dart';
import 'package:my_private_photo_album/detail.dart';
import 'package:my_private_photo_album/photo_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_private_photo_album/blocs/theme.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    PhotoNotifier photoNotifier =
        Provider.of<PhotoNotifier>(context, listen: false);
    getPhotos(photoNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context);

    Future<void> _refreshList() async {
      getPhotos(photoNotifier);
    }

    print("building Feed");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
        ),
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
      body: new RefreshIndicator(
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Image.network(
                photoNotifier.photoList[index].image != null
                    ? photoNotifier.photoList[index].image
                    : 'https://www.testingxperts.com/wp-content/uploads/2019/02/placeholder-img.jpg',
                width: 120,
                fit: BoxFit.fitWidth,
              ),
              title: Text(photoNotifier.photoList[index].name),
              subtitle: Text(photoNotifier.photoList[index].folder),
              onTap: () {
                photoNotifier.currentPhoto = photoNotifier.photoList[index];
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return PhotoDetail();
                }));
              },
            );
          },
          itemCount: photoNotifier.photoList.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: Colors.black,
            );
          },
        ),
        onRefresh: _refreshList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          photoNotifier.currentPhoto = null;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return PhotoForm(
                isUpdating: false,
              );
            }),
          );
        },
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
      ),
    );
  }
}
