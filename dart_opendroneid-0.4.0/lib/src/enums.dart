import 'package:collection/collection.dart';

import 'types/odid_message.dart';

enum MessageType {
  basicID(0),
  location(1),
  auth(2),
  selfID(3),
  system(4),
  operatorID(5),
  messagePack(15);

  final int value;

  const MessageType(this.value);

  static MessageType? getByValue(int value) {
    return MessageType.values.firstWhereOrNull((type) => type.value == value);
  }

  Type toODIDMessageType() {
    switch (this) {
      case MessageType.basicID:
        return BasicIDMessage;
      case MessageType.location:
        return LocationMessage;
      case MessageType.auth:
        return AuthMessage;
      case MessageType.selfID:
        return SelfIDMessage;
      case MessageType.system:
        return SystemMessage;
      case MessageType.operatorID:
        return OperatorIDMessage;
      case MessageType.messagePack:
        return MessagePack;
    }
  }
}

enum IDType {
  none(0),
  serialNumber(1),
  CAARegistrationID(2),
  UTMAssignedID(3),
  specificSessionID(4);

  final int value;

  const IDType(this.value);

  static IDType? getByValue(int value) {
    return IDType.values.firstWhereOrNull((type) => type.value == value);
  }
}

enum UAType {
  none(0),
  aeroplane(1),
  helicopterOrMultirotor(2),
  gyroplane(3),
  hybridLift(4),
  ornithopter(5),
  glider(6),
  kite(7),
  freeBalloon(8),
  captiveBalloon(9),
  airship(10),
  freeFallParachute(11),
  rocket(12),
  tetheredPoweredAircraft(13),
  groundObstacle(14),
  other(15);

  final int value;

  const UAType(this.value);

  static UAType? getByValue(int value) {
    return UAType.values.firstWhereOrNull((type) => type.value == value);
  }
}

enum OperationalStatus {
  none(0),
  ground(1),
  airborne(2),
  emergency(3),
  remoteIDSystemFailure(4);

  final int value;

  const OperationalStatus(this.value);

  static OperationalStatus? getByValue(int value) {
    return OperationalStatus.values
        .firstWhereOrNull((type) => type.value == value);
  }
}

enum HorizontalAccuracy {
  unknown(0),
  kilometers_18_52(1),
  kilometers_7_408(2),
  kilometers_3_704(3),
  kilometers_1_852(4),
  meters_926(5),
  meters_555_6(6),
  meters_185_2(7),
  meters_92_6(8),
  meters_30(9),
  meters_10(10),
  meters_3(11),
  meters_1(12);

  final int value;

  const HorizontalAccuracy(this.value);

  static HorizontalAccuracy? getByValue(int value) {
    return HorizontalAccuracy.values
        .firstWhereOrNull((type) => type.value == value);
  }
}

enum VerticalAccuracy {
  unknown(0),
  meters_150(1),
  meters_45(2),
  meters_25(3),
  meters_10(4),
  meters_3(5),
  meters_1(6);

  final int value;

  const VerticalAccuracy(this.value);

  static VerticalAccuracy? getByValue(int value) {
    return VerticalAccuracy.values
        .firstWhereOrNull((type) => type.value == value);
  }
}

/// Same as [VerticalAccuracy], redefined for naming clarity
typedef BaroAltitudeAccuracy = VerticalAccuracy;

enum SpeedAccuracy {
  unknown(0),
  meterPerSecond_10(1),
  meterPerSecond_3(2),
  meterPerSecond_1(3),
  meterPerSecond_0_3(4);

  final int value;

  const SpeedAccuracy(this.value);

  static SpeedAccuracy? getByValue(int value) {
    return SpeedAccuracy.values.firstWhereOrNull((type) => type.value == value);
  }
}

enum HeightType {
  aboveTakeoff(0),
  aboveGroundLevel(1);

  final int value;

  const HeightType(this.value);

  static HeightType? getByValue(int value) {
    return HeightType.values.firstWhereOrNull((type) => type.value == value);
  }
}

enum ClassificationType {
  undeclared(0),
  europeanUnion(1);

  final int value;

  const ClassificationType(this.value);

  static ClassificationType? getByValue(int value) {
    return ClassificationType.values
        .firstWhereOrNull((type) => type.value == value);
  }
}

enum UACategoryEurope {
  undefined(0),
  EUOpen(1),
  EUSpecific(2),
  EUCertified(3);

  final int value;

  const UACategoryEurope(this.value);

  static UACategoryEurope? getByValue(int value) {
    return UACategoryEurope.values
        .firstWhereOrNull((type) => type.value == value);
  }
}

enum UAClassEurope {
  undefined(0),
  EUClass_0(1),
  EUClass_1(2),
  EUClass_2(3),
  EUClass_3(4),
  EUClass_4(5),
  EUClass_5(6),
  EUClass_6(7);

  final int value;

  const UAClassEurope(this.value);

  static UAClassEurope? getByValue(int value) {
    return UAClassEurope.values.firstWhereOrNull((type) => type.value == value);
  }
}

enum OperatorLocationType {
  takeOff(0),
  dynamic(1),
  fixed(2);

  final int value;

  const OperatorLocationType(this.value);

  static OperatorLocationType? getByValue(int value) {
    return OperatorLocationType.values
        .firstWhereOrNull((type) => type.value == value);
  }
}

enum AuthType {
  none(0),
  UASIDSignature(1),
  operatorIDSignature(2),
  messageSetSignature(3),
  networkRemoteID(4),
  specificAuthentication(5),
  privateUse0xA(10),
  privateUse0xB(11),
  privateUse0xC(12),
  privateUse0xD(13),
  privateUse0xE(14),
  privateUse0xF(15);

  final int value;

  const AuthType(this.value);

  static AuthType? getByValue(int value) {
    return AuthType.values.firstWhereOrNull((type) => type.value == value);
  }
}
