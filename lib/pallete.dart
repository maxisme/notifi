import 'dart:ui';

class MyColour {
  // This class is not meant to be instantiated or extended; this constructor
  // prevents instantiation and extension.
  // ignore: unused_element
  MyColour._();

  /// Completely invisible.
  static const Color offWhite = Color(0xfff5f5f5);
  static const Color white = Color(0xffffffff);
  static const Color offGrey = Color(0xffeae8e8);
  static const Color black = Color(0xff212121);
  static const Color darkGrey = Color(0xff333333);
  static const Color grey = Color(0xff707070);
  static const Color red = Color(0xffbc2122);
  static const Color transparent = Color(0x0000000);
}
