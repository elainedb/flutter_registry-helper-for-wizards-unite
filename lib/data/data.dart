import 'package:cloud_firestore/cloud_firestore.dart';

const prestigeValues = ['Standard', 'Bronze', 'Silver', 'Gold'];

class Registry {
  final List<Chapter> chapters;

  Registry(this.chapters);
}

class Chapter {
  final String id;
  final String name;
  final List<Page> pages;

  Chapter(this.id, this.name, this.pages);
}

class Page {
  final String id;
  final String name;
  final List<Foundable> foundables;

  Page(this.id, this.name, this.foundables);
}

class Foundable {
  final String id;
  final String name;
  final int fragmentRequirementStandard;
  final int fragmentRequirementBronze;
  final int fragmentRequirementSilver;
  final int fragmentRequirementGold;

  Foundable(this.id, this.name, this.fragmentRequirementStandard, this.fragmentRequirementBronze, this.fragmentRequirementSilver, this.fragmentRequirementGold);
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