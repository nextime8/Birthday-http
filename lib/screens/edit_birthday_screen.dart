import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/birthday.dart';
import '../providers/birthdays.dart';

class EditBirthdayScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditBirthdayScreenState createState() => _EditBirthdayScreenState();
}

class _EditBirthdayScreenState extends State<EditBirthdayScreen> {
  final _dateController = TextEditingController();
  final _dateFocusNode = FocusNode();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _noteController = TextEditingController();
  final _noteFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  var _editedBirthday = Birthday(
    id: "0",
    date: DateTime.now(),
    name: '',
    note: '',
  );
  var _initValues = {
    'date': '',
    'name': '',
    'note': '',
  };
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
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final birthdayId = ModalRoute.of(context)?.settings.arguments as String?;
      if (birthdayId != null) {
        _editedBirthday =
            Provider.of<Birthdays>(context, listen: false).findById(birthdayId);
        _initValues = {
          'date': _editedBirthday.date.toString(),
          'name': _editedBirthday.name,
          'note': _editedBirthday.note,
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
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
    if (_editedBirthday.id != "0") {
      await Provider.of<Birthdays>(context, listen: false)
          .updateBirthday(_editedBirthday.id, _editedBirthday);
      Fluttertoast.showToast(
        msg: 'Birthday updated!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      try {
        await Provider.of<Birthdays>(context, listen: false)
            .addBirthday(_editedBirthday);
        Fluttertoast.showToast(
          msg: 'Birthday added!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurred!'),
            content: const Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Birthday'),
        content: const Text('Are you sure you want to delete this birthday?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true); // Return true if confirmed
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false); // Return false if not confirmed
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await _deleteBirthday(context, id);
    }
  }

  Future<void> _deleteBirthday(BuildContext context, String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Birthdays>(context, listen: false).deleteBirthday(id);
      _showToast('Birthday deleted successfully');
      Navigator.of(context).pop();
    } catch (error) {
      _showToast('Deleting failed!');
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
        title: const Text('Edit Birthdays'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                _showDeleteConfirmationDialog(context, _editedBirthday.id),
          ),
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
                      initialValue: _initValues['id'],
                      decoration: const InputDecoration(labelText: 'ID'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an ID.';
                        }

                        final intId = int.tryParse(value);
                        if (intId == null || intId < 0 || intId > 100) {
                          return 'ID must be between 0 and 100.';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _editedBirthday = Birthday(
                          date: _editedBirthday.date,
                          name: _editedBirthday.name,
                          note: _editedBirthday.note,
                          id: value!,
                        );
                      },
                    ),
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
                      onSaved: (value) {
                        _editedBirthday = Birthday(
                          date: DateTime.parse(value!),
                          name: _editedBirthday.name,
                          note: _editedBirthday.note,
                          id: _editedBirthday.id,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['name'],
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
                      onSaved: (value) {
                        _editedBirthday = Birthday(
                          date: _editedBirthday.date,
                          name: value!,
                          note: _editedBirthday.note,
                          id: _editedBirthday.id,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['note'],
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
                      onSaved: (value) {
                        _editedBirthday = Birthday(
                          date: _editedBirthday.date,
                          name: _editedBirthday.name,
                          note: value!,
                          id: _editedBirthday.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
