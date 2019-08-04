import 'dart:io';

void disableRawMode() {
  stdin.lineMode = true;
  stdin.echoMode = true;
}

void enableRawMode() {
  stdin.echoMode = false;
  stdin.lineMode = false;
}

main(List<String> arguments) {
  enableRawMode();

  int charCode;
  String char;

  charCode = stdin.readByteSync();
  char = String.fromCharCode(charCode);

  print("charcode: $charCode (char: '$char')");

  while (charCode != -1 && char != 'q') {
    charCode = stdin.readByteSync();
    char = String.fromCharCode(charCode);

    print("charcode: $charCode (char: '$char')");
  }

  disableRawMode();
  return 0;
}
