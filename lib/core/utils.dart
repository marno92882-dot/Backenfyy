import 'dart:convert';

String shellQuote(String value) {
  return "'${value.replaceAll("'", "'\\''")}'";
}

String base64EncodeUtf8(String value) => base64Encode(utf8.encode(value));

String formatTime(DateTime value) {
  final h = value.hour.toString().padLeft(2, '0');
  final m = value.minute.toString().padLeft(2, '0');
  final s = value.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}
