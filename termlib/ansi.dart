const ansiDeviceStatusReportCursorPosition = '\x1b[6n';
const ansiEraseInDisplayAll = '\x1b[2J';
const ansiResetCursorPosition = '\x1b[H';
const ansiMoveCursorToScreenEdge = '\x1b[999C\x1b[999B';
String ansiCursorPosition({int row = 1, int col = 1}) => '\x1b[${row};${col}H';
