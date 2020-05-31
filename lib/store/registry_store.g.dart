// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registry_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RegistryStore on _RegistryStore, Store {
  Computed<bool> _$isLoadingComputed;

  @override
  bool get isLoading =>
      (_$isLoadingComputed ??= Computed<bool>(() => super.isLoading)).value;

  final _$registryAtom = Atom(name: '_RegistryStore.registry');

  @override
  Registry get registry {
    _$registryAtom.context.enforceReadPolicy(_$registryAtom);
    _$registryAtom.reportObserved();
    return super.registry;
  }

  @override
  set registry(Registry value) {
    _$registryAtom.context.conditionallyRunInAction(() {
      super.registry = value;
      _$registryAtom.reportChanged();
    }, _$registryAtom, name: '${_$registryAtom.name}_set');
  }

  final _$isRegistryLoadingAtom =
      Atom(name: '_RegistryStore.isRegistryLoading');

  @override
  bool get isRegistryLoading {
    _$isRegistryLoadingAtom.context.enforceReadPolicy(_$isRegistryLoadingAtom);
    _$isRegistryLoadingAtom.reportObserved();
    return super.isRegistryLoading;
  }

  @override
  set isRegistryLoading(bool value) {
    _$isRegistryLoadingAtom.context.conditionallyRunInAction(() {
      super.isRegistryLoading = value;
      _$isRegistryLoadingAtom.reportChanged();
    }, _$isRegistryLoadingAtom, name: '${_$isRegistryLoadingAtom.name}_set');
  }

  final _$isUserDataLoadingAtom =
      Atom(name: '_RegistryStore.isUserDataLoading');

  @override
  bool get isUserDataLoading {
    _$isUserDataLoadingAtom.context.enforceReadPolicy(_$isUserDataLoadingAtom);
    _$isUserDataLoadingAtom.reportObserved();
    return super.isUserDataLoading;
  }

  @override
  set isUserDataLoading(bool value) {
    _$isUserDataLoadingAtom.context.conditionallyRunInAction(() {
      super.isUserDataLoading = value;
      _$isUserDataLoadingAtom.reportChanged();
    }, _$isUserDataLoadingAtom, name: '${_$isUserDataLoadingAtom.name}_set');
  }

  final _$widgetOptionsAtom = Atom(name: '_RegistryStore.widgetOptions');

  @override
  List<Widget> get explorationWidgetOptions {
    _$widgetOptionsAtom.context.enforceReadPolicy(_$widgetOptionsAtom);
    _$widgetOptionsAtom.reportObserved();
    return super.explorationWidgetOptions;
  }

  @override
  set explorationWidgetOptions(List<Widget> value) {
    _$widgetOptionsAtom.context.conditionallyRunInAction(() {
      super.explorationWidgetOptions = value;
      _$widgetOptionsAtom.reportChanged();
    }, _$widgetOptionsAtom, name: '${_$widgetOptionsAtom.name}_set');
  }

  final _$initRegistryDataFromJsonAsyncAction =
      AsyncAction('initRegistryDataFromJson');

  @override
  Future initRegistryDataFromJson() {
    return _$initRegistryDataFromJsonAsyncAction
        .run(() => super.initRegistryDataFromJson());
  }

  final _$getRegistryFromSharedPrefsAsyncAction =
      AsyncAction('getRegistryFromSharedPrefs');

  @override
  Future getRegistryFromSharedPrefs() {
    return _$getRegistryFromSharedPrefsAsyncAction
        .run(() => super.getRegistryFromSharedPrefs());
  }

  final _$_RegistryStoreActionController =
      ActionController(name: '_RegistryStore');

  @override
  dynamic updateExplorationWidgets(String sortValue) {
    final _$actionInfo = _$_RegistryStoreActionController.startAction();
    try {
      return super.updateExplorationWidgets(sortValue);
    } finally {
      _$_RegistryStoreActionController.endAction(_$actionInfo);
    }
  }
}
