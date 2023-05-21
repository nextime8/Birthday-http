import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:fluttertoast/fluttertoast.dart';

import '../models/http_exceptions.dart';
import 'birthday.dart';

class Birthdays with ChangeNotifier {
  List<Birthday> _birthdays = [];

  List<Birthday> get birthdays {
    return [..._birthdays];
  }

  Birthday findById(String id) {
    return _birthdays.firstWhere((bir) => bir.id == id);
  }

  Future<void> fetchAndSetBirthdays() async {
    final url = Uri.https(
      'birthday-management-app-default-rtdb.europewest1.firebasedatabase.app',
      '/users/IKiqwP26GdZF7RzcSNHe0Rdq9o42/birthdays.json',
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      final List<Birthday> loadedBirthdays = [];
      extractedData.forEach((userId, userData) {
        final birthdaysData = userData['birthdays'] as Map<String, dynamic>;
        birthdaysData.forEach((birthdayId, birthdayData) {
          loadedBirthdays.add(Birthday(
            id: birthdayId,
            date: DateTime.parse(birthdayData['date']),
            name: birthdayData['name'],
            note: birthdayData['note'],
          ));
        });
      });

      _birthdays = loadedBirthdays;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addBirthday(Birthday birthday) async {
    final url = Uri.parse(
      'https://birthday-management-app-default-rtdb.europewest1.firebasedatabase.app'
      '/users/IKiqwP26GdZF7RzcSNHe0Rdq9o42/birthdays.json',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'date': birthday.date.toIso8601String(),
          'name': birthday.name,
          'note': birthday.note,
        }),
      );

      final newBirthdayId = json.decode(response.body)['name'];

      final newBirthday = Birthday(
        id: newBirthdayId,
        name: birthday.name,
        date: birthday.date,
        note: birthday.note,
      );

      _birthdays.add(newBirthday);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateBirthday(String birthdayId, Birthday newBirthday) async {
    final bdayIndex = _birthdays.indexWhere((bday) => bday.id == birthdayId);
    if (bdayIndex >= 0) {
      final url = Uri.https(
        'birthday-management-app-default-rtdb.europewest1.firebasedatabase.app',
        '/users/IKiqwP26GdZF7RzcSNHe0Rdq9o42/birthdays/$birthdayId.json',
      );
      try {
        await http.patch(
          url,
          body: json.encode({
            'date': newBirthday.date.toIso8601String(),
            'name': newBirthday.name,
            'note': newBirthday.note,
          }),
        );
        _birthdays[bdayIndex] = newBirthday;
        notifyListeners();
      } catch (error) {
        print(error);
        throw error;
      }
    } else {
      print('...');
    }
  }

  Future<void> deleteBirthday(String id) async {
    final url = Uri.https(
      'birthday-management-app-default-rtdb.europewest1.firebasedatabase.app',
      '/users/IKiqwP26GdZF7RzcSNHe0Rdq9o42/birthdays/$id.json',
    );
    final existingBirthdayIndex =
        _birthdays.indexWhere((birthday) => birthday.id == id);
    Birthday? existingBirthday = _birthdays[existingBirthdayIndex];
    _birthdays.removeAt(existingBirthdayIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _birthdays.insert(existingBirthdayIndex, existingBirthday);
      notifyListeners();
      throw HttpException('Could not delete birthday.');
    }
    existingBirthday = null;
  }
}
