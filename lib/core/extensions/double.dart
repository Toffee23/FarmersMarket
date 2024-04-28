extension DoubleUtils on double {
  String toPrice([String currency = '₦']) {
    final String str = toStringAsFixed(2);

    List<String> parts = str.split('.');
    String integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},');
    String result = integerPart;

    if (parts.length > 1) {
      result += '.${parts[1]}';
    }

    return '$currency$result';
  }
}
