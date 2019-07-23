import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/widgets/registry.dart';

class LocatorPage extends StatefulWidget {
  final Registry _registry;
  LocatorPage(this._registry);

  @override
  State<StatefulWidget> createState() => LocatorPageState(_registry);
}

class LocatorPageState extends State<LocatorPage> {
  final Registry _registry;
  LocatorPageState(this._registry);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        getLocatorForChapter("cmc", cmcDark, cmcLight),
        getLocatorForChapter("da", daDark, daLight),
        getLocatorForChapter("hs", hsDark, hsLight),
        getLocatorForChapter("loh", lohDark, lohLight),
        getLocatorForChapter("mom", momDark, momLight),
        getLocatorForChapter("m", mDark, mLight),
        getLocatorForChapter("mgs", mgsDark, mgsLight),
        getLocatorForChapter("ma", maDark, maLight),
        getLocatorForChapter("www", wwwDark, wwwLight),
        getLocatorForChapter("o", oDark, oLight),
      ],
    );
  }

  Card getLocatorForChapter(String chapterId, Color dark, Color light) {
    var chapter = getChapterWithId(_registry, chapterId);

    return Card(
      color: light,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: <Widget>[
            Container(
              height: 100,
              child: Image.asset(
                "images/$chapterId.png",
                color: Color.fromRGBO(255, 255, 255, 0.5),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                    child: Text(
                  chapter.name,
                  style: TextStyle(color: dark, fontSize: 16, fontWeight: FontWeight.bold),
                )),
                Container(
                  height: 24,
                ),
                Text(
                  "Open Street Maps Value/Category:",
                  style: TextStyle(color: dark, fontSize: 14),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child: Text(
                    chapter.osm,
                    style: TextStyle(color: dark, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 24,
                ),
                Text(
                  "Examples:",
                  style: TextStyle(color: dark, fontSize: 14),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child: Text(
                    chapter.examples,
                    style: TextStyle(color: dark, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
