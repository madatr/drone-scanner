import 'dart:typed_data';

import 'package:dart_opendroneid/dart_opendroneid.dart';
import 'package:dart_opendroneid/src/parsers/operator_id_message_parser.dart';
import 'package:dart_opendroneid/src/types/operator_id_type.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'native_parser.dart';
import 'opendroneid_core_library/generated_bindings.dart';
import 'resources/operator_id_messages.dart';

void compareWithReference(
  Uint8List messageData,
  Function(OperatorIDMessage? parsedOutput,
          ODID_OperatorID_data? referenceOutput)
      comparison,
) {
  using((arena) {
    final dartParser = OperatorIDMessageParser();
    final nativeParser = NativeParser(arena);

    final dartOutput = dartParser.parse(messageData);
    final nativeOutput = nativeParser.parseOperatorID(messageData);

    comparison(dartOutput, nativeOutput);
  });
}

/// Tests for equality with reference decoder output
// TODO maybe implement as a matcher?
void matchReferenceFields(
  OperatorIDMessage parsedOutput,
  ODID_OperatorID_data referenceOutput,
) {
  expect(
    parsedOutput.operatorIDType.value,
    equals(referenceOutput.OperatorIdType),
    reason: 'unexpected operator ID type',
  );
  // FIXME extractString length should be unbounded?
  expect(
    parsedOutput.operatorID,
    equals(referenceOutput.OperatorId.extractString(20)),
    reason: 'unexpected operator ID',
  );
}

void main() {
  group('Correct message parsing tests', () {
    test('parse correct basic ID message', () {
      final Uint8List messageData = OperatorIDMessages.correctMessage;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);

        expect(parsedOutput.operatorIDType, isA<OperatorIDTypeOperatorID>());
      });
    });

    test('parse private operator ID type', () {
      final Uint8List messageData = OperatorIDMessages.privateOperatorIdType;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);

        expect(parsedOutput.operatorIDType, isA<OperatorIDTypePrivate>());
      });
    });
  });

  group('Captured correct message tests', () {
    test('correct captured message #1', () {
      final Uint8List messageData = OperatorIDMessages.correctCapturedMessage1;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);

        expect(parsedOutput.operatorIDType, isA<OperatorIDTypeOperatorID>());
      });
    });
  });
}
