// ignore_for_file: lines_longer_than_80_chars

import 'dart:developer';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/elliptic.dart';
import 'package:flutter_opendroneid/extensions/list_extension.dart';
import 'package:flutter_opendroneid/models/message_container.dart';

class AuthResult {
  bool verified;
  String verificationMessage;

  List<Duration> processingTimes = [];
  List<Duration> hashingTimes = [];
  List<Duration> verificationTimes = [];

  AuthResult({required this.verified, required this.verificationMessage});
}

class Authenticator {
  static int trials = 0;
  static List<Duration> processingTimes = [];
  static List<Duration> hashingTimes = [];
  static List<Duration> verificationTimes = [];

  static double calculateAverage(List<Duration> durations) {
    if (durations.isEmpty) {
      return 0;
    }
    int dl = durations.length;
    int sum = 0;
    durations.forEach((element) {
      sum = sum + element.inMicroseconds;
    });
    log("Dividing: ${sum} / $dl");
    return (sum) / dl;
  }

  static String stringToHex(String text, int length) {
    var hexString = text.runes
        .map((rune) => rune.toRadixString(16).padLeft(2, '0'))
        .join('');

    // Ensure that the hex string has the desired length
    if (hexString.length < length) {
      hexString = hexString.padRight(length, '0');
    } else if (hexString.length > length) {
      // Trim the hex string if it exceeds the desired length
      hexString = hexString.substring(0, length);
    }

    return hexString;
  }

  static Uint8List hexStringToBytes(String hexString) {
    var result = <int>[];
    for (var i = 0; i < hexString.length; i += 2) {
      result.add(int.parse(hexString.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(result);
  }

  static String hashHexString(String hexString) {
    var bytes = hexStringToBytes(hexString);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static AuthResult checkAuth(List<MessageContainer> allMessages) {
    if (trials > 20) {
      var averageProcessingTime = calculateAverage(processingTimes);
      var averageHashingTime = calculateAverage(hashingTimes);
      var averageVerificationTime = calculateAverage(verificationTimes);

      log('Average Processing Time: $averageProcessingTime');
      log('Average Hashing Time: $averageHashingTime');
      log('Average Verification Time: $averageVerificationTime');
    }

    Duration? pt;
    Duration? ht;
    Duration? vt;

    var result = AuthResult(
        verified: false, verificationMessage: "Have not checked yet");

    var pubKeyHex = '';
    var sigHex = '';
    var operatorID = '';
    log("MADATR: checkAuth");

    log("message Rx time: ${allMessages.last.lastUpdate.toIso8601String()}");
    if (allMessages.last.afterProcess != null) {
      log("message after processing time: ${allMessages.last.afterProcess!.toIso8601String()}");
      pt = allMessages.last.afterProcess!
          .difference(allMessages.last.lastUpdate);
      log("Processing time: ${pt.inMicroseconds} μs");
    }
    if (allMessages.last.authenticationMessage != null &&
        allMessages.last.operatorIdMessage != null) {
      var payload = allMessages.last.authenticationMessage!.authData.authData
          .toHexString();
      // log("MADATR: payload: ${payload}");

      if (payload.isNotEmpty || payload.length == 256) {
        pubKeyHex = payload.substring(0, 128);

        sigHex = payload.substring(128, 256);
      } else {
        result.verificationMessage = "Auth payload wrong length";
        return result;
      }

      var lengthOfHex = 49;
      operatorID = stringToHex(
          allMessages.last.operatorIdMessage!.operatorID, lengthOfHex);
      operatorID += "1000100"; // Terminating chars from cpp

      var t1 = DateTime.now();

      var hashHex = hashHexString(operatorID);
      var t2 = DateTime.now();

      ht = t2.difference(t1);
      log("Hashing time: ${ht.inMicroseconds} μs");

      // log("MADATR: Got Data");

      // log("MADATR: pubKeyHex UA: DD0876EA58CD10AFAA466E60FCD77DEB813F172A038197DEC59FDA98F504A036C06FF635FC4E7B620D3D58BC671152C684B025817D9BBA2C971F8C1997F33E53");
      // log("MADATR: pubKeyHex Rx: ${pubKeyHex.toUpperCase()}");
      // log("-------");

      // log("MADATR: message UA: 4B552D55412D31323233343100000000000000000000000001000100");
      // log("MADATR: message Rx: ${operatorID.toUpperCase()}");
      // log("--");
      // log("MADATR: message Hash UA: 0AE4EA8F87B8082E69FA545BAC7A8FC55E3E8589FCDC20BD16BE2FB359BEC5B5");
      // log("MADATR: message Hash Rx: ${hashHex.toUpperCase()}");
      // log("--");

      // log("MADATR: sigHashHex UA: 400AC0C73ED08F82FF8458773F4C4796AF886E55A7FDB9B021CDF2081AA70E4936164E6DCBE122F70CF4F0C8513203B9DE4FED8FE6C58205C0874F9F84FE7461");
      // log("MADATR: sigHashHex Rx: ${sigHex.toUpperCase()}");
      // log("-------");
      // log("----------------------------");

      // log("MADATR: operatorID: ${operatorID.toUpperCase()}");

      t1 = DateTime.now();

      var ec = getP256();
      pubKeyHex = "04$pubKeyHex";

      PublicKey pubKey;
      try {
        pubKey = PublicKey.fromHex(ec, pubKeyHex);
      } on Exception catch (e) {
        log("MADATR: AUTH: Public Key Error: ${e.toString()}");
        result.verificationMessage = "Public Key Error: ${e.toString()}";
        return result;
      }

      List<int> hash;
      try {
        hash = List<int>.generate(hashHex.length ~/ 2,
            (i) => int.parse(hashHex.substring(i * 2, i * 2 + 2), radix: 16));
      } on Exception catch (e) {
        log("MADATR: AUTH: Hashing Error: ${e.toString()}");
        result.verificationMessage = "Hashing Error: ${e.toString()}";
        return result;
      }

      log("Trying to verify");

      Signature signature;
      try {
        signature = Signature.fromCompactHex(sigHex);
      } on Exception catch (e) {
        log("MADATR: AUTH: Signature Parsing Error: ${e.toString()}");
        result.verificationMessage = "Signature Parsing Error: ${e.toString()}";
        return result;
      }
      bool vres;
      try {
        vres = verify(pubKey, hash, signature);

        t2 = DateTime.now();
        vt = t2.difference(t1);
        log("Verification time: ${vt.inMicroseconds} μs");

        log(vres ? "Verified" : "Not verified");
        result.verified = true;
        result.verificationMessage = "-";

        if (vres) {
          log("Trial: $trials");
          trials++;
          hashingTimes.add(ht);
          processingTimes.add(pt!);
          verificationTimes.add((vt));

          result.hashingTimes = hashingTimes;
          result.processingTimes = processingTimes;
          result.verificationTimes = verificationTimes;
        }

        return result;
      } on Exception catch (e) {
        log("MADATR: AUTH: Verification Error: ${e.toString()}");
        result.verificationMessage = "Verification Error: ${e.toString()}";
        return result;
      }
    } else {
      if (allMessages.last.authenticationMessage == null) {
        result.verificationMessage = "No Auth Message";
      } else {
        result.verificationMessage = "No Operator ID Message";
      }
    }
    return result;
  }
}
