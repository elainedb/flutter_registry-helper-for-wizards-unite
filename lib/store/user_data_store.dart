import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

import '../data/data.dart';
import 'authentication.dart';

part 'user_data_store.g.dart';

class UserDataStore = _UserDataStore with _$UserDataStore;

abstract class _UserDataStore with Store {
  final authentication = GetIt.instance<Authentication>();

  @observable
  bool isLoading = true;

  @observable
  Map<String, dynamic> data;

  @action
  initData() {
    if (authentication.isAnonymous) {
      getUserDataFromPrefs().then((d) {
        data = d.fragmentDataList;
        isLoading = false;
      });
    } else {
      Firestore.instance.collection('userData').document(authentication.userId).snapshots().listen((snapshot) {
        data = snapshot.data;
        isLoading = false;
      });
    }
  }

  @action
  setPrestigeLevel(Page page, String newValue) async {
    Map<String, dynamic> newData = Map();
    page.foundables.forEach((foundable) {
      data[foundable.id]['count'] = 0;
      data[foundable.id]['level'] = getPrestigeLevelWithPrestigeValue(newValue);

      if (!authentication.isAnonymous) {
        newData[foundable.id] = {'count': 0, 'level': getPrestigeLevelWithPrestigeValue(newValue)};
      }
    });

    if (!authentication.isAnonymous) {
      Firestore.instance.collection('userData').document(authentication.userId).setData(newData, merge: true);
    } else {
      await saveUserDataToPrefs(UserData(data));
      getUserDataFromPrefs().then((d) {
        data = d.fragmentDataList;
      });
    }
  }

  @action
  submitNewValue(Foundable foundable, String newValue, int requirement) async {
    var newInt = int.tryParse(newValue) ?? 0;
    data[foundable.id]['count'] = newInt;

    if (!authentication.isAnonymous) {
      Firestore.instance.collection('userData').document(authentication.userId).setData({
        foundable.id: {'count': newInt}
      }, merge: true);
    } else {
      await saveUserDataToPrefs(UserData(data));
      getUserDataFromPrefs().then((d) {
        data = d.fragmentDataList;
      });
    }
  }

  Future<void> submitNewPage(Map<String, double> foundableCount) async {
    Map<String, dynamic> newData = Map();
    foundableCount.forEach((id, count) {
      newData[id] = {'count': count.truncate()};
    });

    if (!authentication.isAnonymous) {
      Firestore.instance.collection('userData').document(authentication.userId).setData(newData, merge: true);
    } else {
      foundableCount.forEach((id, count) {
        data[id]['count'] = count.truncate();
      });

      await saveUserDataToPrefs(UserData(data));
      getUserDataFromPrefs().then((d) {
        data = d.fragmentDataList;
      });
    }

    return Future.value(0);
  }
}