import 'dart:typed_data';

import '../enums.dart';
import '../types/uas_id.dart';
import 'generic_decoders.dart';

UASID? decodeUASID(ByteData input) {
  final idType = IDType.getByValue((input.getUint8(0) & 0xF0) >> 4);
  final id = ByteData.sublistView(input, 1, 21);

  return switch (idType) {
    IDType.none => IDNone(),
    IDType.serialNumber => SerialNumber(serialNumber: decodeString(id)!),
    IDType.CAARegistrationID =>
      CAARegistrationID(registrationID: decodeString(id)!),
    IDType.UTMAssignedID => UTMAssignedID(id: decodeRaw(id)),
    IDType.specificSessionID => SpecificSessionID(id: decodeRaw(id)),
    null => null
  };
}
