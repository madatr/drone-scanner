import 'dart:typed_data';

import 'package:dart_opendroneid/dart_opendroneid.dart';
import 'package:dart_opendroneid/src/parsers/auth_message_parser.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'native_parser.dart';
import 'opendroneid_core_library/generated_bindings.dart';
import 'resources/auth_messages.dart';

void compareWithReference(
  Uint8List messageData,
  Function(AuthMessage? parsedOutput, ODID_Auth_data? referenceOutput)
      comparison,
) {
  using((arena) {
    final dartParser = AuthMessageParser();
    final nativeParser = NativeParser(arena);

    final dartOutput = dartParser.parse(messageData);
    final nativeOutput = nativeParser.parseAuth(messageData);

    comparison(dartOutput, nativeOutput);
  });
}

/// Tests for equality with reference decoder output
// TODO maybe implement as a matcher?
void matchReferenceFields(
  AuthMessage parsedOutput,
  ODID_Auth_data referenceOutput,
) {
  expect(
    parsedOutput.authType.value,
    equals(referenceOutput.AuthType),
    reason: 'unexpected Auth type',
  );

  final isZeroPage = referenceOutput.DataPage == 0;

  expect(
    parsedOutput.authPageNumber,
    equals(referenceOutput.DataPage),
    reason: 'unexpected Page Number',
  );

  if (isZeroPage) {
    expect(
      parsedOutput.lastAuthPageIndex,
      equals(referenceOutput.LastPageIndex),
      reason: 'unexpected Last Auth Page Index',
    );

    expect(
      parsedOutput.authLength,
      equals(referenceOutput.Length),
      reason: 'unexpected Auth Length',
    );

    expect(
      ((parsedOutput.timestamp?.millisecondsSinceEpoch ?? 0) / 1000) -
          1546300800,
      equals(referenceOutput.Timestamp),
      reason: 'unexpected Timestamp',
    );
  } else {
    expect(
      parsedOutput.lastAuthPageIndex,
      isNull,
      reason: 'unexpected non null Last Auth Page Index',
    );

    expect(
      parsedOutput.authLength,
      isNull,
      reason: 'unexpected non null Auth Length',
    );

    expect(
      parsedOutput.timestamp,
      isNull,
      reason: 'unexpected non null Timestamp',
    );
  }

  expect(
    parsedOutput.authData.authData,
    equals(referenceOutput.AuthData.extractBytes(
      isZeroPage ? maxAuthPageZeroSize : maxAuthPageNonZeroSize,
    )),
    reason: 'unexpected Auth Data',
  );
}

void main() {
  group('Correct message parsing tests', () {
    test('parse correct auth message with zero page number', () {
      final messageData = AuthMessages.correctMessagePageZero;

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

    test('parse correct auth message with non zero page number', () {
      final messageData = AuthMessages.correctMessagePageNonZero;

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

    test(
        'parse correct auth message with zero page number'
        ' with non zoro page count', () {
      final messageData = AuthMessages.correctMessagePageZeroWithPageCnt;

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
    test('reject too big auth length for zero page', () {
      final Uint8List messageData = AuthMessages.invalidAuthLenZeroPage;

      expect(messageData.length, equals(maxMessageSize));

      // Expect parsing to fail on auth lenght to big for zero page
      expect(AuthMessageParser().parse(messageData), isNull);
    });

    test('reject unknown auth type', () {
      final Uint8List messageData = AuthMessages.invalidAuthLenZeroPage;

      expect(messageData.length, equals(maxMessageSize));

      // Expect parsing to fail on unknown auth type
      expect(AuthMessageParser().parse(messageData), isNull);
    });
  });

  group('Captured Aeroentry message tests', () {
    test('Aeroentry captured message #1', () {
      final Uint8List messageData = AuthMessages.aeroentryCapturedMessage1;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });

    test('Aeroentry captured message #2', () {
      final Uint8List messageData = AuthMessages.aeroentryCapturedMessage2;

      expect(messageData.length, equals(maxMessageSize));

      compareWithReference(messageData, (parsedOutput, referenceOutput) {
        expect(parsedOutput, isNotNull);
        expect(referenceOutput, isNotNull);

        if (parsedOutput == null || referenceOutput == null) {
          return;
        }

        matchReferenceFields(parsedOutput, referenceOutput);
      });
    });
  });
}
