#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

struct termios orig_termios;

void enableRawMode() {
  tcgetattr(STDIN_FILENO, &orig_termios);
  atexit(disableRawMode);

  struct termios raw = orig_termios;
  raw.c_lflag &= ~(ECHO | ICANON);

  tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

void disableRawMode() { tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios); }

int main() {
  enableRawMode();

  char c;
  while (read(STDIN_FILENO, &c, 1) == 1 && c != 'q') {
    if (isprint(c)) {
      printf("%d ('%c')\n", c, c);
    } else {
      printf("%d\n", c);
    }
  }
  return 0;
}