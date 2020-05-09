// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserDataStore on _UserDataStore, Store {
  final _$isLoadingAtom = Atom(name: '_UserDataStore.isLoading');

  @override
  bool get isLoading {
    _$isLoadingAtom.context.enforceReadPolicy(_$isLoadingAtom);
    _$isLoadingAtom.reportObserved();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.context.conditionallyRunInAction(() {
      super.isLoading = value;
      _$isLoadingAtom.reportChanged();
    }, _$isLoadingAtom, name: '${_$isLoadingAtom.name}_set');
  }

  final _$dataAtom = Atom(name: '_UserDataStore.data');

  @override
  Map<String, dynamic> get data {
    _$dataAtom.context.enforceReadPolicy(_$dataAtom);
    _$dataAtom.reportObserved();
    return super.data;
  }

  @override
  set data(Map<String, dynamic> value) {
    _$dataAtom.context.conditionallyRunInAction(() {
      super.data = value;
      _$dataAtom.reportChanged();
    }, _$dataAtom, name: '${_$dataAtom.name}_set');
  }

  final _$setPrestigeLevelAsyncAction = AsyncAction('setPrestigeLevel');

  @override
  Future setPrestigeLevel(WUPage page, String newValue) {
    return _$setPrestigeLevelAsyncAction
        .run(() => super.setPrestigeLevel(page, newValue));
  }

  final _$submitNewValueAsyncAction = AsyncAction('submitNewValue');

  @override
  Future submitNewValue(Foundable foundable, String newValue) {
    return _$submitNewValueAsyncAction
        .run(() => super.submitNewValue(foundable, newValue));
  }

  final _$_UserDataStoreActionController =
      ActionController(name: '_UserDataStore');

  @override
  dynamic initData() {
    final _$actionInfo = _$_UserDataStoreActionController.startAction();
    try {
      return super.initData();
    } finally {
      _$_UserDataStoreActionController.endAction(_$actionInfo);
    }
  }
}
