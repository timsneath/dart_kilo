import 'dart:io';
import 'dart:math' show min;

import 'package:dart_console/dart_console.dart';

final console = Console();

const kiloVersion = '0.0.1';
const controlQ = 0x11;

// Cursor location relative to file (not the screen)
int cursorCol = 0, cursorRow = 0;

// The row in the file that is currently at the top of the screen
int screenFileRowOffset = 0;
// The column in the row that is currently on the left of the screen
int screenRowColOffset = 0;

var editorRows = <String>[];

void initEditor() {}

void die(String message) {
  console.clearScreen();
  console.resetCursorPosition();
  console.disableRawMode();
  console.write(message);
  exit(1);
}

String truncateString(String text, int length) =>
    length < text.length ? text.substring(0, length) : text;

// file i/o
void editorOpen(String filename) {
  final file = File(filename);
  editorRows = file.readAsLinesSync();
}

// output
void editorScroll() {
  if (cursorRow < screenFileRowOffset) {
    screenFileRowOffset = cursorRow;
  }

  if (cursorRow >= screenFileRowOffset + console.windowHeight) {
    screenFileRowOffset = cursorRow - console.windowHeight + 1;
  }

  if (cursorCol < screenRowColOffset) {
    screenRowColOffset = cursorCol;
  }

  if (cursorCol >= screenRowColOffset + console.windowWidth) {
    screenRowColOffset = cursorCol - console.windowWidth + 1;
  }
}

void editorDrawRows() {
  final screenBuffer = StringBuffer();

  for (int screenRow = 0; screenRow < console.windowHeight; screenRow++) {
    // fileRow is the row of the file we want to print to screenRow
    final fileRow = screenFileRowOffset + screenRow;

    // If we're beyond the text buffer, print tilde in column 0
    if (fileRow >= editorRows.length) {
      // Show a welcome message
      if (editorRows.isEmpty &&
          (screenRow == (console.windowHeight / 3).round())) {
        // Print the welcome message centered a third of the way down the screen
        final welcomeMessage = truncateString(
            'Kilo editor -- version $kiloVersion', console.windowWidth);
        int padding =
            ((console.windowWidth - welcomeMessage.length) / 2).round();
        if (padding > 0) {
          screenBuffer.write('~');
          padding--;
        }
        while (padding-- > 0) {
          screenBuffer.write(' ');
        }
        screenBuffer.write(welcomeMessage);
      } else {
        screenBuffer.write('~');
      }
    }

    // Otherwise print the onscreen portion of the current file row,
    // trimmed if necessary
    else {
      if (editorRows[fileRow].length - screenRowColOffset > 0) {
        screenBuffer.write(truncateString(
            editorRows[fileRow].substring(screenRowColOffset),
            console.windowWidth));
      }
    }

    // We're in raw mode, so we have to perform 'return to row 0' and 'line
    // feed' separately
    if (screenRow < console.windowHeight - 1) {
      screenBuffer.write('\r\n');
    }
  }

  console.write(screenBuffer.toString());
}

void editorRefreshScreen() {
  editorScroll();

  console.hideCursor();
  console.clearScreen();

  editorDrawRows();

  console.cursorPosition = Coordinate(
      cursorRow - screenFileRowOffset, cursorCol - screenRowColOffset);
  console.showCursor();
}

// input
void editorMoveCursor(ControlCharacter key) {
  switch (key) {
    case ControlCharacter.arrowLeft:
      if (cursorCol != 0) {
        cursorCol--;
      } else if (cursorRow > 0) {
        cursorRow--;
        cursorCol = editorRows[cursorRow].length;
      }
      break;
    case ControlCharacter.arrowRight:
      if (cursorRow < editorRows.length) {
        if (cursorCol < editorRows[cursorRow].length) {
          cursorCol++;
        } else if (cursorCol == editorRows[cursorRow].length) {
          cursorCol = 0;
          cursorRow++;
        }
      }
      break;
    case ControlCharacter.arrowUp:
      if (cursorRow != 0) cursorRow--;
      break;
    case ControlCharacter.arrowDown:
      if (cursorRow < editorRows.length) cursorRow++;
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
      cursorCol = 0;
      break;
    case ControlCharacter.end:
      cursorCol = console.windowWidth - 1;
      break;
    default:
  }

  if (cursorRow < editorRows.length) {
    cursorCol = min(cursorCol, editorRows[cursorRow].length);
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
  try {
    console.enableRawMode();
    initEditor();
    if (arguments.isNotEmpty) editorOpen(arguments[0]);

    while (true) {
      editorRefreshScreen();
      editorProcessKeypress();
    }
  } catch (exception) {
    console.disableRawMode();
    rethrow;
  }
}
