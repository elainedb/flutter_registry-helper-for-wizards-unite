import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';

part 'signin_image.g.dart';

class SignInImage = _SignInImage with _$SignInImage;

abstract class _SignInImage with Store {
  @observable
  ui.Image image;

  @action
  loadImage() async {
    image = await load("assets/images/background.jpg");
  }

  Future<ui.Image> load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }
}
