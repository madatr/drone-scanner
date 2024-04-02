import 'dart:developer';
import 'dart:typed_data';

import 'constants.dart';
import 'parsers/auth_message_parser.dart';
import 'parsers/basic_id_message_parser.dart';
import 'parsers/location_message_parser.dart';
import 'parsers/message_pack_parser.dart';
import 'parsers/odid_message_parser.dart';
import 'parsers/operator_id_message_parser.dart';
import 'parsers/self_id_message_parser.dart';
import 'parsers/system_message_parser.dart';
import 'types.dart';

Map<Type, ODIDMessageParser> _parserMapping = {
  BasicIDMessage: BasicIDMessageParser(),
  LocationMessage: LocationMessageParser(),
  AuthMessage: AuthMessageParser(),
  SelfIDMessage: SelfIDMessageParser(),
  SystemMessage: SystemMessageParser(),
  OperatorIDMessage: OperatorIDMessageParser(),
  MessagePack: MessagePackParser(),
};

// int i = 0;
List<int> authDataCombined = [];

/// Parses ODID message from array of raw bytes [messageData].
/// Optional parameter [T] can constrain the expected message type. In case the
/// specified type does not match parsed message type, `null` is returned.
T? parseODIDMessage<T extends ODIDMessage>(Uint8List messageData) {
  final messageType = determineODIDMessageType(messageData);

  if (T != ODIDMessage && messageType is! T) {
    // TODO or throw here instead of null?
    return null;
  }

  // Check that message length is exactly 25 bytes for standard message (not message pack)
  if (messageType != MessagePack && messageData.length != maxMessageSize) {
    return null;
  }
  // i++;

  final parser = _parserMapping[messageType];

  if (parser == null) {
    return null;
  }

  var out;

  if (messageType == AuthMessage) {
    // authDataCombined ??= Uint8List.fromList([]);

    out = parser.parse(messageData) as AuthMessage?;

    if (out != null) {
      try {
        // log("MADATR: Internal: Page(${out!.authPageNumber})| data: ${out!.authData.toString()}");

        if (out!.authPageNumber == 0) {
          // log("Got auth message (0): ${DateTime.now().toIso8601String()}");

          // log("MADATR: Internal: Page 0 - clearing");

          authDataCombined.clear();
          authDataCombined.addAll(out!.authData.authData.toList());
        } else {
          authDataCombined.addAll(out!.authData.authData.toList());
        }
        // log("MADATR: Internal: data: ${out!.authData.toString()}");
        // log("MADATR: Internal: combined: ${authDataCombined.toString()}");
        var authData_ =
            AuthData(authData: Uint8List.fromList(authDataCombined));
        var authMes = AuthMessage(
            protocolVersion: out!.protocolVersion,
            rawContent: out!.rawContent,
            authType: out!.authType,
            authPageNumber: out!.authPageNumber,
            lastAuthPageIndex: out!.lastAuthPageIndex,
            authLength: out!.authLength,
            timestamp: out!.timestamp,
            authData: authData_);
        out = authMes;
      } catch (e) {
        log("MADATR: ERR: ${e.toString()}");
      }
    }
    // log("MADATR: Internal: Auth page (page number: $pageNumber) Data: ${authData}");
    // log("MADATR: Internal: Auth data combined ${authDataCombined}");
  } else {
    out = parser.parse(messageData) as T?;
  }

  return out;
}

/// Parses stream of binary chunks representing messages into [ODIDMessage]
/// stream (using [parseODIDMessage]).
Stream<ODIDMessage?> parseODIDMessageStream(Stream<Uint8List> messageStream) =>
    messageStream.map(parseODIDMessage);

/// Returns ODID message type based on received message header.
/// Returns `null` in case the message or its type is invalid
Type? determineODIDMessageType(Uint8List messageData) {
  // Each message has to be 25 bytes, except for message packs
  if (messageData.length < maxMessageSize) {
    return null;
  }

  // Header is always the first byte
  final header = messageData[0];

  // First 4 bits encode message type
  final type = (header & 0xF0) >> 4;

  // Check that message length is exactly 25 bytes for standard message (not message pack)
  if (type != 15 && messageData.length != maxMessageSize) {
    return null;
  }

  return MessageType.getByValue(type)?.toODIDMessageType();
}
