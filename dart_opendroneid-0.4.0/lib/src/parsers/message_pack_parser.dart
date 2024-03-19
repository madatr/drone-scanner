import 'dart:typed_data';

import '../dart_opendroneid.dart';
import '../decoders/decoders.dart';
import '../types.dart';
import 'odid_message_parser.dart';

class MessagePackParser implements ODIDMessageParser {
  @override
  MessagePack? parse(Uint8List messageData) {
    final protocolVersion =
        decodeField(decodeProtocolVersion, messageData, 0, 1);

    if (protocolVersion == null) {
      return null;
    }
    // Message pack contains metadata before actual message data
    // these include type, singleMessageSize and messageCount
    const packMetadataSize = 3;

    // Size of each message in pack (should always be 25)
    final singleMessageSize = messageData[1];

    // Number of messages in this message pack
    final messageCount = messageData[2];

    // Check if received data length checks out with header data
    if (messageData.length !=
        (singleMessageSize * messageCount) + packMetadataSize) {
      return null;
    }

    final List<ODIDMessage> messages = [];

    for (var i = 0; i < messageCount; i++) {
      final offset = packMetadataSize + (i * singleMessageSize);
      final singleMessageData =
          messageData.sublist(offset, offset + singleMessageSize);
      final message = parseODIDMessage(singleMessageData);

      // TODO maybe return null if any message is null?
      if (message != null) {
        messages.add(message);
      }
    }

    // FIXME each message type can be present only once!

    return MessagePack(
      protocolVersion: protocolVersion,
      rawContent: messageData,
      messages: messages,
    );
  }

  const MessagePackParser();
}
