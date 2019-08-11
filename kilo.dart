import 'dart:io';
import 'dart:math' show min;

import 'package:dart_console/dart_console.dart';

final console = Console();

const kiloVersion = '0.0.1';
const kiloTabStopLength = 8;

// We keep two copies of the file contents, as follows:
//
// fileRows represents the actual contents of the document
//
// renderRows represents what we'll render on screen. This may be different to
// the actual contents of the file. For example, tabs are rendered as a series
// of spaces even though they are only one character; control characters may
// be shown in some form in the future.
var fileRows = <String>[];
var renderRows = <String>[];

// Cursor location relative to file (not the screen)
int cursorCol = 0, cursorRow = 0;

// Also store cursor column position relative to the rendered row
int cursorRenderCol = 0;

// The row in the file that is currently at the top of the screen
int screenFileRowOffset = 0;
// The column in the row that is currently on the left of the screen
int screenRowColOffset = 0;

// Allow a line for the status bar
final editorWindowHeight = console.windowHeight - 1;

void initEditor() {}

void die(String message) {
  console.clearScreen();
  console.resetCursorPosition();
  console.rawMode = false;
  console.write(message);
  exit(1);
}

String truncateString(String text, int length) =>
    length < text.length ? text.substring(0, length) : text;

// file i/o
void editorOpen(String filename) {
  final file = File(filename);
  fileRows = file.readAsLinesSync();

  for (var row in fileRows) {
    row.replaceAll('\t', ' ' * kiloTabStopLength);
    renderRows.add(row);
  }

  assert(fileRows.length == renderRows.length);
}

// output
int getRenderedCol(int fileRow, int fileCol) {
  int col = 0;
  String row = fileRows[fileRow];
  for (var i = 0; i < fileCol; i++) {
    if (row[i] == '\t') {
      col += (kiloTabStopLength - 1) - (col % kiloTabStopLength);
    }
    col++;
  }
  return col;
}

void editorScroll() {
  cursorRenderCol = 0;

  if (cursorRow < fileRows.length) {
    cursorRenderCol = getRenderedCol(cursorRow, cursorCol);
  }

  if (cursorRow < screenFileRowOffset) {
    screenFileRowOffset = cursorRow;
  }

  if (cursorRow >= screenFileRowOffset + editorWindowHeight) {
    screenFileRowOffset = cursorRow - editorWindowHeight + 1;
  }

  if (cursorRenderCol < screenRowColOffset) {
    screenRowColOffset = cursorRenderCol;
  }

  if (cursorRenderCol >= screenRowColOffset + editorWindowHeight) {
    screenRowColOffset = cursorRenderCol - editorWindowHeight + 1;
  }
}

void editorDrawRows() {
  final screenBuffer = StringBuffer();

  for (int screenRow = 0; screenRow < editorWindowHeight; screenRow++) {
    // fileRow is the row of the file we want to print to screenRow
    final fileRow = screenFileRowOffset + screenRow;

    // If we're beyond the text buffer, print tilde in column 0
    if (fileRow >= fileRows.length) {
      // Show a welcome message
      if (fileRows.isEmpty && (screenRow == (editorWindowHeight / 3).round())) {
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
      if (fileRows[fileRow].length - screenRowColOffset > 0) {
        screenBuffer.write(truncateString(
            fileRows[fileRow].substring(screenRowColOffset),
            console.windowWidth));
      }
    }

    screenBuffer.write(console.newLine);
  }

  console.write(screenBuffer.toString());
}

void editorDrawStatusBar() {
  console.setTextStyle(inverted: true);
  console.write("<<< STATUS BAR >>>".padRight(console.windowWidth));
  console.resetColorAttributes();
}

void editorRefreshScreen() {
  editorScroll();

  console.hideCursor();
  console.clearScreen();

  editorDrawRows();
  editorDrawStatusBar();

  console.cursorPosition = Coordinate(
      cursorRow - screenFileRowOffset, cursorRenderCol - screenRowColOffset);
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
        cursorCol = fileRows[cursorRow].length;
      }
      break;
    case ControlCharacter.arrowRight:
      if (cursorRow < fileRows.length) {
        if (cursorCol < fileRows[cursorRow].length) {
          cursorCol++;
        } else if (cursorCol == fileRows[cursorRow].length) {
          cursorCol = 0;
          cursorRow++;
        }
      }
      break;
    case ControlCharacter.arrowUp:
      if (cursorRow != 0) cursorRow--;
      break;
    case ControlCharacter.arrowDown:
      if (cursorRow < fileRows.length) cursorRow++;
      break;
    case ControlCharacter.pageUp:
      cursorRow = screenFileRowOffset;
      for (var i = 0; i < editorWindowHeight; i++) {
        editorMoveCursor(ControlCharacter.arrowUp);
      }
      break;
    case ControlCharacter.pageDown:
      cursorRow = screenFileRowOffset + editorWindowHeight - 1;
      for (var i = 0; i < editorWindowHeight; i++) {
        editorMoveCursor(ControlCharacter.arrowDown);
      }
      break;
    case ControlCharacter.home:
      cursorCol = 0;
      break;
    case ControlCharacter.end:
      if (cursorRow < fileRows.length) {
        cursorCol = fileRows[cursorRow].length;
      }
      break;
    default:
  }

  if (cursorRow < fileRows.length) {
    cursorCol = min(cursorCol, fileRows[cursorRow].length);
  }
}

void editorProcessKeypress() {
  final key = console.readKey();

  if (key.isControl) {
    switch (key.controlChar) {
      case ControlCharacter.ctrlQ:
        console.clearScreen();
        console.resetCursorPosition();
        console.rawMode = false;
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
    console.rawMode = true;
    initEditor();
    if (arguments.isNotEmpty) editorOpen(arguments[0]);

    while (true) {
      editorRefreshScreen();
      editorProcessKeypress();
    }
  } catch (exception) {
    // Make sure raw mode gets disabled if we hit some unrelated problem
    console.rawMode = false;
    rethrow;
  }
}
