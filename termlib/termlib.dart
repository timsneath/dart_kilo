import 'dart:ffi' as ffi;

typedef enableraw_native_t = ffi.Void Function();

typedef disableraw_native_t = ffi.Void Function();

class TermLib {
  ffi.DynamicLibrary termlib;

  void Function() enableRawMode;
  void Function() disableRawMode;

  TermLib() {
    termlib = ffi.DynamicLibrary.open('termlib/termlib.so');

    enableRawMode = termlib
        .lookup<ffi.NativeFunction<enableraw_native_t>>('enableRawMode')
        .asFunction();

    disableRawMode = termlib
        .lookup<ffi.NativeFunction<disableraw_native_t>>('disableRawMode')
        .asFunction();
  }
}
