import 'package:mobx/mobx.dart';

part 'ui_store.g.dart';

class UiStore = _UiStore with _$UiStore;

abstract class _UiStore with Store {
  @observable
  bool isMainChildAtTop = false;
}
