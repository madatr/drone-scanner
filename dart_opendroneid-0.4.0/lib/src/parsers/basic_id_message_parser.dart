import 'dart:typed_data';

import '../decoders/basic_id_message_decoders.dart';
import '../decoders/decoders.dart';
import '../types.dart';
import 'odid_message_parser.dart';

class BasicIDMessageParser implements ODIDMessageParser {
  const BasicIDMessageParser();

  @override
  BasicIDMessage? parse(Uint8List messageData) {
    final protocolVersion =
        decodeField(decodeProtocolVersion, messageData, 0, 1);

    // UAS type is present on the lower 4 bits
    final uasType = UAType.getByValue(messageData[1] & 0x0F);

    final uasID = decodeField(decodeUASID, messageData, 1, 22);

    final fields = [
      protocolVersion,
      uasType,
      uasID,
    ];

    if (fields.any((f) => f == null)) {
      return null;
    }

    return BasicIDMessage(
      protocolVersion: protocolVersion!,
      rawContent: messageData,
      uaType: uasType!,
      uasID: uasID!,
    );
  }
}
