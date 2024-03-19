import 'dart:typed_data';

import '../constants.dart';

int? decodeDirection(ByteData input) {
  // Direction encoded in 2nd lowest bit of flags
  final eastWestBit = (input.getUint8(0) & 0x02) >> 1;
  final value = input.getUint8(1);

  final result = eastWestBit == 0 ? value : value + 180;

  if (result == 361) {
    return null;
  }

  return result;
}

double? decodeHorizontalSpeed(ByteData input) {
  final multiplierBit = input.getUint8(0) & 0x01;
  final value = input.getUint8(2);

  if (multiplierBit == 1 && value == 255) {
    return null;
  }

  // 255 m/s means unknown value
  if (multiplierBit == 0) {
    return value * 0.25;
  }

  return (value * 0.75) + (255 * 0.25);
}

double? decodeVerticalSpeed(ByteData input) {
  final value = input.getInt8(0);

  // 63 m/s (126) means unknown value
  if (value == 126) {
    return null;
  }

  return value * verticalSpeedMultiplier;
}

Duration? decodeLocationTimestamp(ByteData input) {
  if (input.getUint8(0) == 0xFF && input.getUint8(1) == 0xFF) {
    return null;
  }

  final value = input.getUint16(0, Endian.little);

  return Duration(milliseconds: value * 100);
}

Duration? decodeTimestampAccuracy(ByteData input) {
  final value = input.getUint8(0) & 0x0F;

  if (value == 0) {
    return null;
  }

  return Duration(milliseconds: value * 100);
}
