import 'package:flutter/material.dart';
import 'package:note_http/providers/birthday.dart';
import 'package:note_http/providers/birthdays.dart';
import 'package:note_http/screens/add_birthday_screen.dart';
import 'package:note_http/screens/edit_birthday_screen.dart';
import 'package:provider/provider.dart';

import 'package:note_http/screens/birthdays_overview_screen.dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    
    return MultiProvider(
      
      providers: [
        ChangeNotifierProvider.value(
          value: Birthdays(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Birthday Notes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: BirthdayOverview.routeName,
        routes: {
          BirthdayOverview.routeName: (context) => BirthdayOverview(),
          EditBirthdayScreen.routeName: (context) => EditBirthdayScreen(),
          AddBirthdayScreen.routeName:(context) => AddBirthdayScreen(),
        },
      ),
    );
  }
}
