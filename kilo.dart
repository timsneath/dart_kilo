import 'dart:io';
import 'termlib/termlib.dart';

final terminal = TermLib();

int controlCharacter(String key) => key.codeUnitAt(0) & 0x1F;

bool isCodeUnitNonPrintable(int rawCharCode) {
  if (rawCharCode >= 0x00 && rawCharCode <= 0x1f) return true;
  if (rawCharCode == 0x7f) return true;
  return false;
}

main(List<String> arguments) {
  terminal.enableRawMode();

  int codeUnit;
  String char;

  while (true) {
    codeUnit = stdin.readByteSync();
    if (codeUnit == -1) break;

    char = String.fromCharCode(codeUnit);

    if (isCodeUnitNonPrintable(codeUnit)) {
      stdout.write("$codeUnit\r\n");
    } else {
      stdout.write("$codeUnit ('$char')\r\n");
    }
    if (codeUnit == controlCharacter('Q')) break;
  }

  return 0;
}
