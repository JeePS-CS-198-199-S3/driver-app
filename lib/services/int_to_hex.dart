String intToHexColor(int colorValue) {
  String hexColor = colorValue.toRadixString(16).toUpperCase();
  // Take only the leftmost 6 hex digits
  hexColor = hexColor.substring(2, 8);
  // Pad the hex color value with zeros if necessary
  while (hexColor.length < 6) {
    hexColor = '0$hexColor';
  }
  return '#$hexColor';
}
