import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/models/message_container.dart';

import '../../../../constants/colors.dart';
import '../../common/headline.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';
import 'authenticator.dart';

class AuthFields {
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

  static List<Widget> buildAuthFields(
    BuildContext context,
    List<MessageContainer> messagePackList,
  ) {
    var result = Authenticator.checkAuth(messagePackList);
    var averageProcessingTime = 0.0;
    var averageHashingTime = 0.0;
    var averageVerificationTime = 0.0;
    var averageRxTime = 0.0;

    if (result.hashingTimes.length > 10) {
      averageProcessingTime = calculateAverage(result.processingTimes);
      averageHashingTime = calculateAverage(result.hashingTimes);
      averageVerificationTime = calculateAverage(result.verificationTimes);
      averageRxTime = calculateAverage(result.rxTimes);
    }

    log("MADATR T: Verification result: ${result.verificationMessage}");

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return [
      const Headline(text: 'AUTHENTICATION & VERIFICATION'),
      if (isLandscape) const Spacer(),
      AircraftDetailRow(
        children: [
          AircraftDetailField(
            headlineText: 'Verified',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      result.verified
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      color: result.verified ? Colors.green : Colors.red,
                    )
                  ],
                ),
                const SizedBox(
                  width: 5,
                ),
                // Text(
                //   sourceText,
                //   style: const TextStyle(
                //     color: AppColors.detailFieldColor,
                //   ),
                // ),
              ],
            ),
          ),
          AircraftDetailField(
            headlineText: 'Comments',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.verificationMessage,
                  style: const TextStyle(
                    color: AppColors.detailFieldColor,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      // AircraftDetailField(
      //   headlineText: 'Verification Timings',
      //   child: Row(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         "Messages Received: ${result.hashingTimes.length}",
      //         style: const TextStyle(
      //           color: AppColors.detailFieldColor,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      result.hashingTimes.length > 10
          ? AircraftDetailField(
              headlineText: 'Average Processing Time',
              numOfMes: result.processingTimes.length.toString(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${averageProcessingTime.toStringAsFixed(0)} μs  ≈  ${(averageProcessingTime / 1000).toStringAsFixed(0)} ms",
                    style: const TextStyle(
                      color: AppColors.detailFieldColor,
                    ),
                  ),
                ],
              ),
            )
          : Container(),
      result.hashingTimes.length > 10
          ? AircraftDetailField(
              headlineText: 'Average Hashing Time',
              numOfMes: result.hashingTimes.length.toString(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${averageHashingTime.toStringAsFixed(0)} μs  ≈  ${(averageHashingTime / 1000).toStringAsFixed(0)} ms",
                    style: const TextStyle(
                      color: AppColors.detailFieldColor,
                    ),
                  ),
                ],
              ),
            )
          : Container(),
      result.hashingTimes.length > 10
          ? AircraftDetailField(
              headlineText: 'Average Verification Time',
              numOfMes: result.verificationTimes.length.toString(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${averageVerificationTime.toStringAsFixed(0)} μs  ≈  ${(averageVerificationTime / 1000).toStringAsFixed(0)} ms",
                    style: const TextStyle(
                      color: AppColors.detailFieldColor,
                    ),
                  ),
                ],
              ),
            )
          : Container(),

      result.hashingTimes.length > 10
          ? AircraftDetailField(
              headlineText: 'Average Time Rx Δ',
              numOfMes: result.rxTimes.length.toString(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${averageRxTime.toStringAsFixed(0)} μs  ≈  ${(averageRxTime / 1000).toStringAsFixed(0)} ms",
                    style: const TextStyle(
                      color: AppColors.detailFieldColor,
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    ];
  }
}
