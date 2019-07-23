import 'package:cloud_firestore/cloud_firestore.dart';

const prestigeValues = ['Standard', 'Bronze', 'Silver', 'Gold'];

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
  final List<Page> pages;

  Chapter(this.id, this.name, this.pages);

  factory Chapter.fromJson(Map<String, dynamic> json) {
    var list = json['pages'] as List;
    List<Page> pagesList = list.map((i) => Page.fromJson(i)).toList();

    return Chapter(
      json['id'],
      json['name'],
      pagesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
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

  Foundable(this.id, this.name, this.fragmentRequirementStandard, this.fragmentRequirementBronze, this.fragmentRequirementSilver, this.fragmentRequirementGold);

  Foundable.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        fragmentRequirementStandard = json['fragmentRequirementStandard'],
        fragmentRequirementBronze = json['fragmentRequirementBronze'],
        fragmentRequirementSilver = json['fragmentRequirementSilver'],
        fragmentRequirementGold = json['fragmentRequirementGold'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fragmentRequirementStandard': fragmentRequirementStandard,
        'fragmentRequirementBronze': fragmentRequirementBronze,
        'fragmentRequirementSilver': fragmentRequirementSilver,
        'fragmentRequirementGold': fragmentRequirementGold,
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

String getPrestigeLevelWithPageId(String pageId, DocumentSnapshot data) {
  switch (data.data["${pageId}_1"]["level"]) {
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