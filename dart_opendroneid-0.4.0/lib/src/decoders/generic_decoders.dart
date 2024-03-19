import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../constants.dart';
import '../types.dart';

double? decodeAltitude(ByteData input) {
  final value = input.getUint16(0, Endian.little);

  if (value == 0) {
    return null;
  }

  return (value * 0.5) - 1000;
}

Location? decodeLocation(ByteData input) {
  final latitude =
      decodeCoordinate(ByteData.view(input.buffer, input.offsetInBytes, 4));
  final longitude =
      decodeCoordinate(ByteData.view(input.buffer, input.offsetInBytes + 4, 4));

  // Both lat and lon = 0 means unknown location
  if (latitude == 0 && longitude == 0) {
    return null;
  }

  return Location(
    latitude: latitude!,
    longitude: longitude!,
  );
}

double? decodeCoordinate(ByteData input) {
  final value = input.getInt32(0, Endian.little);

  return value * latLonMultiplier;
}

String? decodeString(ByteData input) {
  final value = utf8.decode(
      input.buffer.asUint8List(input.offsetInBytes, input.lengthInBytes));

  return value.contains('\u0000') ? value.split('\u0000').firstOrNull! : value;
}

Uint8List decodeRaw(ByteData input) {
  return input.buffer.asUint8List(input.offsetInBytes, input.lengthInBytes);
}

int decodeProtocolVersion(ByteData input) {
  return input.getInt8(0) & 0x0F;
}

DateTime? decodeODIDEpochTimestamp(ByteData input) {
  final value = input.getUint32(0, Endian.little);
  final unixMilliseconds = (value + odidEpochOffset) * 1000;

  return DateTime.fromMillisecondsSinceEpoch(unixMilliseconds, isUtc: true);
}
