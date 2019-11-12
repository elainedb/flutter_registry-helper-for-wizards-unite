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

  @observable
  ObservableFuture<FirebaseUser> user = ObservableFuture<FirebaseUser>.value(null);

  @action
  void setAuthState(dynamic newState) {
    authState = newState;
  }

  @computed
  bool get actualAuthState => authState.value;

  @computed
  String get actualEmail => email.value;

  @computed
  FirebaseUser get actualUser => user.value;

  @computed
  bool get isAnonymous => user.value != null ? user.value.isAnonymous : false;

  @computed
  String get userId => user.value != null ? user.value.uid : "";

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

  @action
  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await getGoogleUser();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser user = await _auth.signInWithCredential(credential);
    authState = ObservableFuture.value(user.uid != null);

    return await Future.value(true);
  }

  @action
  Future<bool> signInAnonymous() async {
    await _auth.signInAnonymously();
    authState = ObservableFuture.value(true);
    return await Future.value(true);
  }

  @action
  Future<bool> initAuthState() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    authState = ObservableFuture.value(firebaseUser != null);
    user = ObservableFuture.value(firebaseUser);
    return await Future.value(true);
  }

  Future getGoogleUser() async {
    GoogleSignInAccount googleUser = _googleSignIn.currentUser;
    if (googleUser == null) {
      googleUser = await _googleSignIn.signInSilently();
    }
    if (googleUser == null) {
      googleUser = await _googleSignIn.signIn();
    }

    return googleUser;
  }

}