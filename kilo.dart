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
void editorMoveCursor(ControlCharacter key) {
  switch (key) {
    case ControlCharacter.arrowLeft:
      if (cCol != 0) cCol--;
      break;
    case ControlCharacter.arrowRight:
      if (cCol != console.windowWidth - 1) cCol++;
      break;
    case ControlCharacter.arrowUp:
      if (cRow != 0) cRow--;
      break;
    case ControlCharacter.arrowDown:
      if (cRow != console.windowHeight - 1) cRow++;
      break;
    case ControlCharacter.pageUp:
      for (var i = 0; i < console.windowHeight; i++) {
        editorMoveCursor(ControlCharacter.arrowUp);
      }
      break;
    case ControlCharacter.pageDown:
      for (var i = 0; i < console.windowHeight; i++) {
        editorMoveCursor(ControlCharacter.arrowDown);
      }
      break;
    case ControlCharacter.home:
      cCol = 0;
      break;
    case ControlCharacter.end:
      cCol = console.windowWidth - 1;
      break;
    default:
  }
}

void editorProcessKeypress() {
  final key = console.readKey();

  if (key.isControl) {
    switch (key.controlChar) {
      case ControlCharacter.ctrlQ:
        console.clearScreen();
        console.resetCursorPosition();
        exit(0);
        break;
      case ControlCharacter.arrowLeft:
      case ControlCharacter.arrowUp:
      case ControlCharacter.arrowRight:
      case ControlCharacter.arrowDown:
      case ControlCharacter.pageUp:
      case ControlCharacter.pageDown:
      case ControlCharacter.home:
      case ControlCharacter.end:
        editorMoveCursor(key.controlChar);
        break;
      default:
    }
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
