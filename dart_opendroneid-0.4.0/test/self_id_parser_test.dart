import 'dart:typed_data';

import 'package:dart_opendroneid/src/constants.dart';
import 'package:dart_opendroneid/src/parsers/self_id_message_parser.dart';
import 'package:dart_opendroneid/src/types.dart';
import 'package:dart_opendroneid/src/types/description_type.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'native_parser.dart';
import 'opendroneid_core_library/generated_bindings.dart';
import 'resources/self_id_messages.dart';

void compareWithReference(
  Uint8List messageData,
  Function(SelfIDMessage? parsedOutput, ODID_SelfID_data? referenceOutput)
      comparison,
) {
  using((arena) {
    final dartParser = SelfIDMessageParser();
    final nativeParser = NativeParser(arena);

    final dartOutput = dartParser.parse(messageData);
    final nativeOutput = nativeParser.parseSelfID(messageData);

    comparison(dartOutput, nativeOutput);
  });
}

/// Tests for equality with reference decoder output
// TODO maybe implement as a matcher?
void matchReferenceFields(
  SelfIDMessage parsedOutput,
  ODID_SelfID_data referenceOutput,
) {
  expect(
    parsedOutput.descriptionType.value,
    equals(referenceOutput.DescType),
    reason: 'unexpected description type',
  );
  // FIXME extractString length should be unbounded?
  expect(
    parsedOutput.description,
    equals(referenceOutput.Desc.extractString(23)),
    reason: 'unexpected description',
  );
}

void main() {
  group('Correct message parsing tests', () {
    test('parse correct self ID message', () {
      final Uint8List messageData = SelfIDMessages.correctMessage;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);

        expect(parsedOutput.descriptionType, isA<DescriptionTypePrivate>());
      });
    });

    test('parse emergency description', () {
      final Uint8List messageData = SelfIDMessages.emergencyDescription;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        if (parsedOutput == null || referenceOutput == null) {
          expect(parsedOutput, equals(referenceOutput));

          return;
        }

        expect(parsedOutput.protocolVersion, equals(2));

        matchReferenceFields(parsedOutput, referenceOutput);

        expect(parsedOutput.descriptionType, isA<DescriptionTypeEmergency>());
      });
    });
  });

  // TODO add real message test (we don't send Self ID messages)

  // group('Captured correct message tests', () {});
}
