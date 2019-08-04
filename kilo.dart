import 'dart:io';
import 'termlib/termlib.dart';

final termlib = TermLib();

bool iscntrl(int charCode) {
  if (charCode >= 0x00 && charCode <= 0x1f) return true;
  if (charCode == 0x7f) return true;
  return false;
}

main(List<String> arguments) {
  termlib.enableRawMode();

  int charCode;
  String char;

  while (true) {
    charCode = stdin.readByteSync();
    if (charCode == -1) break;

    char = String.fromCharCode(charCode);
    if (char == 'q') break;

    if (iscntrl(charCode)) {
      stdout.write("$charCode\r\n");
    } else {
      stdout.write("$charCode ('$char')\r\n");
    }
  }

  termlib.disableRawMode();
  return 0;
}
