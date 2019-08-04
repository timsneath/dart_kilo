import 'dart:io';

void disableRawMode() {
  stdin.lineMode = true;
  stdin.echoMode = true;
}

void enableRawMode() {
  stdin.echoMode = false;
  stdin.lineMode = false;
}

bool iscntrl(int charCode) {
  if (charCode >= 0x00 && charCode <= 0x1f) return true;
  if (charCode == 0x7f) return true;
  return false;
}

main(List<String> arguments) {
  enableRawMode();

  int charCode;
  String char;

  while (true) {
    charCode = stdin.readByteSync();
    if (charCode == -1) break;

    char = String.fromCharCode(charCode);
    if (char == 'q') break;

    if (iscntrl(charCode)) {
      print("$charCode");
    } else {
      print("$charCode ('$char')");
    }
  }

  disableRawMode();
  return 0;
}
