import 'dart:io';

import 'package:dart_console/dart_console.dart';

final console = Console();

const kiloVersion = '0.0.1';
const controlQ = 0x11;

int cCol = 0, cRow = 0;

void initEditor() {}

void die(String message) {
  console.clearScreen();
  console.resetCursorPosition();
  console.disableRawMode();
  console.write(message);
  exit(1);
}

// output
void editorDrawRows() {
  for (int y = 0; y < console.windowHeight; y++) {
    if (y == (console.windowHeight / 3).round()) {
      var welcomeMessage = 'Kilo editor -- version $kiloVersion';
      if (console.windowWidth < welcomeMessage.length) {
        welcomeMessage = welcomeMessage.substring(0, console.windowWidth);
      }
      int padding = ((console.windowWidth - welcomeMessage.length) / 2).round();
      if (padding > 0) {
        console.write('~');
        padding--;
      }
      while (padding-- > 0) {
        console.write(' ');
      }
      console.write(welcomeMessage);
    } else {
      console.write('~');
    }
    console.clearToLineEnd();

    if (y < console.windowHeight - 1) {
      console.write('\r\n');
    }
  }
}

void editorRefreshScreen() {
  console.hideCursor();
  console.resetCursorPosition();

  editorDrawRows();

  console.cursorPosition = Coordinate(cRow, cCol);
  console.showCursor();
}

// input
void editorMoveCursor(String key) {
  switch (key) {
    case 'a':
      cCol--;
      break;
    case 'd':
      cCol++;
      break;
    case 'w':
      cRow--;
      break;
    case 's':
      cRow++;
      break;
  }
}

void editorProcessKeypress() {
  final codeUnit = stdin.readByteSync();
  final char = String.fromCharCode(codeUnit);

  switch (codeUnit) {
    case controlQ:
      console.clearScreen();
      console.resetCursorPosition();
      exit(0);
      break;
  }

  if ((char == 'w') || (char == 'a') || (char == 's') || (char == 'd')) {
    editorMoveCursor(char);
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
