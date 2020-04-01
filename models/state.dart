import 'package:firebase_auth/firebase_auth.dart';
import 'user.dart';
import 'settings.dart';

class XStateModel {
  bool isLoading;
  FirebaseUser firebaseUserAuth;
  XUser user;
  XSettings settings;

  XStateModel({
    this.isLoading = false,
    this.firebaseUserAuth,
    this.user,
    this.settings,
  });
}
 