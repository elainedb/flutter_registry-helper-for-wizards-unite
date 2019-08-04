import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/pages/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bottom_bar_nav.dart';

const prestigeValues = ['Standard', 'Bronze', 'Silver', 'Gold'];
const sortValues = ['Default', 'Low/Medium (no beam)', 'High (yellow beam)', 'Severe (orange beam)', 'Emergency (red beam)', 'Wizarding Challenges rewards'];
var chaptersForDisplay = [
  ChapterForDisplay("cmc", cmcDark, cmcLight),
  ChapterForDisplay("da", daDark, daLight),
  ChapterForDisplay("hs", hsDark, hsLight),
  ChapterForDisplay("loh", lohDark, lohLight),
  ChapterForDisplay("mom", momDark, momLight),
  ChapterForDisplay("m", mDark, mLight),
  ChapterForDisplay("mgs", mgsDark, mgsLight),
  ChapterForDisplay("ma", maDark, maLight),
  ChapterForDisplay("www", wwwDark, wwwLight),
  ChapterForDisplay("o", oDark, oLight),
];

class Registry {
  final List<Chapter> chapters;

  Registry(this.chapters);

  factory Registry.fromJson(Map<String, dynamic> json) {
    var list = json['chapters'] as List;
    List<Chapter> chaptersList = list.map((i) => Chapter.fromJson(i)).toList();

    return Registry(
      chaptersList,
    );
  }

  Map<String, dynamic> toJson() => {
        'chapters': chapters,
      };
}

class Chapter {
  final String id;
  final String name;
  final String osm;
  final String examples;
  final List<Page> pages;

  Chapter(this.id, this.name, this.osm, this.examples, this.pages);

  factory Chapter.fromJson(Map<String, dynamic> json) {
    var list = json['pages'] as List;
    List<Page> pagesList = list.map((i) => Page.fromJson(i)).toList();

    return Chapter(
      json['id'],
      json['name'],
      json['osm'],
      json['examples'],
      pagesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'osm': osm,
        'examples': examples,
        'pages': pages,
      };
}

class Page {
  final String id;
  final String name;
  final List<Foundable> foundables;

  Page(this.id, this.name, this.foundables);

  factory Page.fromJson(Map<String, dynamic> json) {
    var list = json['foundables'] as List;
    List<Foundable> foundablesList = list.map((i) => Foundable.fromJson(i)).toList();

    return Page(
      json['id'],
      json['name'],
      foundablesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'foundables': foundables,
      };
}

class Foundable {
  final String id;
  final String name;
  final int fragmentRequirementStandard;
  final int fragmentRequirementBronze;
  final int fragmentRequirementSilver;
  final int fragmentRequirementGold;
  final String howToCatch;
  final String threatLevel;

  Foundable(this.id, this.name, this.fragmentRequirementStandard, this.fragmentRequirementBronze, this.fragmentRequirementSilver, this.fragmentRequirementGold, this.howToCatch, this.threatLevel);

  Foundable.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        fragmentRequirementStandard = json['fragmentRequirementStandard'],
        fragmentRequirementBronze = json['fragmentRequirementBronze'],
        fragmentRequirementSilver = json['fragmentRequirementSilver'],
        fragmentRequirementGold = json['fragmentRequirementGold'],
        howToCatch = json['howToCatch'],
        threatLevel = json['threatLevel'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fragmentRequirementStandard': fragmentRequirementStandard,
        'fragmentRequirementBronze': fragmentRequirementBronze,
        'fragmentRequirementSilver': fragmentRequirementSilver,
        'fragmentRequirementGold': fragmentRequirementGold,
        'howToCatch': howToCatch,
        'threatLevel': threatLevel,
      };
}

Chapter getChapterWithId(Registry registry, String id) {
  Chapter chapter;
  registry.chapters.forEach((c) {
    if (c.id == id) {
      chapter = c;
    }
  });

  return chapter;
}

List<String> getPagesIds(Chapter chapter) {
  return chapter.pages.map((p) => p.id).toList();
}

Page getPageWithId(Chapter chapter, String id) {
  Page page;
  chapter.pages.forEach((p) {
    if (p.id == id) {
      page = p;
    }
  });

  return page;
}

List<String> getFoundablesIds(Page page) {
  return page.foundables.map((f) => f.id).toList();
}

Foundable getFoundableWithId(Page page, String id) {
  Foundable foundable;
  page.foundables.forEach((f) {
    if (f.id == id) {
      foundable = f;
    }
  });

  return foundable;
}

List<String> getAllFoundablesIds(Registry registry) {
  List<String> ids = List();
  registry.chapters.forEach((chapter) {
    chapter.pages.forEach((page) {
      ids.addAll(getFoundablesIds(page));
    });
  });
  return ids;
}

String getPrestigeLevelWithPageId(String pageId, Map<String, dynamic> data) {
  switch (data["${pageId}_1"]["level"]) {
    case 1:
      return prestigeValues[0];
    case 2:
      return prestigeValues[1];
    case 3:
      return prestigeValues[2];
    case 4:
      return prestigeValues[3];
  }
  return prestigeValues[0];
}

int getPrestigeLevelWithPrestigeValue(String value) {
  switch (value) {
    case 'Standard':
      return 1;
    case 'Bronze':
      return 2;
    case 'Silver':
      return 3;
    case 'Gold':
      return 4;
  }
  return 1;
}

String getFragmentRequirement(Foundable foundable, String dropdownValue) {
  switch (dropdownValue) {
    case 'Standard':
      return "/${foundable.fragmentRequirementStandard}";
    case 'Bronze':
      return "/${foundable.fragmentRequirementBronze}";
    case 'Silver':
      return "/${foundable.fragmentRequirementSilver}";
    case 'Gold':
      return "/${foundable.fragmentRequirementGold}";
  }
  return "/${foundable.fragmentRequirementStandard}";
}

int getRequirementWithLevel(Foundable foundable, int level) {
  switch (level) {
    case 1:
      return foundable.fragmentRequirementStandard;
    case 2:
      return foundable.fragmentRequirementBronze;
    case 3:
      return foundable.fragmentRequirementSilver;
    case 4:
      return foundable.fragmentRequirementGold;
  }
  return foundable.fragmentRequirementStandard;
}

Color getColorWithFoundable(Foundable foundable) {
  switch (foundable.threatLevel) {
    case "l":
      return Colors.grey;
    case "m":
      return Colors.white;
    case "h":
      return Colors.yellow;
    case "s":
      return Colors.orange;
    case "e":
      return Colors.red;
  }
  return Colors.white;
}

Icon getIconWithFoundable(Foundable foundable, double size) {
  IconData id = Icons.not_interested;
  switch (foundable.howToCatch) {
    case "p":
      id  = Icons.vpn_key;
      break;
    case "pw":
//      id = Icons.filter_2;
      id = Icons.vpn_key;
      break;
    case "w":
      id = Icons.pets;
      break;
    case "wc":
      id = Icons.flash_on;
      break;
  }

  return Icon(id, color: getColorWithFoundable(foundable), size: size,);
}

MissingTraces getMissingTracesForChapter(Chapter chapter, Map<String, dynamic> data) {
  var low = 0;
  var medium = 0;
  var high = 0;
  var severe = 0;
  var emergency = 0;
  var challenges = 0;

  chapter.pages.forEach((page) {
    page.foundables.forEach((foundable) {
      var level = data[foundable.id]["level"];
      var total = getRequirementWithLevel(foundable, level);
      var returned = data[foundable.id]["count"];
      var remainder = total - returned;

      if (foundable.howToCatch == "wc") {
        challenges += remainder;
      } else if (foundable.howToCatch == "w" || foundable.howToCatch == "pw") {
        switch (foundable.threatLevel) {
          case "l":
            low += remainder;
            break;
          case "m":
            medium += remainder;
            break;
          case "h":
            high += remainder;
            break;
          case "s":
            severe += remainder;
            break;
          case "e":
            emergency += remainder;
            break;
        }
      }
    });
  });

  return MissingTraces(low, medium, high, severe, emergency, challenges);
}

List<AlmostCompletePage> getPagesWithOneOreTwoMissing(Chapter chapter, Map<String, dynamic> data) {
  List<AlmostCompletePage> almostCompletePages = List();

  chapter.pages.forEach((page) {
    List<IncompleteFoundable> incompleteFoundables = List();

    page.foundables.forEach((foundable) {
      var level = data[foundable.id]["level"];
      var total = getRequirementWithLevel(foundable, level);
      var returned = data[foundable.id]["count"];
      var remainder = total - returned;
      if (remainder > 0) {
        incompleteFoundables.add(IncompleteFoundable(chapter.id, foundable, remainder));
      }
    });

    if (incompleteFoundables.length < 3 && incompleteFoundables.length > 0) {
      almostCompletePages.add(AlmostCompletePage(page.name, incompleteFoundables));
    }
  });

  return almostCompletePages;
}

class ChapterForDisplay {
  final String id;
  final Color darkColor;
  final Color lightColor;

  ChapterForDisplay(this.id, this.darkColor, this.lightColor);
}

class AlmostCompletePage {
  final String pageName;
  final List<IncompleteFoundable> foundables;
  
  AlmostCompletePage(this.pageName, this.foundables);
}

class IncompleteFoundable {
  final String chapterId;
  final Foundable foundable;
  final int remainingFragments;
  
  IncompleteFoundable(this.chapterId, this.foundable, this.remainingFragments);
}

// ---------- USER DATA

class UserData {
  final Map<String, dynamic> fragmentDataList;

  UserData(this.fragmentDataList);

  factory UserData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> map = Map();
    var jsonData = json['fragmentDataList'] as Map<String, dynamic>;
    jsonData.forEach((id, data) {
      map[id] = data;
    });

    return UserData(
      map,
    );
  }

  Map<String, dynamic> toJson() => {
    'fragmentDataList': fragmentDataList,
  };
}

// TODO move this elsewhere?
Future<UserData> getUserDataFromPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userDataString = prefs.getString('userData');
  Map map = jsonDecode(userDataString);
  return UserData.fromJson(map);
}

Future<void> saveUserDataToPrefs(UserData userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userData', jsonEncode(userData));
}