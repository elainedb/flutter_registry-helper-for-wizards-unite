// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signin_image.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SignInImage on _SignInImage, Store {
  Computed<ui.Image> _$actualImageComputed;

  @override
  ui.Image get actualImage =>
      (_$actualImageComputed ??= Computed<ui.Image>(() => super.actualImage))
          .value;

  final _$imageAtom = Atom(name: '_SignInImage.image');

  @override
  ObservableFuture<ui.Image> get image {
    _$imageAtom.context.enforceReadPolicy(_$imageAtom);
    _$imageAtom.reportObserved();
    return super.image;
  }

  @override
  set image(ObservableFuture<ui.Image> value) {
    _$imageAtom.context.conditionallyRunInAction(() {
      super.image = value;
      _$imageAtom.reportChanged();
    }, _$imageAtom, name: '${_$imageAtom.name}_set');
  }

  final _$loadImageAsyncAction = AsyncAction('loadImage');

  @override
  Future<bool> loadImage() {
    return _$loadImageAsyncAction.run(() => super.loadImage());
  }
}
