import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data.dart';
import '../pages/charts.dart';
import '../pages/helper.dart';
import '../pages/my_registry.dart';
import '../pages/settings.dart';
import 'authentication.dart';

part 'registry_store.g.dart';

class RegistryStore = _RegistryStore with _$RegistryStore;

abstract class _RegistryStore with Store {
  final authentication = GetIt.instance<Authentication>();

  @observable
  Registry registry;

  @observable
  bool isRegistryLoading = false;

  @observable
  bool isUserDataLoading = false;

  @observable
  List<Widget> widgetOptions = <Widget>[
    Text('Loading'),
    Text('Loading'),
    Text('Loading'),
    Text('Loading'),
  ];

  @computed
  bool get isLoading => isRegistryLoading || isUserDataLoading;

  @action
  initRegistryDataFromJson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isRegistryLoading = true;

    var registryString = await rootBundle.loadString('assets/json/registry.json');
    await prefs.setString('registry', registryString);
    Map registryMap = jsonDecode(registryString);
    registry = Registry.fromJson(registryMap) ?? null;
    isRegistryLoading = false;

    await _initUserData(authentication.userId, prefs);
  }

  @action
  getRegistryFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var registryString = prefs.getString('registry') ?? "";
    if (registryString.isNotEmpty) {
      Map registryMap = jsonDecode(registryString);
      registry = Registry.fromJson(registryMap) ?? null;
    }
  }

  @action
  updateWidgets(String sortValue) {
    widgetOptions = <Widget>[
      MyRegistryPage(),
      HelperPage(sortValue),
      ChartsPage(),
      SettingsPage(),
    ];
  }

  _initUserData(String userId, SharedPreferences prefs) async {
    isUserDataLoading = true;
    var registryIds = getAllFoundablesIds(registry);

    if (!authentication.isAnonymous) {
      var snapshot = await Firestore.instance.collection('userData').document(userId).get();

      if (!snapshot.exists) {
        _addUserDataConnected(registryIds, userId);
      } else {
        _checkAndAddNewUserKeysConnected(snapshot, registryIds, userId);
        isUserDataLoading = false;
      }
    } else {
      var snapshot = await Firestore.instance.collection('userData').document(userId).get();

      if (!snapshot.exists) {
        var userDataString = prefs.getString('userData');
        if (userDataString == null) {
          _initAnonymousData(registryIds);
        } else {
          _checkAndAddNewUserKeysAnonymous(userDataString, registryIds);
          isUserDataLoading = false;
        }
      } else {
        _migrateAnonymous(snapshot.data, userId);
      }
    }
  }

  _checkAndAddNewUserKeysConnected(DocumentSnapshot snapshot, List<String> registryIds, String userId) {
    var userIds = List<String>();
    var toAddIds = List<String>();
    snapshot.data.forEach((id, value) {
      userIds.add(id);
    });

    registryIds.forEach((registryId) {
      if (!userIds.contains(registryId)) {
        toAddIds.add(registryId);
      }
    });

    if (toAddIds.isNotEmpty) {
      _addUserDataConnected(toAddIds, userId);
    } else {
      isUserDataLoading = false;
    }
  }

  _addUserDataConnected(List<String> ids, String userId) {
    Map<String, dynamic> map = Map();

    for (var id in ids) {
      map[id] = {'count': 0, 'level': 1};
    }

    Firestore.instance.collection('userData').document(userId).setData(map, merge: true).then((_) {
      isUserDataLoading = false;
    });
  }

  _checkAndAddNewUserKeysAnonymous(String userDataString, List<String> registryIds) {
    var userIds = List<String>();
    var toAddIds = List<String>();

    Map map = jsonDecode(userDataString);
    UserData oldUserData = UserData.fromJson(map);

    oldUserData.fragmentDataList.forEach((id, value) {
      userIds.add(id);
    });

    registryIds.forEach((registryId) {
      if (!userIds.contains(registryId)) {
        toAddIds.add(registryId);
      }
    });

    if (toAddIds.isNotEmpty) {
      _addUserDataAnonymous(toAddIds, oldUserData);
    } else {
      isUserDataLoading = false;
    }
  }

  _migrateAnonymous(Map<String, dynamic> data, String userId) async {
    // TODO temp code -> delete when all anonymous were migrated
    saveUserDataToPrefs(UserData(data)).then((value) {
      Firestore.instance.collection('userData').document(userId).delete();
      isUserDataLoading = false;
    });
  }

  _initAnonymousData(List<String> ids) async {
    Map<String, dynamic> map = Map();
    for (var id in ids) {
      map[id] = {'count': 0, 'level': 1};
    }

    await saveUserDataToPrefs(UserData(map));
    isUserDataLoading = false;
  }

  _addUserDataAnonymous(List<String> newIds, UserData oldUserData) {
    Map<String, dynamic> map = oldUserData.fragmentDataList;
    for (var id in newIds) {
      map[id] = {'count': 0, 'level': 1};
    }

    saveUserDataToPrefs(UserData(map)).then((value) {
      isUserDataLoading = false;
    });
  }
}
