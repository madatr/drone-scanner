import 'dart:typed_data';

import '../decoders/decoders.dart';
import '../types.dart';
import 'odid_message_parser.dart';

class SystemMessageParser implements ODIDMessageParser {
  const SystemMessageParser();

  @override
  SystemMessage? parse(Uint8List messageData) {
    final protocolVersion =
        decodeField(decodeProtocolVersion, messageData, 0, 1);

    final operatorLocationType =
        OperatorLocationType.getByValue(messageData[1] & 0x03);
    final operatorLocation = decodeField(decodeLocation, messageData, 2, 10);
    final operatorAltitude = decodeField(decodeAltitude, messageData, 18, 20);
    final areaCount = decodeField(decodeAreaCount, messageData, 10, 12);
    final areaRadius = decodeField(decodeAreaRadius, messageData, 12, 13);
    final areaCeiling = decodeField(decodeAltitude, messageData, 13, 15);
    final areaFloor = decodeField(decodeAltitude, messageData, 15, 17);

    // Flags needed, 1st byte included in passed data
    final uaClassification =
        decodeField(decodeUAClassification, messageData, 1, 18);
    final timestamp =
        decodeField(decodeODIDEpochTimestamp, messageData, 20, 24);

    final fields = [
      protocolVersion,
      operatorLocationType,
      areaCount,
      areaRadius,
      uaClassification,
      timestamp,
    ];

    if (fields.any((f) => f == null)) {
      return null;
    }

    return SystemMessage(
      protocolVersion: protocolVersion!,
      rawContent: messageData,
      operatorLocationType: operatorLocationType!,
      operatorLocation: operatorLocation,
      operatorAltitude: operatorAltitude,
      areaCount: areaCount!,
      areaRadius: areaRadius!,
      areaCeiling: areaCeiling,
      areaFloor: areaFloor,
      uaClassification: uaClassification!,
      timestamp: timestamp!,
    );
  }
}
