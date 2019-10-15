// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Authentication on _Authentication, Store {
  Computed<bool> _$actualAuthStateComputed;

  @override
  bool get actualAuthState => (_$actualAuthStateComputed ??=
          Computed<bool>(() => super.actualAuthState))
      .value;
  Computed<String> _$actualEmailComputed;

  @override
  String get actualEmail =>
      (_$actualEmailComputed ??= Computed<String>(() => super.actualEmail))
          .value;

  final _$authStateAtom = Atom(name: '_Authentication.authState');

  @override
  ObservableFuture<bool> get authState {
    _$authStateAtom.context.enforceReadPolicy(_$authStateAtom);
    _$authStateAtom.reportObserved();
    return super.authState;
  }

  @override
  set authState(ObservableFuture<bool> value) {
    _$authStateAtom.context.conditionallyRunInAction(() {
      super.authState = value;
      _$authStateAtom.reportChanged();
    }, _$authStateAtom, name: '${_$authStateAtom.name}_set');
  }

  final _$emailAtom = Atom(name: '_Authentication.email');

  @override
  ObservableFuture<String> get email {
    _$emailAtom.context.enforceReadPolicy(_$emailAtom);
    _$emailAtom.reportObserved();
    return super.email;
  }

  @override
  set email(ObservableFuture<String> value) {
    _$emailAtom.context.conditionallyRunInAction(() {
      super.email = value;
      _$emailAtom.reportChanged();
    }, _$emailAtom, name: '${_$emailAtom.name}_set');
  }

  final _$signOutAsyncAction = AsyncAction('signOut');

  @override
  Future<bool> signOut() {
    return _$signOutAsyncAction.run(() => super.signOut());
  }

  final _$getEmailAsyncAction = AsyncAction('getEmail');

  @override
  Future<bool> getEmail() {
    return _$getEmailAsyncAction.run(() => super.getEmail());
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
