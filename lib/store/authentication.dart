import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobx/mobx.dart';

part 'authentication.g.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class Authentication = _Authentication with _$Authentication;

abstract class _Authentication with Store {

  @observable
  ObservableFuture<bool> authState = ObservableFuture<bool>.value(false);

  @observable
  ObservableFuture<String> email = ObservableFuture<String>.value("");

  @action
  void setAuthState(dynamic newState) {
    authState = newState;
  }

  @computed
  bool get actualAuthState => authState.value;

  @computed
  String get actualEmail => email.value;

  @action
  Future<bool> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    authState = ObservableFuture.value(false);
    return await Future.value(true);
  }

  @action
  Future<bool> getEmail() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      email = ObservableFuture.value("Anonymous");
    } else {
      email = ObservableFuture.value(user.email);
    }
    return await Future.value(true);
  }

}