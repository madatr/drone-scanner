import 'dart:typed_data';

import 'package:dart_opendroneid/dart_opendroneid.dart';

void main() {
  final Uint8List messageData = Uint8List.fromList([
    // Message Type = Basic ID, Protcol ver. = 2
    0x02,
    // ID type = Serial Number (ANSI/CTA-2063-A), UA Type = Aircraft
    0x11,
    // UAS ID = 15968DEADBEEF
    0x31, 0x35, 0x39, 0x36, 0x38, 0x44, 0x45, 0x41, 0x44, 0x42, 0x45, 0x45,
    0x46,
    // NULL padding
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  ]);

  final type = determineODIDMessageType(messageData);
  print('Message type: $type');

  final message = parseODIDMessage(messageData) as BasicIDMessage;

  print(message);
}
