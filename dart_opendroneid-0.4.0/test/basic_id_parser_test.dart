import 'dart:typed_data';

import 'package:dart_opendroneid/dart_opendroneid.dart';
import 'package:dart_opendroneid/src/parsers/basic_id_message_parser.dart';
import 'package:dart_opendroneid/src/types/uas_id.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'native_parser.dart';
import 'opendroneid_core_library/generated_bindings.dart';
import 'resources/basic_id_messages.dart';

void compareWithReference(
  Uint8List messageData,
  Function(BasicIDMessage? parsedOutput, ODID_BasicID_data? referenceOutput)
      comparison,
) {
  using((arena) {
    final dartParser = BasicIDMessageParser();
    final nativeParser = NativeParser(arena);

    final dartOutput = dartParser.parse(messageData);
    final nativeOutput = nativeParser.parseBasicID(messageData);

    comparison(dartOutput, nativeOutput);
  });
}

/// Tests for equality with reference decoder output
// TODO maybe implement as a matcher?
void matchReferenceFields(
  BasicIDMessage parsedOutput,
  ODID_BasicID_data referenceOutput,
) {
  expect(
    parsedOutput.uasID.type.value,
    equals(referenceOutput.IDType),
    reason: 'unexpected ID type',
  );

  switch (parsedOutput.uasID) {
    case IDNone():
      break;
    case SerialNumber(serialNumber: final sn):
      expect(
        sn,
        equals(referenceOutput.UASID.extractString(20)),
        reason: 'unexpected UAS serial number',
      );
    case CAARegistrationID(registrationID: final id):
      expect(
        id,
        equals(referenceOutput.UASID.extractString(20)),
        reason: 'unexpected UAS registration ID',
      );
    case UTMAssignedID(id: final id):
      expect(
        id,
        equals(referenceOutput.UASID.extractBytes(20)),
        reason: 'unexpected UAS UTM assigned ID',
      );
    case SpecificSessionID(id: final id):
      expect(
        id,
        equals(referenceOutput.UASID.extractBytes(20)),
        reason: 'unexpected UAS specific session ID',
      );
  }

  expect(
    parsedOutput.uaType.value,
    equals(referenceOutput.UAType),
    reason: 'unexpected UA type',
  );
}

void main() {
  group('Correct message parsing tests', () {
    test('parse correct basic ID message', () {
      final messageData = BasicIDMessages.correctMessage;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse arbitrary ID type', () {
      final messageData = BasicIDMessages.arbitraryUasId;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('parse fully populated ID filed (arbitrary bytes)', () {
      final messageData = BasicIDMessages.arbitraryUasIdFull;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });
  });

  group('Invalid messages rejection tests', () {
    test('reject invalid ID type', () {
      final Uint8List messageData = BasicIDMessages.invalidIdType;

      expect(messageData.length, equals(maxMessageSize));

      // Expect parsing to fail on invalid ID type - native impl parses this
      expect(BasicIDMessageParser().parse(messageData), isNull);
    });
  });

  group('Captured correct message tests', () {
    test('correct captured message #1', () {
      final Uint8List messageData = BasicIDMessages.correctCapturedMessage1;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('correct captured message #2', () {
      final Uint8List messageData = BasicIDMessages.correctCapturedMessage2;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('correct captured message #3', () {
      final messageData = BasicIDMessages.correctCapturedMessage3;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('correct captured message #4', () {
      final messageData = BasicIDMessages.correctCapturedMessage4;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('correct captured message #5', () {
      final messageData = BasicIDMessages.correctCapturedMessage5;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });
  });
}
