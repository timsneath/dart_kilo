import 'dart:io';

import 'termlib/console.dart';

final console = Console();

const kiloVersion = '0.0.1';
const controlQ = 0x11;

void initEditor() {
  // die('Size is ${console.windowWidth} cols and ${console.windowHeight} rows.\r\n');
}

void die(String message) {
  console.clearScreen();
  console.resetCursorPosition();
  console.disableRawMode();
  stdout.write(message);
  exit(1);
}

// output
void editorDrawRows() {
  for (int y = 0; y < console.windowHeight; y++) {
    if (y == console.windowHeight / 3) {
      var welcomeMessage = 'Kilo editor -- version $kiloVersion';
      welcomeMessage.substring(0, console.windowWidth); // crop if necessary
      stdout.write(welcomeMessage);
    } else {
      stdout.write('~');
    }
    console.clearToLineEnd();

    if (y < console.windowHeight - 1) {
      stdout.write('\r\n');
    }
  }
}

void editorRefreshScreen() {
  console.hideCursor();
  console.resetCursorPosition();

  editorDrawRows();

  console.resetCursorPosition();
  console.showCursor();
}

// input
void editorProcessKeypress() {
  final codeUnit = stdin.readByteSync();

  switch (codeUnit) {
    case controlQ:
      console.clearScreen();
      console.resetCursorPosition();
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
