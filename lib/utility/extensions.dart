// import '../config/app_constants.dart';

extension MapParsing on Map<String, dynamic> {
  // Common API DATA
  // Map withAPIKeyAndSecretKey() {
  //   final map = this;
  //
  //   map[AppConstants.SECRET_KEY] = AppConstants.SECRET_KEY;
  //
  //   return map;
  // }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
  int getNumbers() => int.parse(replaceAll(RegExp(r'[^0-9]'), ''));
  String get zeroPaddedNumber {
    if (int.tryParse(this) != null && int.parse(this) >= 0) {
      return padLeft(3, '0');
    } else {
      return this;
    }
  }

  String toSentenceCase() {
    final result = StringBuffer();
    for (var i = 0; i < length; i++) {
      if (i == 0) {
        result.write(this[i].toUpperCase());
      } else if (this[i] == this[i].toUpperCase()) {
        result.write(' ');
        result.write(this[i].toLowerCase());
      } else {
        result.write(this[i]);
      }
    }
    return result.toString();
  }
}

