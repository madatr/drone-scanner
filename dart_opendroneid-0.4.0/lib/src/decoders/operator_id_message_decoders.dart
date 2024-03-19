import 'dart:typed_data';

import '../types/operator_id_type.dart';

OperatorIDType? decodeOperatorIDType(ByteData input) {
  final value = input.getUint8(0);

  return switch (value) {
    0 => OperatorIDTypeOperatorID(),
    >= 201 => OperatorIDTypePrivate(value: value),
    _ => null,
  };
}
