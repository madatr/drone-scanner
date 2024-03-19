import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

import 'opendroneid_core_library/generated_bindings.dart';

class NativeParser {
  final OpenDroneIDCore _odid = OpenDroneIDCore(_openReferenceParserLibrary());
  final Arena _arena;

  NativeParser(this._arena);

  ODID_BasicID_data? parseBasicID(Uint8List messageData) {
    final message = _parse(
      messageData,
      sizeOf<ODID_BasicID_data>(),
      _odid.odid_initBasicIDData,
      _odid.decodeBasicIDMessage,
    );

    return message?.ref;
  }

  ODID_Location_data? parseLocation(Uint8List messageData) {
    final message = _parse(
      messageData,
      sizeOf<ODID_Location_data>(),
      _odid.odid_initLocationData,
      _odid.decodeLocationMessage,
    );

    return message?.ref;
  }

  ODID_OperatorID_data? parseOperatorID(Uint8List messageData) {
    final message = _parse(
      messageData,
      sizeOf<ODID_OperatorID_data>(),
      _odid.odid_initOperatorIDData,
      _odid.decodeOperatorIDMessage,
    );

    return message?.ref;
  }

  ODID_SelfID_data? parseSelfID(Uint8List messageData) {
    final message = _parse(
      messageData,
      sizeOf<ODID_SelfID_data>(),
      _odid.odid_initSelfIDData,
      _odid.decodeSelfIDMessage,
    );

    return message?.ref;
  }

  ODID_System_data? parseSystem(Uint8List messageData) {
    final message = _parse(
      messageData,
      sizeOf<ODID_System_data>(),
      _odid.odid_initSystemData,
      _odid.decodeSystemMessage,
    );

    return message?.ref;
  }

  ODID_Auth_data? parseAuth(Uint8List messageData) {
    final message = _parse(
      messageData,
      sizeOf<ODID_Auth_data>(),
      _odid.odid_initAuthData,
      _odid.decodeAuthMessage,
    );

    return message?.ref;
  }

  ODID_UAS_Data? parseMessagePack(Uint8List messageData) {
    final message = _parse(
      messageData,
      sizeOf<ODID_UAS_Data>(),
      _odid.odid_initUasData,
      _odid.decodeMessagePack,
    );

    return message?.ref;
  }

  Pointer<O>? _parse<I extends NativeType, O extends Struct>(
    Uint8List messageData,
    int outputSize,
    void Function(Pointer<O>) prepare,
    int Function(Pointer<O>, Pointer<I>) decode,
  ) {
    // Allocate native memory for input data
    final buf = _arena.allocate<Uint8>(messageData.length);

    // Copy input data from Dart-managed to native memory
    buf.asTypedList(messageData.length).setAll(0, messageData);

    // Allocate output data buffer
    final outData = _arena.allocate<O>(outputSize);
    final inData = buf.cast<I>();

    prepare(outData);
    final returnCode = decode(outData, inData);

    if (returnCode != ODID_SUCCESS) {
      return null;
    }

    return outData;
  }

  static DynamicLibrary _openReferenceParserLibrary() {
    // Open the dynamic library
    var libraryPath = path.join(
      Directory.current.path,
      'test',
      'opendroneid_core_library',
      'libopendroneid.so',
    );
    if (Platform.isMacOS) {
      libraryPath = path.join(
        Directory.current.path,
        'test',
        'opendroneid_core_library',
        'libopendroneid.dylib',
      );
    }
    if (Platform.isWindows) {
      libraryPath = path.join(
        Directory.current.path,
        'test',
        'opendroneid_core_library',
        'libopendroneid.dll',
      );
    }

    return DynamicLibrary.open(libraryPath);
  }
}

extension NativeStringExtractor on Array<Char> {
  String extractString(int maxLength) {
    String output = '';

    for (var i = 0; i < maxLength; i++) {
      if (this[i] == 0) {
        break;
      }

      output += String.fromCharCode(this[i]);
    }

    return output;
  }
}

extension ByteListExtractor on Array<Char> {
  Uint8List extractBytes(int maxLength) =>
      Uint8List.fromList(List.generate(maxLength, (i) => this[i]));
}

extension Uint8ListExtractor on Array<Uint8> {
  Uint8List extractBytes(int maxLength) =>
      Uint8List.fromList(List.generate(maxLength, (i) => this[i]));
}
