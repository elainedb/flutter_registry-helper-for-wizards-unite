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