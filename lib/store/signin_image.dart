import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';

part 'signin_image.g.dart';

class SignInImage = _SignInImage with _$SignInImage;

abstract class _SignInImage with Store {

  @observable
  ObservableFuture<ui.Image> image = ObservableFuture<ui.Image>.value(null);

  @computed
  ui.Image get actualImage => image.value;

  @action
  Future<bool> loadImage() async {
    ui.Image img = await load("assets/images/background.jpg");

    image = ObservableFuture.value(img);

    return await Future.value(true);
  }

  Future<ui.Image> load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

}