import 'dart:typed_data';

import '../decoders/decoders.dart';
import '../types.dart';
import 'odid_message_parser.dart';

class OperatorIDMessageParser implements ODIDMessageParser {
  @override
  OperatorIDMessage? parse(Uint8List messageData) {
    final protocolVersion = decodeField(decodeProtocolVersion, messageData, 0, 1);

    final operatorIDType = decodeField(decodeOperatorIDType, messageData, 1, 2);
    final operatorID = decodeField(decodeString, messageData, 2, 22);

    final fields = [
      protocolVersion,
      operatorIDType,
      operatorID,
    ];

    if (fields.any((f) => f == null)) {
      return null;
    }

    return OperatorIDMessage(
      protocolVersion: protocolVersion!,
      rawContent: messageData,
      operatorIDType: operatorIDType!,
      operatorID: operatorID!,
    );
  }

  const OperatorIDMessageParser();
}
