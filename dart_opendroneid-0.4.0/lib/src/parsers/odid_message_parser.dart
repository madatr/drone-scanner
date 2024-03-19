import 'dart:typed_data';

import '../types.dart';

abstract class ODIDMessageParser {
  ODIDMessage? parse(Uint8List messageData);
}
