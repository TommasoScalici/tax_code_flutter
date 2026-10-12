/// Available formats for sharing a single contact's tax code data.
enum ContactShareFormat {
  /// Plain text tax code string.
  text,

  /// High-resolution graphical card with 1D Barcode and 2D QR Code.
  image,

  /// Printable A4 summary document with complete personal details.
  pdf,
}
