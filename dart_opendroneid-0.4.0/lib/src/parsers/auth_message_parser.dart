// import 'dart:developer';
import 'dart:developer';
import 'dart:typed_data';

import '../constants.dart';
import '../decoders/auth_message_decoders.dart';
import '../decoders/decoders.dart';
import '../enums.dart';
import '../types/odid_message.dart';
import 'odid_message_parser.dart';

class AuthMessageParser implements ODIDMessageParser {
  const AuthMessageParser();

  /// see comment above [AuthMessage] for explanation of the format
  @override
  AuthMessage? parse(Uint8List messageData) {
    final protocolVersion =
        decodeField(decodeProtocolVersion, messageData, 0, 1);
    final authType = AuthType.getByValue((messageData[1] & 0xF0) >> 4);

    if (protocolVersion == null || authType == null) return null;

    int? pageNumber = messageData[1] & 0x0F;
    int? lastPageIndex;
    int? authLength;
    DateTime? timestamp;
    int? authDataOffset;
    int? currMessageAuthLength;

    // log("MADATR: Internalx2: Page: $pageNumber");

    if (pageNumber == 0) {
      lastPageIndex = messageData[2] & 0x0F;
      authLength = messageData[3];
      timestamp = decodeField(decodeODIDEpochTimestamp, messageData, 4, 8);
      // log("MADATR: Internalx2: lastPageIndex: $lastPageIndex");
      // log("MADATR: Internalx2: authLength: $authLength");
      // log("MADATR: Internalx2: maxAuthDataPages: $maxAuthDataPages");
      // log("MADATR: Internalx2: maxAuthPageZeroSize: $maxAuthPageZeroSize");
      if (lastPageIndex >= maxAuthDataPages) {
        // log("MADATR: Internalx2: returning null (1)");

        return null;
      }

      authDataOffset = 8;
      currMessageAuthLength = maxAuthPageZeroSize;
    } else {
      authDataOffset = 2;
      currMessageAuthLength = maxAuthPageNonZeroSize;
    }
    var authData = null;
    try {
      authData = decodeField(
        decodeAuthData,
        messageData,
        authDataOffset,
        authDataOffset + currMessageAuthLength,
      );
    } catch (e) {
      // log("MADATR: Internalx2: Page: $pageNumber | ERR: ${e.toString()}");
    }

    // log("MADATR: Internalx2: Page: $pageNumber | data: ${authData.toString()}");

    if (authData == null) {
      // log("MADATR: Internalx2: returning null (2)");
      return null;
    }

    // log("MADATR: Internalx2: returning page: $pageNumber");

    return AuthMessage(
      protocolVersion: protocolVersion,
      rawContent: messageData,
      authType: authType,
      authPageNumber: pageNumber,
      lastAuthPageIndex: lastPageIndex,
      authLength: authLength,
      timestamp: timestamp,
      authData: authData,
    );
  }
}
