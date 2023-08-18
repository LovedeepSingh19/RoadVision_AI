import 'package:flutter/material.dart';
import '../modals/user_modal.dart';

class userProvider extends ChangeNotifier {
  User _user = User(
    uid: '',
    name: '',
    profilepic: '',
  );
  User get user => _user;

  void setUser(dynamic user) {
    _user = User.fromMap(user);
    notifyListeners();
  }
}
