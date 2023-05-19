import 'dart:io';

String toPosixPath(String pth) {
  return pth.replaceAll(RegExp(r'[\\]'), '/');
}

String toWin32Path(String pth) {
  return pth.replaceAll(RegExp(r'[/]'), '\\');
}

String toPlatformPath(String pth) {
  return pth.replaceAll(RegExp(r'[/\\]'), Platform.pathSeparator);
}
