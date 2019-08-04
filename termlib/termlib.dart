library termlib;

import 'dart-ext:termlib';

// The simplest way to call native code: top-level functions.
int systemRand() native "SystemRand";
bool systemSrand(int seed) native "SystemSrand";
