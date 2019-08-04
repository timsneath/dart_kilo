import 'dart:io';
import 'termlib/termlib.dart';

final terminal = TermLib();

const controlQ = 0x11;

void editorProcessKeypress() {
  final codeUnit = stdin.readByteSync();

  switch (codeUnit) {
    case controlQ:
      exit(0);
      break;
  }
}

main(List<String> arguments) {
  terminal.enableRawMode();

  while (true) {
    editorProcessKeypress();
  }
}
