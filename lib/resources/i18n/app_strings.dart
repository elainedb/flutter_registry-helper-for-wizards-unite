import '../../utils/globals.dart' as globals;
import 'en.dart';
import 'fr.dart';

extension WizardStringExtension on String {
  String i18n() {
    String lang = globals.lang;

    Map<String, Map<String, String>> dic = {
      "en": values_en,
      "fr": values_fr,
      "error": {
        "pt": "Um erro ocorreu.",
        "es": "Ocurrió un error."
      },
      "my_registry": {
        "pt": "Meu Registro",
        "es": "Mi Registro"
      },
      "helper": {
        "pt": "Assistente",
        "es": "Asistente"
      },
      "charts": {
        "pt": "Gráficos",
        "es": "Gráficos"
      },
      "settings": {
        "pt": "Configurações",
        "es": "Ajustes"
      },
    };

    return dic[lang][this];
  }
}