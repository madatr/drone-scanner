import 'dart:typed_data';

import '../constants.dart';
import '../types.dart';

int? decodeAreaCount(ByteData input) {
  return input.getUint16(0, Endian.little);
}

int? decodeAreaRadius(ByteData input) {
  return input.getUint8(0) * areaRadiusMultiplier;
}

UAClassification? decodeUAClassification(ByteData input) {
  final classificationType =
      ClassificationType.getByValue((input.getUint8(0) & 0x0C) >> 2);
  final classificationData = ByteData.sublistView(input, 16, 17);

  return switch (classificationType) {
    ClassificationType.undeclared => UAClassificationUndeclared(),
    ClassificationType.europeanUnion =>
      _decodeEUClassification(classificationData),
    _ => null
  };
}

UAClassificationEurope? _decodeEUClassification(ByteData input) {
  final uaCategory =
      UACategoryEurope.getByValue((input.getUint8(0) & 0xF0) >> 4);
  final uaClass = UAClassEurope.getByValue(input.getUint8(0) & 0x0F);

  if (uaCategory == null || uaClass == null) {
    return null;
  }

  return UAClassificationEurope(
    uaCategoryEurope: uaCategory,
    uaClassEurope: uaClass,
  );
}
