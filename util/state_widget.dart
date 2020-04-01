import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventor/denem7/models/state.dart';
import 'package:eventor/denem7/models/user.dart';
import 'package:eventor/denem7/models/settings.dart';
import 'package:eventor/denem7/util/auth.dart';

class XStateWidget extends StatefulWidget {
  final XStateModel state;
  final Widget child;

  XStateWidget({  //constructur
    @required this.child,
    this.state,
  });

  // Returns data of the nearest widget _StateDataWidget
  // in the widget tree.
  static _XStateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .data;
  }

  @override
  _XStateWidgetState createState() => new _XStateWidgetState();
}

class _XStateWidgetState extends State<XStateWidget> {
  XStateModel state;
  //GoogleSignInAccount googleAccount;
  //final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
    print('not:XStateWidget da...initState... working');
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new XStateModel(isLoading: true);
      initUser();
    }
  }

  Future<Null> initUser() async {
    print('not:XStateWidget da...initUser... working');
    FirebaseUser firebaseUserAuth = await XAuth.getCurrentFirebaseUser(); //şuanki kullanıcıya ulaş
    XUser user = await XAuth.getUserLocal(); //telefona kaydedilmiş giriş bilgisi alınıyot
    XSettings settings = await XAuth.getSettingsLocal(); //yerel ayarları al
    setState(() {
      state.isLoading = false;
      state.firebaseUserAuth = firebaseUserAuth;
      state.user = user;
      state.settings = settings;
    });
  }

  Future<void> logOutUser() async {
    print("not:XStateWidget da logOutUser running");
    await XAuth.signOut(); 
    FirebaseUser firebaseUserAuth = await XAuth.getCurrentFirebaseUser(); // signout yaptık ve şuanki null olan kullanıcıyı aldık
    print("not:state:logOutUser() fonc firebaseUserAuth  ${firebaseUserAuth} ");
    setState(() {
      state.user = null;
      state.settings = null;
      state.firebaseUserAuth = firebaseUserAuth; //firebaseUserAuth null olarak ayrlandı 
         
    });
  }

  Future<void> logInUser(email, password) async { //
    print(" XStateWidget da logInUser fonct working");
    String userId = await XAuth.signIn(email, password); 
    XUser user = await XAuth.getUserFirestore(userId); //XUser nesnesi oluşturuluyor firebaseden alınan verilerle
    await XAuth.storeUserInfoLocal(user); //user bilgileri string olarak telefolna depolanır
    XSettings settings = await XAuth.getSettingsFirestore(userId);
    await XAuth.storeSettingsLocal(settings);
    await initUser();
  }

  @override
  Widget build(BuildContext context) {
    return new _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _XStateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of _StateDataWidget:
  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
