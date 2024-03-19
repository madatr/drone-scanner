import 'dart:typed_data';

import '../enums.dart';
import 'auth_data.dart';
import 'description_type.dart';
import 'operator_id_type.dart';
import 'ua_classification.dart';
import 'uas_id.dart';

sealed class ODIDMessage {
  final int protocolVersion;
  final Uint8List rawContent;

  const ODIDMessage({
    required this.protocolVersion,
    required this.rawContent,
  });

  String toHexString() =>
      rawContent.map((byte) => _byteHexString(byte)).join(' ');

  String _byteHexString(int byte) =>
      '0x${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}';
}

class BasicIDMessage extends ODIDMessage {
  final UASID uasID;
  final UAType uaType;

  const BasicIDMessage({
    required super.protocolVersion,
    required super.rawContent,
    required this.uasID,
    required this.uaType,
  });

  @override
  String toString() => 'BasicIDMessage {'
      'UAS ID: $uasID'
      'UA Type: $uaType, '
      '}';
}

class Location {
  final double latitude;
  final double longitude;

  const Location({
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => 'Location {'
      'Latitude: $latitude, '
      'Longitude: $longitude'
      '}';
}

class LocationMessage extends ODIDMessage {
  final OperationalStatus status;
  final HeightType heightType;

  final int? direction;

  final double? horizontalSpeed;
  final double? verticalSpeed;

  final Location? location;

  final double? altitudePressure;
  final double? altitudeGeodetic;

  final double? height;

  final VerticalAccuracy verticalAccuracy;
  final HorizontalAccuracy horizontalAccuracy;

  final BaroAltitudeAccuracy baroAltitudeAccuracy;
  final SpeedAccuracy speedAccuracy;

  final Duration? timestamp;

  DateTime? getAbsoluteTimestamp(DateTime receivedOn) {
    if (timestamp == null) {
      return null;
    }

    final utcOffset = receivedOn.toUtc();

    return DateTime(
      utcOffset.year,
      utcOffset.month,
      utcOffset.day,
      utcOffset.hour,
    ).add(timestamp!).toUtc();
  }

  final Duration? timestampAccuracy;

  const LocationMessage({
    required super.protocolVersion,
    required super.rawContent,
    required this.status,
    required this.heightType,
    required this.direction,
    required this.horizontalSpeed,
    required this.verticalSpeed,
    required this.location,
    required this.altitudePressure,
    required this.altitudeGeodetic,
    required this.height,
    required this.verticalAccuracy,
    required this.horizontalAccuracy,
    required this.baroAltitudeAccuracy,
    required this.speedAccuracy,
    required this.timestamp,
    required this.timestampAccuracy,
  });

  @override
  String toString() => 'LocationMessage {'
      'Status: $status, '
      'Height Type: $heightType, '
      'Direction: $direction deg, '
      'Horizontal Speed: $horizontalSpeed m/s, '
      'Vertical Speed: $verticalSpeed m/s, '
      'Location: $location, '
      'Pressure Altitude: $altitudePressure m, '
      'Geodetic Altitude: $altitudeGeodetic m, '
      'Height: $height m, '
      'Vertical Accuracy: $verticalAccuracy m, '
      'Horizontal Accuracy: $horizontalAccuracy, '
      'Baro Altitude Accuracy: $baroAltitudeAccuracy, '
      'Speed Accuracy: $speedAccuracy, '
      'Timestamp: $timestamp, '
      'Timestamp Accuracy: $timestampAccuracy s'
      '}';
}

class OperatorIDMessage extends ODIDMessage {
  final OperatorIDType operatorIDType;
  final String operatorID;

  const OperatorIDMessage({
    required super.protocolVersion,
    required super.rawContent,
    required this.operatorIDType,
    required this.operatorID,
  });

  @override
  String toString() => 'OperatorIDMessage {'
      'Operator ID Type: $operatorIDType,'
      'Operator ID: $operatorID'
      '}';
}

class SelfIDMessage extends ODIDMessage {
  final DescriptionType descriptionType;
  final String description;

  const SelfIDMessage({
    required super.protocolVersion,
    required super.rawContent,
    required this.descriptionType,
    required this.description,
  });

  @override
  String toString() => 'SelfIDMessage {'
      'Description Type: $descriptionType, '
      'Description: $description'
      '}';
}

class SystemMessage extends ODIDMessage {
  final OperatorLocationType operatorLocationType;
  final Location? operatorLocation;
  final double? operatorAltitude;

  // TODO group area info under one class?
  final int areaCount;
  final int areaRadius;
  final double? areaCeiling;
  final double? areaFloor;

  final UAClassification uaClassification;

  final DateTime timestamp;

  SystemMessage({
    required super.protocolVersion,
    required super.rawContent,
    required this.operatorLocationType,
    required this.operatorLocation,
    required this.operatorAltitude,
    required this.areaCount,
    required this.areaRadius,
    required this.areaCeiling,
    required this.areaFloor,
    required this.uaClassification,
    required this.timestamp,
  });

  @override
  String toString() => 'SystemMessage {'
      'Operator Location Type: $operatorLocationType, '
      'Operator Location: $operatorLocation, '
      'Operator Altitude: $operatorAltitude m, '
      'Area Count: $areaCount, '
      'Area Radius: $areaRadius m, '
      'Area Ceiling: $areaCeiling m, '
      'Area Floor: $areaFloor m, '
      'UA Classification: $uaClassification, '
      'Timestamp: $timestamp'
      '}';
}

/// The [AuthMessage] can have two different formats:
/// - When [authPageNumber] equals 0, the fields [lastAuthPageIndex],
///   [authLength] and [timestamp] are present.
///   The size of [AuthData] is maximum 17 bytes (maxAuthPageZeroSize).
///
/// - When [authPageNumber] equals 1 through (maxAuthDataPages - 1),
///   [lastAuthPageIndex], [authLength] and [timestamp] are not present.
///
/// - For pages 1 to [lastAuthPageIndex], the size of [AuthData] is maximum
///   23 bytes (maxAuthPageNonZeroSize).
///
/// Unused bytes in the [AuthData] field must be filled with NULLs (i.e. 0x00).
///
/// Since the [authLength] field is one byte, the amount of data bytes
/// transmitted over multiple pages of [AuthData] can only be up to 255.
class AuthMessage extends ODIDMessage {
  final AuthType authType;
  final int authPageNumber;
  final int? lastAuthPageIndex;
  final int? authLength;
  final DateTime? timestamp;
  final AuthData authData;

  const AuthMessage({
    required super.protocolVersion,
    required super.rawContent,
    required this.authType,
    required this.authPageNumber,
    required this.lastAuthPageIndex,
    required this.authLength,
    required this.timestamp,
    required this.authData,
  });

  @override
  String toString() => 'AuthMessage {'
      'Auth Type: $authType, '
      'Auth Page Number: $authPageNumber, '
      'Last Auth Page Index: $lastAuthPageIndex, '
      'Auth Length: $authLength, '
      'Auth Data: $authData, '
      'Timestamp: $timestamp'
      '}';
}

class MessagePack extends ODIDMessage {
  final List<ODIDMessage> messages;

  const MessagePack({
    required super.protocolVersion,
    required super.rawContent,
    required this.messages,
  });

  @override
  String toString() =>
      'MessagePack [${messages.map((m) => m.toString()).join(", ")}]';
}
