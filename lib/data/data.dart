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