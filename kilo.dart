import 'dart:io';

import 'package:dart_console/dart_console.dart';

final console = Console();

const kiloVersion = '0.0.1';
const controlQ = 0x11;

// Cursor location relative to screen
int cCol = 0, cRow = 0;

var editorRows = <String>[];

void initEditor() {}

void die(String message) {
  console.clearScreen();
  console.resetCursorPosition();
  console.disableRawMode();
  console.write(message);
  exit(1);
}

String trimStringToWindowWidth(String text) {
  if (console.windowWidth < text.length) {
    text = text.substring(0, console.windowWidth);
  }
  return text;
}

// file i/o
void editorOpen(String filename) {
  final file = File(filename);
  editorRows = file.readAsLinesSync();
}

// output
void editorDrawRows() {
  for (int row = 0; row < console.windowHeight; row++) {
    if (row >= editorRows.length) {
      if (editorRows.isEmpty && (row == (console.windowHeight / 3).round())) {
        final welcomeMessage =
            trimStringToWindowWidth('Kilo editor -- version $kiloVersion');
        int padding =
            ((console.windowWidth - welcomeMessage.length) / 2).round();
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
    } else {
      // trim as necessary so this line doesn't fall off the edge of the screen
      console.write(trimStringToWindowWidth(editorRows[0]));
    }
    console.clearToLineEnd();

    if (row < console.windowHeight - 1) {
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
        console.disableRawMode();
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
  if (arguments.isNotEmpty) editorOpen(arguments[0]);

  while (true) {
    editorRefreshScreen();
    editorProcessKeypress();
  }
}
