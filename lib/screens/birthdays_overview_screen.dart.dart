import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:note_http/providers/birthdays.dart';
import 'package:note_http/screens/edit_birthday_screen.dart';
import 'add_birthday_screen.dart';

class BirthdayOverview extends StatefulWidget {
  static const routeName = '/birthdays';
  @override
  _BirthdayOverviewState createState() => _BirthdayOverviewState();
}

class _BirthdayOverviewState extends State<BirthdayOverview> {

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Birthdays>(context).fetchAndSetBirthdays().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Birthday Notes'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(AddBirthdayScreen.routeName);
          },
        ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.of(context).pushNamed(EditBirthdayScreen.routeName);
          },
        ),
      ],
    ),
    
  );
}

}
