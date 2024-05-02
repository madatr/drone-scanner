import 'dart:convert';
import 'dart:typed_data';

import '../enums.dart';

abstract class UASID {
  final IDType type;

  const UASID(this.type);

  Map<String, dynamic> toJson();

  String? map(
      {required Null Function(dynamic _) none,
      required Function(dynamic serialNumber) serialNumber,
      required Function(dynamic registrationID) CAARegistrationID,
      required Function(dynamic id) UTMAssignedID,
      required Function(dynamic id) specificSessionID}) {}
}

class IDNone extends UASID {
  const IDNone() : super(IDType.none);

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'none'};
  }

  @override
  String toString() {
    return 'IDNone{}';
  }
}

class SerialNumber extends UASID {
  final String serialNumber;

  SerialNumber({
    required this.serialNumber,
  }) : super(IDType.serialNumber);

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'serialNumber', 'serialNumber': serialNumber};
  }

  @override
  String toString() {
    return 'SerialNumber{serialNumber: $serialNumber}';
  }
}

class CAARegistrationID extends UASID {
  final String registrationID;

  const CAARegistrationID({
    required this.registrationID,
  }) : super(IDType.CAARegistrationID);

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'CAARegistrationID', 'registrationID': registrationID};
  }

  @override
  String toString() {
    return 'CAARegistrationID{registrationID: $registrationID}';
  }
}

/// Representation of a UTM Assigned ID if operating within a UTM system
/// (128-bit UUID) binary encoded, Network Byte Order.
class UTMAssignedID extends UASID {
  final Uint8List id;

  const UTMAssignedID({
    required this.id,
  }) : super(IDType.UTMAssignedID);

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'UTMAssignedID', 'id': base64Encode(id)};
  }

  @override
  String toString() {
    return 'UTMAssignedID{id: $id}';
  }
}

/// Specific Session ID according to the registered Session ID Type
class SpecificSessionID extends UASID {
  final Uint8List id;

  const SpecificSessionID({
    required this.id,
  }) : super(IDType.specificSessionID);

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'specificSessionID', 'id': base64Encode(id)};
  }

  @override
  String toString() {
    return 'SpecificSessionID{id: $id}';
  }
}
