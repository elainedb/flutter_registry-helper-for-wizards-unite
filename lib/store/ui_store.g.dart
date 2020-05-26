// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UiStore on _UiStore, Store {
  final _$isMainChildAtTopAtom = Atom(name: '_UiStore.isMainChildAtTop');

  @override
  bool get isMainChildAtTop {
    _$isMainChildAtTopAtom.context.enforceReadPolicy(_$isMainChildAtTopAtom);
    _$isMainChildAtTopAtom.reportObserved();
    return super.isMainChildAtTop;
  }

  @override
  set isMainChildAtTop(bool value) {
    _$isMainChildAtTopAtom.context.conditionallyRunInAction(() {
      super.isMainChildAtTop = value;
      _$isMainChildAtTopAtom.reportChanged();
    }, _$isMainChildAtTopAtom, name: '${_$isMainChildAtTopAtom.name}_set');
  }
}
