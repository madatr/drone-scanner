import 'dart:typed_data';

import 'package:dart_opendroneid/dart_opendroneid.dart';
import 'package:dart_opendroneid/src/parsers/location_message_parser.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'native_parser.dart';
import 'opendroneid_core_library/generated_bindings.dart';
import 'resources/location_messages.dart';

void compareWithReference(
  Uint8List messageData,
  Function(LocationMessage? parsedOutput, ODID_Location_data? referenceOutput)
      comparison,
) {
  using((arena) {
    final dartParser = LocationMessageParser();
    final nativeParser = NativeParser(arena);

    final dartOutput = dartParser.parse(messageData);
    final nativeOutput = nativeParser.parseLocation(messageData);

    comparison(dartOutput, nativeOutput);
  });
}

/// Tests for equality with reference decoder output
// TODO maybe implement as a matcher?
void matchReferenceFields(
  LocationMessage parsedOutput,
  ODID_Location_data referenceOutput,
) {
  expect(parsedOutput.status.value, equals(referenceOutput.Status));
  expect(parsedOutput.heightType.value, equals(referenceOutput.HeightType));

  if (referenceOutput.Direction == INV_DIR) {
    expect(
      parsedOutput.direction,
      isNull,
      reason: 'expected direction to be unknown',
    );
  } else {
    expect(
      parsedOutput.direction,
      equals(referenceOutput.Direction.floor()),
      reason: 'unexpected direction',
    );
  }

  if (referenceOutput.SpeedHorizontal == INV_SPEED_H) {
    expect(
      parsedOutput.horizontalSpeed,
      isNull,
      reason: 'expected horizontal speed to be unknown',
    );
  } else {
    expect(
      parsedOutput.horizontalSpeed,
      closeTo(referenceOutput.SpeedHorizontal, 0.01),
      reason: 'unexpected horizontal speed',
    );
  }
  if (referenceOutput.SpeedVertical == INV_SPEED_V) {
    expect(
      parsedOutput.verticalSpeed,
      isNull,
      reason: 'expected vertical speed to be unknown',
    );
  } else {
    expect(
      parsedOutput.verticalSpeed,
      closeTo(referenceOutput.SpeedVertical, 0.1),
      reason: 'unexpected vertical speed',
    );
  }

  if (referenceOutput.Latitude == 0 && referenceOutput.Longitude == 0) {
    expect(
      parsedOutput.location,
      isNull,
      reason: 'expected location to be unknown',
    );
  } else {
    expect(
      parsedOutput.location,
      isNotNull,
      reason: 'expected location to be known',
    );
    expect(
      parsedOutput.location!.latitude,
      closeTo(referenceOutput.Latitude, 1e-7),
      reason: 'unexpected latitude',
    );
    expect(
      parsedOutput.location!.longitude,
      closeTo(referenceOutput.Longitude, 1e-7),
      reason: 'unexpected longitude',
    );
  }

  if (referenceOutput.AltitudeBaro == INV_ALT) {
    expect(
      parsedOutput.altitudePressure,
      isNull,
      reason: 'expected pressure altitude to be unknown',
    );
  } else {
    expect(
      parsedOutput.altitudePressure,
      closeTo(referenceOutput.AltitudeBaro, 0.1),
      reason: 'unexpected pressure altitude',
    );
  }

  if (referenceOutput.AltitudeGeo == INV_ALT) {
    expect(
      parsedOutput.altitudeGeodetic,
      isNull,
      reason: 'expected geodetic altitude to be unknown',
    );
  } else {
    expect(
      parsedOutput.altitudeGeodetic,
      closeTo(referenceOutput.AltitudeGeo, 0.1),
      reason: 'unexpected geodetic altitude',
    );
  }

  // FIXME float comparison? check that it works correctly
  if (referenceOutput.Height == INV_ALT) {
    expect(
      parsedOutput.height,
      isNull,
      reason: 'expected height to be unknown',
    );
  } else {
    expect(
      parsedOutput.height,
      closeTo(referenceOutput.Height, 0.1),
      reason: 'unexpected height',
    );
  }

  expect(
    parsedOutput.verticalAccuracy.value,
    equals(referenceOutput.VertAccuracy),
    reason: 'unexpected vertical accuracy',
  );
  expect(
    parsedOutput.horizontalAccuracy.value,
    equals(referenceOutput.HorizAccuracy),
    reason: 'unexpected horizontal accuracy',
  );
  expect(
    parsedOutput.baroAltitudeAccuracy.value,
    equals(referenceOutput.BaroAccuracy),
    reason: 'unexpected barometric altitude accuracy',
  );
  expect(
    parsedOutput.speedAccuracy.value,
    equals(referenceOutput.SpeedAccuracy),
    reason: 'unexpected speed accuracy',
  );

  if (referenceOutput.TimeStamp == INV_TIMESTAMP) {
    expect(
      parsedOutput.timestamp,
      isNull,
      reason: 'expected timestamp to be unknown',
    );
  } else {
    expect(
      parsedOutput.timestamp,
      isNotNull,
      reason: 'expected timestamp to be known',
    );
    expect(
      parsedOutput.timestamp!.inMilliseconds,
      closeTo(referenceOutput.TimeStamp * 1000, 0.1),
      reason: 'unexpected timestamp',
    );
  }

  if (referenceOutput.TSAccuracy ==
      ODID_Timestamp_accuracy.ODID_TIME_ACC_UNKNOWN) {
    expect(
      parsedOutput.timestampAccuracy,
      isNull,
      reason: 'expected timestamp accuracy to be unknown',
    );
  } else {
    expect(
      parsedOutput.timestampAccuracy,
      isNotNull,
      reason: 'expected timestamp accuracy to be known',
    );
    expect(
      parsedOutput.timestampAccuracy!.inMilliseconds / 100,
      equals(referenceOutput.TSAccuracy),
      reason: 'unexpected timestamp accuracy',
    );
  }
}

void main() {
  group('Correct message parsing tests', () {
    test('parse correct location message', () {
      final Uint8List messageData = LocationMessages.correctMessage;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse E/W direction < 180', () {
      final messageData = LocationMessages.directionLessThan180;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse speed multiplier 0.25x correctly', () {
      final Uint8List messageData = LocationMessages.speedMultiplier025;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse positive vertical speed', () {
      final Uint8List messageData = LocationMessages.positiveVerticalSpeed;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse negative latitude', () {
      final Uint8List messageData = LocationMessages.negativeLatitude;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse negative longitude', () {
      final Uint8List messageData = LocationMessages.negativeLongitude;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse negative pressure altitude', () {
      final Uint8List messageData = LocationMessages.negativePressureAltitude;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse positive geodetic altitude', () {
      final Uint8List messageData = LocationMessages.positiveGeodeticAltitude;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse negative height', () {
      final Uint8List messageData = LocationMessages.negativeHeight;
      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse <25m vertical accuracy', () {
      final Uint8List messageData =
          LocationMessages.verticalAccuracyLessThan25Meters;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse <7.408km horizontal accuracy', () {
      final Uint8List messageData =
          LocationMessages.horizontalAccuracyLessThan7Kilometers;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse <150m baro altitude accuracy', () {
      final Uint8List messageData =
          LocationMessages.baroAltitudeLessThan150Meters;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse <0.3m/s speed accuracy', () {
      final Uint8List messageData = LocationMessages.speedAccLessThan03Mps;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse timestamp 59m after UTC hour', () {
      final Uint8List messageData = LocationMessages.timestamp59Minutes;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse 1.2s timestamp accuracy', () {
      final Uint8List messageData =
          LocationMessages.timestampAcc1200Milliseconds;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });
  });

  group('special value tests', () {
    test('unknown track direction', () {
      final Uint8List messageData = LocationMessages.unknownTrackDirection;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('unknown speed', () {
      final Uint8List messageData = LocationMessages.unknownSpeed;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('unknown vertical speed', () {
      final Uint8List messageData = LocationMessages.unknownVerticalSpeed;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('unknown location', () {
      final Uint8List messageData = LocationMessages.unknownLocation;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('unknown pressure altitude', () {
      final Uint8List messageData = LocationMessages.unknownPressureAltitude;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('unknown geodetic altitude', () {
      final Uint8List messageData = LocationMessages.unknownGeodeticAltitude;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('unknown height', () {
      final Uint8List messageData = LocationMessages.unknownHeight;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('unknown timestamp', () {
      final Uint8List messageData = LocationMessages.unknownTimestamp;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('unknown timestamp accuracy', () {
      final Uint8List messageData = LocationMessages.unknownTimestampAccuracy;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });
  });

  group('Captured correct message tests', () {
    test('correct captured message #1', () {
      final Uint8List messageData = LocationMessages.correctCapturedMessage1;
      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('correct captured message #2', () {
      final Uint8List messageData = LocationMessages.correctCapturedMessage2;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('correct captured message #3', () {
      final Uint8List messageData = LocationMessages.correctCapturedMessage3;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('correct captured message #4', () {
      final Uint8List messageData = LocationMessages.correctCapturedMessage4;
      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('correct captured message #5', () {
      final Uint8List messageData = LocationMessages.correctCapturedMessage5;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });
  });
}
