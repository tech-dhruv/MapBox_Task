// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:intl/intl.dart';

class AppConstants {
  static const String APP_NAME = "Flutter Setup";
  static const String FONT_FAMILY = "arial";

  // Shared Preference Keys
  static const String TOKEN = 'token';
  static const String THEME = 'theme';
  static const String ONBOARDING_DONE = 'onboarding_done';

  // secret Keys
  static const String SECRET_KEY = "secret";

  // POLICY URLS
  static const String PRIVACY_POLICY = "";
  static const String TERMS_OF_SERVICE = "";

  //API
  static const String API_STATUS = "status";
  static const String API_STATUS_CODE = "status_code";
  static const String API_ERROR = "error";
  static const String API_MESSAGE = "message";

  static String getPhotoUrl(String file) {
    return "http://13.50.241.50:3000/$file";
  }

  static String getFormatDateTime(date) {
    return DateFormat('dd/MM/yyyy | hh:mm aa')
        .format(DateTime.parse(date).toLocal());
  }

  static String getFormatTimeDate(date) {
    return DateFormat('hh:mm aa | dd/MM/yyyy')
        .format(DateTime.parse(date).toLocal());
  }

  static String getFormatTime(date) {
    return DateFormat('hh:mm aa').format(date);
  }

  static String getFormatDate(date) {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
  }

  static String getCustomDate(String format, date) {
    return DateFormat(format).format(DateTime.parse(date).toLocal()).toString();
  }
}
