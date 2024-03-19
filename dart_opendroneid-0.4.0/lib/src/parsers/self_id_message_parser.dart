import 'dart:typed_data';

import '../decoders/decoders.dart';
import '../types.dart';
import 'odid_message_parser.dart';

class SelfIDMessageParser implements ODIDMessageParser {
  @override
  SelfIDMessage? parse(Uint8List messageData) {
    final protocolVersion = decodeField(decodeProtocolVersion, messageData, 0, 1);

    final descriptionType =
        decodeField(decodeDescriptionType, messageData, 1, 2);
    final description = decodeField(decodeString, messageData, 2, 25);

    final fields = [
      protocolVersion,
      descriptionType,
      description,
    ];

    if (fields.any((f) => f == null)) {
      return null;
    }

    return SelfIDMessage(
      protocolVersion: protocolVersion!,
      rawContent: messageData,
      descriptionType: descriptionType!,
      description: description!,
    );
  }

  const SelfIDMessageParser();
}
