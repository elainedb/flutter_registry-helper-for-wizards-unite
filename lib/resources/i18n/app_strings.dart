import '../../utils/globals.dart' as globals;
import 'en.dart';
import 'es.dart';
import 'fr.dart';
import 'pt.dart';

extension WizardStringExtension on String {
  String i18n() {
    String lang = globals.lang;

    Map<String, Map<String, String>> dic = {
      "en": values_en,
      "fr": values_fr,
      "pt": values_pt,
      "es": values_es,
    };

    return dic[lang][this];
  }
}