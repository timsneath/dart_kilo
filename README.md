[![Language](https://img.shields.io/badge/language-Dart-blue.svg)](https://dart.dev)

An initial attempt at a Dart port of the [Kilo text editor][kilo]. Primarily
built as a test harness for the [`dart_console`][dart_console] package, which
is itself at an early stage of development. 

## Current status (Aug 16th, 2019):
Implemented enough for a text viewer (no input yet). You can call it with:
```bash
$ dart kilo.dart testfile
```
 - Arrow keys, page up/down, home/end should all work.
 - Vertical and horizontal scrolling should work. 
 - Status bar should show accurate information

## About the source project
Notes from the Kilo project:

> Kilo does not depend on any library (not even curses). It uses fairly 
> standard VT100 (and similar terminals) escape sequences. The project is in 
> [an] alpha stage and was written in just a few hours...

> People are encouraged to use it as a starting point to write other editors
> or command line interfaces that are more advanced than the usual REPL style
> CLI.

Thanks also to snaptoken, for their instruction tutorial which breaks Kilo
down into a [multi-step tutorial][snaptoken]. Lots of fun here! 

[kilo]: https://github.com/antirez/kilo
[dart_console]: https://github.com/timsneath/dart_console
[snaptoken]: https://viewsourcecode.org/snaptoken/kilo/
