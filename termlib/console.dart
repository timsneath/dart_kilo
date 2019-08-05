import 'dart:io';

import 'ansi.dart';
import 'termlib.dart';

class Coordinate {
  final int row;
  final int col;

  const Coordinate(int row, int col)
      : this.row = row,
        this.col = col;

  bool operator ==(dynamic other) =>
      other is Coordinate && row == other.row && col == other.col;
}

class Console {
  final termlib = TermLib();

  void enableRawMode() => termlib.enableRawMode();
  void disableRawMode() => termlib.disableRawMode();

  void clearScreen() => stdout.write(ansiEraseInDisplayAll);
  void setCursor(Coordinate coordinate) => stdout
      .write(ansiCursorPosition(row: coordinate.row, col: coordinate.col));
  void resetCursor() => stdout.write(ansiCursorPosition());

  int get windowWidth {
    // termlib tries ioctl() to give us the screen size, but we fall back to
    // the approach of setting the cursor to beyond the edge of the screen and
    // then reading back the actual position of the cursor
    final width = termlib.getWindowWidth();
    if (width != -1) {
      return width;
    } else {
      final originalCursor = cursorPosition;
      stdout.write(ansiMoveCursorToScreenEdge);
      final newCursor = cursorPosition;
      setCursor(originalCursor);

      if (newCursor != null) {
        return newCursor.col;
      } else {
        throw Exception("Couldn't retrieve window width");
      }
    }
  }

  int get windowHeight {
    // termlib tries ioctl() to give us the screen size, but we fall back to
    // the approach of setting the cursor to beyond the edge of the screen and
    // then reading back the actual position of the cursor
    final height = termlib.getWindowHeight();
    if (height != -1) {
      return height;
    } else {
      final originalCursor = cursorPosition;
      stdout.write(ansiMoveCursorToScreenEdge);
      final newCursor = cursorPosition;
      setCursor(originalCursor);

      if (newCursor != null) {
        return newCursor.row;
      } else {
        throw Exception("Couldn't retrieve window height");
      }
    }
  }

  Coordinate get cursorPosition {
    stdout.write(ansiDeviceStatusReportCursorPosition);
    // returns a result in the form <ESC>[24;80R
    String result = '';
    int i = 0;

    // avoid infinite loop if we're getting a bad result
    while (i < 16) {
      result += String.fromCharCode(stdin.readByteSync());
      if (result.endsWith('R')) break;
      i++;
    }

    if (result[0] != '\x1b') return null;

    result = result.substring(2, result.length - 1);
    final coords = result.split(';');

    if (coords.length != 2) return null;
    if ((int.tryParse(coords[0]) != null) &&
        (int.tryParse(coords[1]) != null)) {
      return Coordinate(int.parse(coords[0]), int.parse(coords[1]));
    } else {
      return null;
    }
  }
}
