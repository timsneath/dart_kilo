const ansiEraseInDisplay = '\x1b[2J';
const ansiResetCursorPosition = '\x1b[H';
String ansiCursorPosition({int row = 1, int col = 1}) => '\x1b[${row};${col}H';
