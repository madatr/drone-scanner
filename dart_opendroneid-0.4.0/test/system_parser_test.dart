import 'dart:typed_data';

import 'package:dart_opendroneid/dart_opendroneid.dart';
import 'package:dart_opendroneid/src/parsers/system_message_parser.dart';
import 'package:dart_opendroneid/src/types/ua_classification.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'native_parser.dart';
import 'opendroneid_core_library/generated_bindings.dart';
import 'resources/system_messages.dart';

void compareWithReference(
  Uint8List messageData,
  Function(SystemMessage? parsedOutput, ODID_System_data? referenceOutput)
      comparison,
) {
  using((arena) {
    final dartParser = SystemMessageParser();
    final nativeParser = NativeParser(arena);

    final dartOutput = dartParser.parse(messageData);
    final nativeOutput = nativeParser.parseSystem(messageData);

    comparison(dartOutput, nativeOutput);
  });
}

/// Tests for equality with reference decoder output
// TODO maybe implement as a matcher?
void matchReferenceFields(
  SystemMessage parsedOutput,
  ODID_System_data referenceOutput,
) {
  expect(
    parsedOutput.operatorLocationType.value,
    equals(referenceOutput.OperatorLocationType),
    reason: 'unexpected operator location type',
  );

  if (referenceOutput.OperatorLatitude == 0 &&
      referenceOutput.OperatorLongitude == 0) {
    expect(
      parsedOutput.operatorLocation,
      isNull,
      reason: 'expected operator location to be unknown',
    );
  } else {
    expect(
      parsedOutput.operatorLocation,
      isNotNull,
      reason: 'expected operator location to be known',
    );
    expect(
      parsedOutput.operatorLocation!.latitude,
      closeTo(referenceOutput.OperatorLatitude, 1e-7),
      reason: 'unexpected operator latitude',
    );
    expect(
      parsedOutput.operatorLocation!.longitude,
      closeTo(referenceOutput.OperatorLongitude, 1e-7),
      reason: 'unexpected operator longitude',
    );
  }

  expect(
    parsedOutput.areaCount,
    equals(referenceOutput.AreaCount),
    reason: 'unexpected area count',
  );
  expect(
    parsedOutput.areaRadius,
    equals(referenceOutput.AreaRadius),
    reason: 'unexpected area radius',
  );

  if (referenceOutput.AreaCeiling == INV_ALT) {
    expect(
      parsedOutput.areaCeiling,
      isNull,
      reason: 'expected area ceiling to be unknown',
    );
  } else {
    expect(
      parsedOutput.areaCeiling,
      closeTo(referenceOutput.AreaCeiling, 0.1),
      reason: 'unexpected area ceiling',
    );
  }

  if (referenceOutput.AreaFloor == INV_ALT) {
    expect(
      parsedOutput.areaFloor,
      isNull,
      reason: 'expected area floor to be unknown',
    );
  } else {
    expect(
      parsedOutput.areaFloor,
      closeTo(referenceOutput.AreaFloor, 0.1),
      reason: 'unexpected area floor',
    );
  }

  expect(
    parsedOutput.uaClassification.value,
    equals(referenceOutput.ClassificationType),
    reason: 'unexpected UA classification type',
  );

  if (referenceOutput.ClassificationType ==
      ODID_classification_type.ODID_CLASSIFICATION_TYPE_EU) {
    expect(
      parsedOutput.uaClassification,
      isA<UAClassificationEurope>(),
      reason: 'unexpected UA classification',
    );

    final uaClassification =
        parsedOutput.uaClassification as UAClassificationEurope;

    expect(
      uaClassification.uaCategoryEurope.value,
      equals(referenceOutput.CategoryEU),
      reason: 'unexpected UA category (EU)',
    );
    expect(
      uaClassification.uaClassEurope.value,
      equals(referenceOutput.ClassEU),
      reason: 'unexpected UA class (EU)',
    );
  } else if (referenceOutput.ClassificationType ==
      ODID_classification_type.ODID_CLASSIFICATION_TYPE_UNDECLARED) {
    expect(
      parsedOutput.uaClassification,
      isA<UAClassificationUndeclared>(),
      reason: 'UA classification not \'undeclared\'',
    );
  }

  if (referenceOutput.OperatorAltitudeGeo == INV_ALT) {
    expect(
      parsedOutput.operatorAltitude,
      isNull,
      reason: 'expected operator altitude to be unknown',
    );
  } else {
    expect(
      parsedOutput.operatorAltitude,
      closeTo(referenceOutput.OperatorAltitudeGeo, 0.1),
      reason: 'unexpected operator altitude',
    );
  }

  expect(
    (parsedOutput.timestamp.millisecondsSinceEpoch / 1000) - 1546300800,
    equals(referenceOutput.Timestamp),
    reason: 'unexpected timestamp',
  );
}

void main() {
  group('Correct message parsing tests', () {
    test('parse correct system message #1', () {
      final Uint8List messageData = SystemMessages.correctMessage1;

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

    test('parse correct system message #2', () {
      final Uint8List messageData = SystemMessages.correctMessage2;

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
      final Uint8List messageData = SystemMessages.correctCapturedMessage1;

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
      final Uint8List messageData = SystemMessages.correctCapturedMessage2;

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
      final Uint8List messageData = SystemMessages.correctCapturedMessage3;

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
      final Uint8List messageData = SystemMessages.correctCapturedMessage4;

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
      final Uint8List messageData = SystemMessages.correctCapturedMessage5;

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
