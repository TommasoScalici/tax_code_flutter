/// Utility for converting Italian tax codes into their phonetic spelling
/// using the traditional Italian telephone alphabet and Italian digit names.
///
/// Intended for Text-to-Speech (TTS) and voice assistants (e.g. Google Gemini)
/// to accurately dictate tax codes character by character.
final class PhoneticSpellingFormatter {
  const PhoneticSpellingFormatter._();

  static const Map<String, String> _phoneticMap = {
    'A': 'Ancona',
    'B': 'Bologna',
    'C': 'Como',
    'D': 'Domodossola',
    'E': 'Empoli',
    'F': 'Firenze',
    'G': 'Genova',
    'H': 'Hotel',
    'I': 'Imola',
    'J': 'Jolly',
    'K': 'Kursaal',
    'L': 'Livorno',
    'M': 'Milano',
    'N': 'Napoli',
    'O': 'Otranto',
    'P': 'Palermo',
    'Q': 'Quarto',
    'R': 'Roma',
    'S': 'Sassari',
    'T': 'Torino',
    'U': 'Udine',
    'V': 'Venezia',
    'W': 'Washington',
    'X': 'Xeres',
    'Y': 'Yemen',
    'Z': 'Zara',
  };

  static const Map<String, String> _digitMap = {
    '0': 'zero',
    '1': 'uno',
    '2': 'due',
    '3': 'tre',
    '4': 'quattro',
    '5': 'cinque',
    '6': 'sei',
    '7': 'sette',
    '8': 'otto',
    '9': 'nove',
  };

  /// Returns the phonetic representation for a single uppercase character.
  ///
  /// - Letters: `"X come [Città]"` (e.g. `"A come Ancona"`).
  /// - Digits: `"uno"`, `"due"`, etc.
  /// - Other symbols: returned as-is.
  static String formatCharacter(String char) {
    if (char.isEmpty) return '';
    final upper = char[0].toUpperCase();
    final city = _phoneticMap[upper];
    if (city != null) {
      return '$upper come $city';
    }
    final digit = _digitMap[upper];
    if (digit != null) {
      return digit;
    }
    return upper;
  }

  /// Formats the given tax code into a comma-separated phonetic spelling string.
  ///
  /// Whitespace is stripped before formatting.
  /// Example:
  /// `"RSSMRA80A01H501U"` ->
  /// `"R come Roma, S come Sassari, S come Sassari, M come Milano, R come Roma, A come Ancona, otto, zero, A come Ancona, zero, uno, H come Hotel, cinque, zero, uno, U come Udine"`
  static String format(String taxCode) {
    final cleaned = taxCode.trim().replaceAll(' ', '');
    if (cleaned.isEmpty) return '';
    return cleaned.split('').map(formatCharacter).join(', ');
  }
}
