import 'package:flutter/material.dart';
import 'package:my_private_photo_album/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_private_photo_album/photo_notifier.dart';
import 'package:my_private_photo_album/dashboard.dart';
import 'package:my_private_photo_album/blocs/theme.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PhotoNotifier(),
        ),
      ],
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(ThemeData.dark()),
      child: MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  const MaterialAppWithTheme({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return new MaterialApp(
      title: 'Private Photo Album',
      home: HomeScreen(),
      theme: theme.getTheme(),
    );
  }
}
