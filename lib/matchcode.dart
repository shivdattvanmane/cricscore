import 'dart:math';

Set<String> generatedCodes = {};

String generateMatchCode() {
  var random = Random();
  String matchCode;
  do {
    int code = random.nextInt(900000) + 100000;
    matchCode = code.toString();
  } while (generatedCodes.contains(matchCode));
  generatedCodes.add(matchCode);
  return matchCode;
}

