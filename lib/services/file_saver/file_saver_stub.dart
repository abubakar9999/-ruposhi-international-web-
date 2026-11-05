import 'dart:typed_data';
import 'dart:developer' as dev;

void saveFile(Uint8List bytes, String fileName, {String mimeType = 'application/pdf'}) {
  dev.log('FileSaver (Stub): Triggered download for $fileName (${bytes.length} bytes)');
}

