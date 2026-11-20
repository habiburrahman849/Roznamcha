abstract final class PhoneUtils {
  static String digitsOnly(String? phone) =>
      (phone ?? '').replaceAll(RegExp(r'\D'), '');

  /// WhatsApp needs a country code. A Pakistani mobile written as
  /// 03xxxxxxxxx is rewritten to 92xxxxxxxxxx. Anything else is digits only.
  static String? waDigits(String? phone) {
    var digits = digitsOnly(phone);
    if (digits.isEmpty) return null;
    if (digits.startsWith('0') && digits.length == 11) {
      digits = '92${digits.substring(1)}';
    }
    return digits;
  }
}
