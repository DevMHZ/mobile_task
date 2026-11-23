double? parsePrice(String input) {
  var value = input.trim();
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  for (var i = 0; i < arabic.length; i++) {
    value = value.replaceAll(arabic[i], '$i');
  }
  value = value.replaceAll('٫', '.');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) return null;
  final price = double.tryParse(value);
  return price != null && price.isFinite ? price : null;
}
