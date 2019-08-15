[![Language](https://img.shields.io/badge/language-Dart-blue.svg)](https://dart.dev)

An initial attempt at a Dart port of the [Kilo text editor][kilo]. Primarily
built as a test harness for the [`dart_console`][dart_console] package, which
is itself at an early stage of development. 

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
