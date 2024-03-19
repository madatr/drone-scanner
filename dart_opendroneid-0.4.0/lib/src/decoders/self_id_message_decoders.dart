import 'dart:typed_data';

import '../types/description_type.dart';

DescriptionType? decodeDescriptionType(ByteData input) {
  final value = input.getUint8(0);

  return switch (value) {
    0 => DescriptionTypeText(),
    1 => DescriptionTypeEmergency(),
    2 => DescriptionTypeExtendedStatus(),
    >= 201 => DescriptionTypePrivate(value: value),
    _ => null
  };
}
