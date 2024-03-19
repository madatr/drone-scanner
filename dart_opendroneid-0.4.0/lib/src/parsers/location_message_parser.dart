import 'dart:typed_data';

import '../decoders/decoders.dart';
import '../types.dart';
import 'odid_message_parser.dart';

class LocationMessageParser implements ODIDMessageParser {
  const LocationMessageParser();

  @override
  LocationMessage? parse(Uint8List messageData) {
    final protocolVersion =
        decodeField(decodeProtocolVersion, messageData, 0, 1);

    final status = OperationalStatus.getByValue((messageData[1] & 0xF0) >> 4);
    final heightType = HeightType.getByValue((messageData[1] & 0x04) >> 2);
    final direction = decodeField(decodeDirection, messageData, 1, 3);

    // Flags needed, 1st byte included in passed data
    final horizontalSpeed =
        decodeField(decodeHorizontalSpeed, messageData, 1, 4);
    final verticalSpeed = decodeField(decodeVerticalSpeed, messageData, 4, 5);
    final location = decodeField(decodeLocation, messageData, 5, 13);

    final altitudePressure = decodeField(decodeAltitude, messageData, 13, 15);
    final altitudeGeodetic = decodeField(decodeAltitude, messageData, 15, 17);
    final height = decodeField(decodeAltitude, messageData, 17, 19);
    final verticalAccuracy =
        VerticalAccuracy.getByValue((messageData[19] & 0xF0) >> 4);
    final horizontalAccuracy =
        HorizontalAccuracy.getByValue(messageData[19] & 0x0F);
    final baroAltitudeAccuracy =
        BaroAltitudeAccuracy.getByValue((messageData[20] & 0xF0) >> 4);
    final speedAccuracy = SpeedAccuracy.getByValue(messageData[20] & 0x0F);
    final timestamp = decodeField(decodeLocationTimestamp, messageData, 21, 23);
    final timestampAccuracy =
        decodeField(decodeTimestampAccuracy, messageData, 23, 24);

    final fields = [
      protocolVersion,
      status,
      heightType,
      verticalAccuracy,
      horizontalAccuracy,
      baroAltitudeAccuracy,
      speedAccuracy,
    ];

    // Return if any field is missing
    if (fields.any((f) => f == null)) {
      return null;
    }

    return LocationMessage(
      protocolVersion: protocolVersion!,
      rawContent: messageData,
      status: status!,
      heightType: heightType!,
      direction: direction,
      horizontalSpeed: horizontalSpeed,
      verticalSpeed: verticalSpeed,
      location: location,
      altitudePressure: altitudePressure,
      altitudeGeodetic: altitudeGeodetic,
      height: height,
      verticalAccuracy: verticalAccuracy!,
      horizontalAccuracy: horizontalAccuracy!,
      baroAltitudeAccuracy: baroAltitudeAccuracy!,
      speedAccuracy: speedAccuracy!,
      timestamp: timestamp,
      timestampAccuracy: timestampAccuracy,
    );
  }
}
