import 'dart:io';

import 'termlib/console.dart';

final console = Console();

const controlQ = 0x11;

void initEditor() {
  // die('Size is ${console.windowWidth} cols and ${console.windowHeight} rows.\r\n');
}

void die(String message) {
  console.clearScreen();
  console.resetCursor();
  console.disableRawMode();
  stdout.write(message);
  exit(1);
}

// output
StringBuffer editorDrawRows() {
  var buffer = StringBuffer();
  final windowHeight = console.windowHeight;
  for (int y = 0; y < windowHeight; y++) {
    buffer.write('~');

    if (y < windowHeight - 1) {
      buffer.write('\r\n');
    }
  }
  return buffer;
}

void editorRefreshScreen() {
  console.clearScreen();
  console.resetCursor();

  final screen = editorDrawRows();
  stdout.write(screen.toString());

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
