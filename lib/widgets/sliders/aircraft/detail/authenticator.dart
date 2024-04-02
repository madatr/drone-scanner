// ignore_for_file: lines_longer_than_80_chars

import 'dart:developer';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/elliptic.dart';
import 'package:flutter_opendroneid/extensions/list_extension.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:intl/intl.dart';

class AuthResult {
  bool verified;
  String verificationMessage;

  List<Duration> processingTimes = [];
  List<Duration> hashingTimes = [];
  List<Duration> verificationTimes = [];
  List<Duration> rxTimes = [];

  AuthResult({required this.verified, required this.verificationMessage});
}

class Authenticator {
  static int trials = 0;
  static List<Duration> processingTimes = [];
  static List<Duration> hashingTimes = [];
  static List<Duration> verificationTimes = [];
  static List<Duration> rxTimes = [];

  // static double calculateAverage(List<Duration> durations) {
  //   if (durations.isEmpty) {
  //     return 0;
  //   }
  //   var dl = durations.length;
  //   var sum = 0;
  //   durations.forEach((element) {
  //     sum = sum + element.inMicroseconds;
  //   });
  //   log("Dividing: $sum / $dl");
  //   return (sum) / dl;
  // }

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

  static DateTime parseTime(String inputTimeString) {
    var now = DateTime.now();

    // Split the input time string by spaces
    var parts = inputTimeString.split(' ');

    // Extract the year, time and microsecond parts
    var year = int.parse(parts[0]);
    var timePart = parts[1];

    // Split the time part by colons
    var timeParts = timePart.split(':');

    // Extract the hour, minute, second, and microsecond parts
    var hour = int.parse(timeParts[0]);
    var minute = int.parse(timeParts[1]);
    var second = int.parse(timeParts[2].split('.')[0]); // Extract seconds
    var totalMicrosecond =
        int.parse(timeParts[2].split('.')[1]); // Extract microseconds

    var milliseconds =
        totalMicrosecond ~/ 1000; // Integer division to get milliseconds
    var microseconds = totalMicrosecond % 1000; // Remainder to get microseconds

    // Create a new DateTime object with the extracted values
    var parsedDateTime = DateTime(year, now.month, now.day, hour, minute,
        second, milliseconds, microseconds);

    return parsedDateTime;
  }

  static AuthResult checkAuth(List<MessageContainer> allMessages) {
    // if (trials > 20) {
    //   var averageProcessingTime = calculateAverage(processingTimes);
    //   var averageHashingTime = calculateAverage(hashingTimes);
    //   var averageVerificationTime = calculateAverage(verificationTimes);
    //   var averageRxTime = calculateAverage(rxTimes);

    //   log('Average Processing Time: $averageProcessingTime');
    //   log('Average Hashing Time: $averageHashingTime');
    //   log('Average Verification Time: $averageVerificationTime');
    //   log('Average Rx Time: $averageRxTime');
    // }

    if (allMessages.last.selfIdMessage != null) {
      if (allMessages.last.selfIdMessage!.description != "") {
        // DateTime now = DateTime.now();

        var txTime =
            parseTime(allMessages.last.selfIdMessage!.description.toString());

        log("TS: INTERMID: y:${txTime.year}, hour:${txTime.hour}, minute:${txTime.minute}, second:${txTime.second}, microsec:${txTime.microsecond}");

        var formattedTxDateTime =
            DateFormat('yyyy HH:mm:ss.SSSSSS').format(txTime);

        var formattedRxDateTime = DateFormat('yyyy HH:mm:ss.SSSSSS')
            .format(allMessages.last.lastUpdate);

        // log("TS: Input: ${allMessages.last.selfIdMessage!.description.toString()}");
        // log("TS: Input Parsed: $formattedTxDateTime");
        Duration td = allMessages.last.lastUpdate.difference(txTime);
        // Duration tn = now.difference(txTime);

        log("TS: Tx Time: $formattedTxDateTime");
        log("TS: Rx Time: $formattedRxDateTime");
        log("TS: Time Rx Δ: ${td.inMilliseconds} ms == ${td.inMicroseconds} μs");
        // log("TS: Time Now Δ: ${tn.inMilliseconds} ms == ${tn.inMicroseconds} μs");

        rxTimes.add(td);

        log("TS: ------------------------");
      } else {
        log("TS: No TimeStamp");
      }
    } else {
      log("NTS: o TimeStamp");
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
      operatorID += "1000000"; // Terminating chars from cpp

      var t1 = DateTime.now();

      var hashHex = hashHexString(operatorID);
      var t2 = DateTime.now();

      ht = t2.difference(t1);
      log("Hashing time: ${ht.inMicroseconds} μs");

      // log("MADATR: Got Data");

      // log("MADATR: pubKeyHex UA: E05C48713D1FB3F0F02AD459516CB701A1AABC0960C8CA620B821805C59887B525AF1869DB9A4716B6AED257792C3554645DD769A76026EF62BC6C5194F95DEE");
      // log("MADATR: pubKeyHex Rx: ${pubKeyHex.toUpperCase()}");
      // log("-------");

      // log("MADATR: message UA: 4B552D55412D31323233343100000000000000000000000001000100");
      // log("MADATR: message Rx: ${operatorID.toUpperCase()}");
      // log("--");
      // log("MADATR: message Hash UA: CF2BDCDBC1A82C742880F53607D495CABA9081C013F13F61D46BE716BBEE5A48");
      // log("MADATR: message Hash Rx: ${hashHex.toUpperCase()}");
      // log("--");

      // log("MADATR: sigHashHex UA: F9E1A5558E0E201DEC05AA952FC17BB748F06646E3548813BD84A77049EBACC53FE38AA912D3C4C267C99136DAAA0CE0BBB4AFB9D4E244068F39E4DFA518F1FA");
      // log("MADATR: sigHashHex Rx: ${sigHex.toUpperCase()}");
      // log("-------");
      // log("----------------------------");

      // log("MADATR: operatorID UA: 4B555F55544D5F55415F333438353337383300000000000001000000");
      // log("MADATR: operatorID Rx: ${operatorID.toUpperCase()}");

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
          result.rxTimes = rxTimes;
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
