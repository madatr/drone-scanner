import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/models/message_container.dart';

import '../../../../constants/colors.dart';
import '../../common/headline.dart';
import 'aircraft_detail_field.dart';
import 'aircraft_detail_row.dart';
import 'authenticator.dart';

class AuthFields {
  static List<Widget> buildAuthFields(
    BuildContext context,
    List<MessageContainer> messagePackList,
  ) {
    var result = Authenticator.checkAuth(messagePackList);
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
    ];
  }
}
