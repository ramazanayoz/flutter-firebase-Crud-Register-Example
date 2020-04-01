import 'dart:async';
//import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventor/denem7/models/user.dart';
import 'package:eventor/denem7/models/settings.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class XAuth {

  //sign up kısım
  static Future<String> signUp(String email, String password) async {
    AuthResult user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return user.user.uid;
  }

  static void addUserSettingsDB(XUser user) async {  //kullanıcı firebase db kaydediliyor
    checkUserExist(user.userId).then((value) {
      if (!value) {
        print("user ${user.firstName} ${user.email} added");
        print("not auth: user.toJson(): ${user.classObjConvertToJson()}");
        Firestore.instance
            .document("users/${user.userId}")
            .setData(user.classObjConvertToJson());//alınan bilgiler json yani map formata çevrilir database eklemek için
        _addSettings(new XSettings(
          settingsId: user.userId,
        ));
      } else {
        print("user ${user.firstName} ${user.email} exists");
      }
    });
  }

  static Future<bool> checkUserExist(String userId) async {
    print("not: auth: checkUserExist fonk");
    bool exists = false;
    try {
      await Firestore.instance.document("users/$userId").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  static void _addSettings(XSettings settings) async {
    print("not: Xauth _addSettings fonc working");
    Firestore.instance
        .document("settings /${settings.settingsId}")
        .setData(settings.convertToJsonMap()); //firebase eklemek için fjson yani map formata çevriliyor
    print("not: auth:  settings.toJson(): ${settings.convertToJsonMap()}");
  }

  //sign in kısım
  static Future<String> signIn(String email, String password) async {
    AuthResult user = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);
    print("---:auth: signIn fonk ile Useruid alınıyor ${user.user.uid}");
    return user.user.uid;
  }

  static Future<XUser> getUserFirestore(String userId) async {
    //---:auth: getUserFirestore fonk çalışıyor ve  user uid ile firebase documansnapshot nesnesine ulaşılır"
    print(":auth: getUserFirestore(String userId) fonk");
    if (userId != null) {
      return Firestore.instance
          .collection('users')
          .document(userId)
          .get()
          .then((documentSnapshot) => XUser.docConvertToClassObj(documentSnapshot));  
    } else {
      print('firestore userId can not be null');
      return null;
    }
  }

  static Future<XSettings> getSettingsFirestore(String settingsId) async {
    print(":auth:  getSettingsFirestore(String settingsId) fonk");
    if (settingsId != null) {
      return Firestore.instance
          .collection('settings')
          .document(settingsId)
          .get()
          .then((documentSnapshot) => XSettings.docConvertToSettingClassObj(documentSnapshot));
    } else {
      print('no firestore settings available');
      return null;
    }
  }

    static Future<FirebaseUser> getCurrentFirebaseUser() async {
    print("not:auth: getCurrentFirebaseUser fonk");    
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    return currentUser;
  }

  //yerel belleğe store işlemleri
  static Future<String> storeUserInfoLocal(XUser user) async {
    //print(":auth: storeUserLocal(XUser user) fonk working");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeUser = classObjConvertToJsonString(user);
    //print("---:storeUser var: $storeUser");
    await prefs.setString('user', storeUser);
    return user.userId;
  }

  static Future<String> storeSettingsLocal(XSettings settings) async { //kullanıcı adı gibi bilgiler telefona yerel olarak kaydetme
    print("not:auth: storeSettingsLocal(XSettings settings) fonk");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeSettings = settingsObjectToJsonString(settings);
    print(" storeSettings var ${storeSettings}");
    await prefs.setString('settings', storeSettings);
    return settings.settingsId;
  }


  //yerel bellekten store alma
  static Future<XUser> getUserLocal() async { //tekrar kullanıcı parala kgirmesin diye depolanan yerden kullanıcı ayaralrı alma
    print("not:auth: getUserLocal fonk");    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      XUser user = stringjsonConvertToClassobj(prefs.getString('user'));
      print("not: auth :user: prefs.getString('user') ${prefs.getString('user')}");
      print('USER: $user');
      return user;
    } else {
      return null;
    }
  }

  static Future<XSettings> getSettingsLocal() async {
    print("not:auth: getSettingsLocal fonk");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('settings') != null) {
      XSettings settings = settingsFromJson(prefs.getString('settings'));
      print("auth getSettingsLocal() prefs.getString('settings') : } ${prefs.getString('settings')}");
      return settings;
    } else {
      return null;
    }
  }

  static Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    FirebaseAuth.instance.signOut();
  }

  static Future<void> forgotPasswordEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static String getExceptionText(Exception e) {
    print("not:auth: getExceptionText(Exception e) fonk");
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'User with this email address not found.';
          break;
        case 'The password is invalid or the user does not have a password.':
          return 'Invalid password.';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'No internet connection.';
          break;
        case 'The email address is already in use by another account.':
          return 'This email address already has an account.';
          break;
        default:
          return 'Unknown error occured.';
      }
    } else {
      return 'Unknown error occured.';
    }
  }

  /*static Stream<User> getUserFirestore(String userId) {
    print("...getUserFirestore...");
    if (userId != null) {
      //try firestore
      return Firestore.instance
          .collection("users")
          .where("userId", isEqualTo: userId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return User.fromDocument(doc);
        }).first;
      });
    } else {
      print('firestore user not found');
      return null;
    }
  }*/

  /*static Stream<Settings> getSettingsFirestore(String settingsId) {
    print("...getSettingsFirestore...");
    if (settingsId != null) {
      //try firestore
      return Firestore.instance
          .collection("settings")
          .where("settingsId", isEqualTo: settingsId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return Settings.fromDocument(doc);
        }).first;
      });
    } else {
      print('no firestore settings available');
      return null;
    }
  }*/
}
