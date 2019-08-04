import 'dart:io';

import 'ansi.dart';
import 'termlib.dart';

class Console {
  final termlib = TermLib();

  void enableRawMode() => termlib.enableRawMode();
  void disableRawMode() => termlib.disableRawMode();

  void clearScreen() => stdout.write(ansiEraseInDisplay);
  void setCursor(int row, int col) =>
      stdout.write(ansiCursorPosition(row: row, col: col));
  void resetCursor() => stdout.write(ansiCursorPosition());

  int get windowWidth => 80;
  int get windowHeight => 24;
}
