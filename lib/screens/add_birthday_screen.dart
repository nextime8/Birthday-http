import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/birthday.dart';
import '../providers/birthdays.dart';

class AddBirthdayScreen extends StatefulWidget {
  static const routeName = '/add-birthday';

  @override
  _AddBirthdayScreenState createState() => _AddBirthdayScreenState();
}

class _AddBirthdayScreenState extends State<AddBirthdayScreen> {
  final _dateController = TextEditingController();
  final _dateFocusNode = FocusNode();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _noteController = TextEditingController();
  final _noteFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  var _isInit = true;
  var _isLoading = false;

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _dateFocusNode.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    final newBirthday = Birthday(
      id: DateTime.now().toString(),
      date: DateTime.parse(_dateController.text),
      name: _nameController.text,
      note: _noteController.text,
    );

    try {
      await Provider.of<Birthdays>(context, listen: false)
          .addBirthday(newBirthday);
      _showToast('Birthday added!');
      Navigator.of(context).pop();
    } catch (error) {
      _showToast('Adding birthday failed!');
    }

    setState(() {
      _isLoading = false;
    });
  }

  DateTime _dateTime = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = picked;
        _dateController.text = picked.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Birthday'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        hintText: 'Select a date',
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a date.';
                        }

                        final enteredDate = DateTime.tryParse(value);
                        if (enteredDate == null) {
                          return 'Invalid date format.';
                        }

                        final currentDate = DateTime.now();
                        final minDate = DateTime(1900);

                        if (enteredDate.isAfter(currentDate)) {
                          return 'Date must be before or equal to today.';
                        }

                        if (enteredDate.isBefore(minDate)) {
                          return 'Date must be after 1900.';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      textInputAction: TextInputAction.next,
                      focusNode: _nameFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_nameFocusNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: 'Note'),
                      keyboardType: TextInputType.multiline,
                      focusNode: _noteFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a note.';
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
