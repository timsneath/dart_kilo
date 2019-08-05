import 'dart:io';

import 'termlib/console.dart';

final console = Console();

const controlQ = 0x11;

void initEditor() {
  die('Size is ${console.windowWidth} cols and ${console.windowHeight} rows.\r\n');
}

void die(String message) {
  console.clearScreen();
  console.resetCursor();
  console.disableRawMode();
  stdout.write(message);
  exit(1);
}

// output
void editorDrawRows() {
  for (int y = 0; y < console.windowHeight; y++) {
    stdout.write('~\r\n');
  }
}

void editorRefreshScreen() {
  console.clearScreen();
  console.resetCursor();

  editorDrawRows();

  console.resetCursor();
}

// input
void editorProcessKeypress() {
  final codeUnit = stdin.readByteSync();

  switch (codeUnit) {
    case controlQ:
      console.clearScreen();
      console.resetCursor();
      exit(0);
      break;
  }
}

main(List<String> arguments) {
  console.enableRawMode();
  initEditor();

  while (true) {
    editorRefreshScreen();
    editorProcessKeypress();
  }
}
