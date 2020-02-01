import 'dart:convert';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobx/mobx.dart';
import 'package:registry_helper_for_wu/utils/fanalytics.dart';

part 'authentication.g.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class Authentication = _Authentication with _$Authentication;

abstract class _Authentication with Store {

  @observable
  bool authState = false;

  @observable
  String email = "";

  @observable
  FirebaseUser user;

  @action
  void setAuthState(dynamic newState) {
    authState = newState;
  }

  @computed
  bool get isAnonymous => user != null ? user.isAnonymous : false;

  @computed
  String get userId => user != null ? user.uid : "";

  @action
  signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    authState = false;
  }

  @action
  getEmail() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      email = "Anonymous";
    } else {
      email = user.email;
    }
  }

  @action
  signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await getGoogleUser();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    AuthResult authResult = await _auth.signInWithCredential(credential);
    user = authResult.user;
    authState = user != null;
  }

  @action
  signInWithApple() async {
    const Utf8Codec utf8 = Utf8Codec();

    final AuthorizationResult result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (result.status) {
      case AuthorizationStatus.authorized:
        final AuthCredential credential = OAuthProvider(providerId: "apple.com").getCredential(
             idToken: utf8.decode(result.credential.identityToken),
             accessToken: utf8.decode(result.credential.authorizationCode));
        AuthResult authResult = await _auth.signInWithCredential(credential);
        user = authResult.user;
        authState = user != null;
        break;

      case AuthorizationStatus.error:
        print("Sign in failed: ${result.error.localizedDescription}");
        break;

      case AuthorizationStatus.cancelled:
        print('User cancelled');
        break;
    }
  }

  @action
  signInAnonymous() async {
    await _auth.signInAnonymously();
    authState = true;
  }

  @action
  initAuthState() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    authState = firebaseUser != null;
    user = firebaseUser;
  }

  @action
  sendUserId() async {
    await FAnalytics.analytics.setUserId(userId);
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