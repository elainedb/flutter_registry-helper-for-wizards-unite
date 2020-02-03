// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Authentication on _Authentication, Store {
  Computed<bool> _$isAnonymousComputed;

  @override
  bool get isAnonymous =>
      (_$isAnonymousComputed ??= Computed<bool>(() => super.isAnonymous)).value;
  Computed<String> _$userIdComputed;

  @override
  String get userId =>
      (_$userIdComputed ??= Computed<String>(() => super.userId)).value;

  final _$authStateAtom = Atom(name: '_Authentication.authState');

  @override
  bool get authState {
    _$authStateAtom.context.enforceReadPolicy(_$authStateAtom);
    _$authStateAtom.reportObserved();
    return super.authState;
  }

  @override
  set authState(bool value) {
    _$authStateAtom.context.conditionallyRunInAction(() {
      super.authState = value;
      _$authStateAtom.reportChanged();
    }, _$authStateAtom, name: '${_$authStateAtom.name}_set');
  }

  final _$emailAtom = Atom(name: '_Authentication.email');

  @override
  String get email {
    _$emailAtom.context.enforceReadPolicy(_$emailAtom);
    _$emailAtom.reportObserved();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.context.conditionallyRunInAction(() {
      super.email = value;
      _$emailAtom.reportChanged();
    }, _$emailAtom, name: '${_$emailAtom.name}_set');
  }

  final _$userAtom = Atom(name: '_Authentication.user');

  @override
  FirebaseUser get user {
    _$userAtom.context.enforceReadPolicy(_$userAtom);
    _$userAtom.reportObserved();
    return super.user;
  }

  @override
  set user(FirebaseUser value) {
    _$userAtom.context.conditionallyRunInAction(() {
      super.user = value;
      _$userAtom.reportChanged();
    }, _$userAtom, name: '${_$userAtom.name}_set');
  }

  final _$signOutAsyncAction = AsyncAction('signOut');

  @override
  Future signOut() {
    return _$signOutAsyncAction.run(() => super.signOut());
  }

  final _$getEmailAsyncAction = AsyncAction('getEmail');

  @override
  Future getEmail() {
    return _$getEmailAsyncAction.run(() => super.getEmail());
  }

  final _$signInWithGoogleAsyncAction = AsyncAction('signInWithGoogle');

  @override
  Future signInWithGoogle() {
    return _$signInWithGoogleAsyncAction.run(() => super.signInWithGoogle());
  }

  final _$signInWithAppleAsyncAction = AsyncAction('signInWithApple');

  @override
  Future signInWithApple() {
    return _$signInWithAppleAsyncAction.run(() => super.signInWithApple());
  }

  final _$signInAnonymousAsyncAction = AsyncAction('signInAnonymous');

  @override
  Future signInAnonymous() {
    return _$signInAnonymousAsyncAction.run(() => super.signInAnonymous());
  }

  final _$initAuthStateAsyncAction = AsyncAction('initAuthState');

  @override
  Future initAuthState() {
    return _$initAuthStateAsyncAction.run(() => super.initAuthState());
  }

  final _$_AuthenticationActionController =
      ActionController(name: '_Authentication');

  @override
  void setAuthState(dynamic newState) {
    final _$actionInfo = _$_AuthenticationActionController.startAction();
    try {
      return super.setAuthState(newState);
    } finally {
      _$_AuthenticationActionController.endAction(_$actionInfo);
    }
  }
}
