import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/helper.dart';
import '../resources/values/app_colors.dart';
import '../resources/i18n/app_strings.dart';

const prestigeValues = ['prestige_standard', 'prestige_bronze', 'prestige_silver', 'prestige_gold'];
const sortValues = ['sort_default', 'sort_low', 'sort_high', 'sort_severe', 'sort_emergency', 'sort_fortress'];
var chaptersForDisplay = [
  ChapterForDisplay("cmc", AppColors.cmcDark, AppColors.cmcLight),
  ChapterForDisplay("da", AppColors.daDark, AppColors.daLight),
  ChapterForDisplay("hs", AppColors.hsDark, AppColors.hsLight),
  ChapterForDisplay("loh", AppColors.lohDark, AppColors.lohLight),
  ChapterForDisplay("mom", AppColors.momDark, AppColors.momLight),
  ChapterForDisplay("m", AppColors.mDark, AppColors.mLight),
  ChapterForDisplay("mgs", AppColors.mgsDark, AppColors.mgsLight),
  ChapterForDisplay("mar", AppColors.maDark, AppColors.maLight),
  ChapterForDisplay("www", AppColors.wwwDark, AppColors.wwwLight),
  ChapterForDisplay("o", AppColors.oDark, AppColors.oLight),
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
  final List<WUPage> pages;

  Chapter(this.id, this.name, this.osm, this.examples, this.pages);

  factory Chapter.fromJson(Map<String, dynamic> json) {
    var list = json['pages'] as List;
    List<WUPage> pagesList = list.map((i) => WUPage.fromJson(i)).toList();

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

class WUPage {
  final String id;
  final String name;
  final List<Foundable> foundables;

  WUPage(this.id, this.name, this.foundables);

  factory WUPage.fromJson(Map<String, dynamic> json) {
    var list = json['foundables'] as List;
    List<Foundable> foundablesList = list.map((i) => Foundable.fromJson(i)).toList();

    return WUPage(
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

  Foundable(
    this.id,
    this.name,
    this.fragmentRequirementStandard,
    this.fragmentRequirementBronze,
    this.fragmentRequirementSilver,
    this.fragmentRequirementGold,
    this.howToCatch,
    this.threatLevel,
  );

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

WUPage getPageWithId(Chapter chapter, String id) {
  WUPage page;
  chapter.pages.forEach((p) {
    if (p.id == id) {
      page = p;
    }
  });

  return page;
}

List<String> getFoundablesIds(WUPage page) {
  return page.foundables.map((f) => f.id).toList();
}

Foundable getFoundableWithId(WUPage page, String id) {
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
  if (value == prestigeValues[0]) return 1;
  else if (value == prestigeValues[1]) return 2;
  else if (value == prestigeValues[2]) return 3;
  else if (value == prestigeValues[3]) return 4;
  return 1;
}

String getFragmentRequirement(Foundable foundable, String dropdownValue) {
  if (dropdownValue == prestigeValues[0]) return "/${foundable.fragmentRequirementStandard}";
  else if (dropdownValue == prestigeValues[1]) return "/${foundable.fragmentRequirementBronze}";
  else if (dropdownValue == prestigeValues[2]) return "/${foundable.fragmentRequirementSilver}";
  else if (dropdownValue == prestigeValues[3]) return "/${foundable.fragmentRequirementGold}";
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
      return AppColors.lowThreatColor;
    case "m":
      return AppColors.mediumThreatColor;
    case "h":
      return AppColors.highThreatColor;
    case "s":
      return AppColors.severeThreatColor;
    case "e":
      return AppColors.emergencyThreatColor;
  }
  return AppColors.lowThreatColor;
}

Widget getIconWithFoundable(Foundable foundable, double size) {
  var km = "";
  if (foundable.howToCatch.contains("p2")) km = "2";
  if (foundable.howToCatch.contains("p5")) km = "5";
  if (foundable.howToCatch.contains("p10")) km = "10";

  if (foundable.howToCatch.contains("p") && foundable.howToCatch.contains("f")) {
    return Container(
      width: size + 6,
      color: getColorWithFoundable(foundable),
      child: Column(
        children: <Widget>[
          portkeyWidget(size, foundable, km),
          regularWidget(size, foundable, "⚔️"),
        ],
      ),
    );
  } else if (foundable.howToCatch.contains("p") && foundable.howToCatch.length > 1) {
    return portkeyWidget(size, foundable, km);
  } else {
    String data = "";

    if (foundable.howToCatch == "p") data = "🔑️";
    if (foundable.howToCatch.contains("w")) data = "🌳";
    if (foundable.howToCatch.contains("f")) data = "⚔️";

    return regularWidget(size, foundable, data);
  }
}

Widget portkeyWidget(double size, Foundable foundable, String km) {
  return Container(
    width: size + 4,
    color: getColorWithFoundable(foundable),
    child: Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Text(
          km,
          style: TextStyle(
            fontSize: size * 0.7,
          ),
        ),
        Text(
          "🔑️",
          style: TextStyle(
            fontSize: size,
          ),
        ),
      ],
    ),
  );
}

Widget regularWidget(double size, Foundable foundable, String data) {
  return Container(
    width: size,
    child: Text(
      data,
      style: TextStyle(
        backgroundColor: getColorWithFoundable(foundable),
        fontSize: size,
      ),
    ),
  );
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
      var isPlaced = data[foundable.id]["placed"];
      var returned = data[foundable.id]["count"];
      var total = getRequirementWithLevel(foundable, level);
      var remainder = total - returned;

      if (!isPlaced) {
        if (foundable.howToCatch.contains("f")) {
          challenges += remainder;
        }
        if (foundable.howToCatch == "w" || foundable.howToCatch.contains("p")) {
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
      var isPlaced = data[foundable.id]["placed"];
      var returned = data[foundable.id]["count"];
      var total = getRequirementWithLevel(foundable, level);
      var remainder = total - returned;
      if (remainder > 0 && !isPlaced) {
        incompleteFoundables.add(IncompleteFoundable(chapter.id, foundable, remainder));
      }
    });

    if (incompleteFoundables.length < 3 && incompleteFoundables.length > 0) {
      almostCompletePages.add(AlmostCompletePage(page.id.i18n(), incompleteFoundables));
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
