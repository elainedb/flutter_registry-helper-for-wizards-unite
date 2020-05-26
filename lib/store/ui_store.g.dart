// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UiStore on _UiStore, Store {
  final _$isRegistryRowAtTopAtom = Atom(name: '_UiStore.isRegistryRowAtTop');

  @override
  bool get isRegistryRowAtTop {
    _$isRegistryRowAtTopAtom.context
        .enforceReadPolicy(_$isRegistryRowAtTopAtom);
    _$isRegistryRowAtTopAtom.reportObserved();
    return super.isRegistryRowAtTop;
  }

  @override
  set isRegistryRowAtTop(bool value) {
    _$isRegistryRowAtTopAtom.context.conditionallyRunInAction(() {
      super.isRegistryRowAtTop = value;
      _$isRegistryRowAtTopAtom.reportChanged();
    }, _$isRegistryRowAtTopAtom, name: '${_$isRegistryRowAtTopAtom.name}_set');
  }
}
