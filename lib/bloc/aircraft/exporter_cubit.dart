import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/csvlogger.dart';
import 'aircraft_cubit.dart';

enum ExportFormat {
  csv,
  gpx,
}

class ExportState {}

class PositionDetail extends Position {
  final DateTime dateTime;

  const PositionDetail(
      {required super.longitude,
      required super.latitude,
      required super.timestamp,
      required super.accuracy,
      required super.altitude,
      required super.altitudeAccuracy,
      required super.heading,
      required super.headingAccuracy,
      required super.speed,
      required super.speedAccuracy,
      required this.dateTime});

  @override
  Map<String, dynamic> toJson() => {
        'longitude': longitude,
        'latitude': latitude,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'accuracy': accuracy,
        'altitude': altitude,
        'altitude_accuracy': altitudeAccuracy,
        'floor': floor,
        'heading': heading,
        'heading_accuracy': headingAccuracy,
        'speed': speed,
        'speed_accuracy': speedAccuracy,
        'is_mocked': isMocked,
        'dateTime': dateTime.toIso8601String()
      };
}

class RssiDistance {
  final PositionDetail myPosition;
  final LocationMessage dronePosition;
  final double distanceMetres;
  final int rssi;
  final String sourceTech;

  RssiDistance(
      {required this.myPosition,
      required this.dronePosition,
      required this.distanceMetres,
      required this.rssi,
      required this.sourceTech});

  Map<String, dynamic> toJson() {
    return {
      'sourceTech': sourceTech,
      'distanceMetres': distanceMetres,
      'rssi': rssi,
      'myPosition': myPosition.toJson(),
      'dronePosition': dronePosition.toJson(),
    };
  }
}

class ExporterCubit extends Cubit<ExportState> {
  bool logging = false;
  bool blankFileLoc = true;
  bool blankFileOdid = true;

  final AircraftCubit aircraftCubit;
  String? saveFileDeviceLocationPath;
  String? saveFileODIDPath;
  String? saveFileAllDataPath;

  File? saveFileDeviceLocation;
  File? saveFileODID;
  File? saveFileAllData;

  List<PositionDetail> myLocations = [];
  List<MessageContainer> odidMessages = [];
  List<RssiDistance> droneDistanceRssi = [];

  PositionDetail? myLastLocation;

  StreamSubscription<Position>? positionStream;

  ExporterCubit({required this.aircraftCubit}) : super(ExportState()) {
    // locationTracker();
  }

  bool get isLogging => logging;

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  Future<Object> startLogger() async {
    try {
      print("EXPORTER_LOG: Started Logger");

      var storageAllowed = await _storagePermissionCheck();
      var locationAllowed = await checkLocationPermission();

      print(
          "EXPORTER_LOG: storageAllowed: $storageAllowed, locationAllowed: $locationAllowed");

      if (storageAllowed && locationAllowed) {
        var now = DateTime.now();

        // final dir = await getDownloadsDirectory();
        final dir = await getDownloadPath();
        // final dir = await getApplicationDocumentsDirectory();

        print("EXPORTER_LOG: getDownloadsDirectory: $dir");

        final devInfo = await getDeviceInformation();

        if (dir != null) {
          var ts = DateFormat('yyyy_MM_dd_HHmmss').format(now);

          saveFileDeviceLocationPath = "$dir/ODID_LOG/DEV_LOCATIONS_$ts.json";
          saveFileODIDPath = "$dir/ODID_LOG/ODID_LOG_$ts.json";
          saveFileAllDataPath = "$dir/ODID_LOG/ALL_DATA_$ts.json";

          print("EXPORTER_LOG: saveFileAllDataPath: $saveFileAllDataPath");

          try {
            saveFileDeviceLocation = File(saveFileDeviceLocationPath!);
            saveFileODID = File(saveFileODIDPath!);
            saveFileAllData = File(saveFileAllDataPath!);

            if (saveFileDeviceLocation != null &&
                saveFileODID != null &&
                saveFileAllData != null) {
              await saveFileDeviceLocation!.create(recursive: true);
              await saveFileODID!.create(recursive: true);
              await saveFileAllData!.create(recursive: true);

              await saveFileDeviceLocation!
                  .writeAsString("{$devInfo,\"data\":[", mode: FileMode.append);

              await saveFileODID!
                  .writeAsString("{$devInfo,\"data\":[", mode: FileMode.append);

              startLocationTracker();
              logging = true;
              blankFileLoc = true;
              blankFileOdid = true;

              return true;
            } else {
              return false;
            }
          } catch (e) {
            print("EXPORTER_LOG: File Creation Error: ${e.toString()}");
            return false;
          }
        }
      }
      return false;
    } on Exception catch (e) {
      return e;
    }
  }

  Future<Object> stopLogger() async {
    try {
      await saveFileDeviceLocation!.writeAsString("]}", mode: FileMode.append);
      await saveFileODID!.writeAsString("]}", mode: FileMode.append);

      final devInfoJson = await getDeviceInformationJson();
      var stats = <String, dynamic>{};
      Exception? statErr;
      try {
        if (odidMessages.fold<bool>(
            true,
            (previousValue, element) =>
                previousValue && element.postProcessTime != null)) {
          var numOfItems = 0;
          var sum = 0;
          for (var element in odidMessages) {
            var diff = element.postProcessTime!.difference(element.rxTime);
            // print("${element.rxTime.second}:${element.rxTime.millisecond} ~~ ${element.postProcessTime!.second}:${element.postProcessTime!.millisecond}");
            if (diff.inMilliseconds > 0 && diff.inMinutes < 2) {
              numOfItems++;
              sum += diff.inMilliseconds;
            }
          }
          if (numOfItems > 0 && sum > 0) {
            print(
                "EXPORTER_LOG: averageProcessingTime: ${sum / numOfItems} ms");
            stats.addAll({"averageProcessingTime": sum / numOfItems});
          }
        }

        if (odidMessages.fold<bool>(
            true,
            (previousValue, element) =>
                previousValue && element.txTime != null)) {
          var numOfItems = 0;
          var sum = 0;

          for (var element in odidMessages) {
            var diff = element.rxTime.difference(element.txTime!);
            // print("EXPORTER_LOG: Type : ${element.source.toString()}");
            if (diff.inMilliseconds > 0 && diff.inMinutes < 2) {
              numOfItems++;
              sum += diff.inMilliseconds;
            }
          }

          if (sum > 0 && numOfItems > 0) {
            print("EXPORTER_LOG: TxRxTD all: ${sum / numOfItems} ms");
            stats.addAll({"TxRxTD all": sum / numOfItems});
          }

          //   enum MessageSource {
          //   BluetoothLegacy,
          //   BluetoothLongRange,
          //   WifiNan,
          //   WifiBeacon,
          //   Unknown,
          // }

          numOfItems = 0;
          sum = 0;
          // BT LEGACY =======================================
          for (var element in odidMessages) {
            if (element.source.toString() == "MessageSource.BluetoothLegacy") {
              var diff = element.rxTime.difference(element.txTime!);
              print("EXPORTER_LOG: BT4");
              // print("EXPORTER_LOG: TxRxTD BT4: ${diff.inMilliseconds} ms");
              if (diff.inMilliseconds > 0 && diff.inMinutes < 2) {
                numOfItems++;
                sum += diff.inMilliseconds;
              }
            }
          }
          if (sum > 0 && numOfItems > 0) {
            print("EXPORTER_LOG: TxRxTD BT4: ${sum / numOfItems} ms");
            stats.addAll({"TxRxTD BT4": sum / numOfItems});
          }
          stats.addAll({"number of BT4 ODID messages": numOfItems});

          numOfItems = 0;
          sum = 0;

          // BT5 =======================================
          for (var element in odidMessages) {
            if (element.source.toString() ==
                "MessageSource.BluetoothLongRange") {
              var diff = element.rxTime.difference(element.txTime!);
              print("EXPORTER_LOG: BT5");
              // print("EXPORTER_LOG: TxRxTD BT5: ${diff.inMilliseconds} ms");
              if (diff.inMilliseconds > 0 && diff.inMinutes < 2) {
                numOfItems++;
                sum += diff.inMilliseconds;
              }
            }
          }
          if (sum > 0 && numOfItems > 0) {
            print("EXPORTER_LOG: TxRxTD BT5: ${sum / numOfItems} ms");
            stats.addAll({"TxRxTD BT5": sum / numOfItems});
          }
          stats.addAll({"number of BT5 ODID messages": numOfItems});

          numOfItems = 0;
          sum = 0;

          // WIFI NAN =======================================
          for (var element in odidMessages) {
            if (element.source.toString() == "MessageSource.WifiNan") {
              var diff = element.rxTime.difference(element.txTime!);
              print("EXPORTER_LOG: WIFI NAN");
              // print("EXPORTER_LOG: TxRxTD WifiNan: ${diff.inMilliseconds} ms");
              if (diff.inMilliseconds > 0 && diff.inMinutes < 2) {
                numOfItems++;
                sum += diff.inMilliseconds;
              }
            }
          }
          if (sum > 0 && numOfItems > 0) {
            print("EXPORTER_LOG: TxRxTD WifiNan: ${sum / numOfItems} ms");
            stats.addAll({"TxRxTD WifiNan": sum / numOfItems});
          }
          stats.addAll({"number of WIFI NAN ODID messages": numOfItems});

          numOfItems = 0;
          sum = 0;

          // WIFI BEACON =======================================
          for (var element in odidMessages) {
            if (element.source.toString() == "MessageSource.WifiBeacon") {
              print("EXPORTER_LOG: WIFI BEACON");
              var diff = element.rxTime.difference(element.txTime!);
              // print("EXPORTER_LOG: TxRxTD WifiBeacon: ${diff.inMilliseconds} ms");
              if (diff.inMilliseconds > 0 && diff.inMinutes < 2) {
                numOfItems++;
                sum += diff.inMilliseconds;
              }
            }
          }
          stats.addAll({"number of WIFI BEACON ODID messages": numOfItems});

          if (sum > 0 && numOfItems > 0) {
            print("EXPORTER_LOG: TxRxTD WifiBeacon: ${sum / numOfItems} ms");
            stats.addAll({"TxRxTD WifiBeacon": sum / numOfItems});
          }
        }
      } on Exception catch (e) {
        statErr = e;
        print("EXPORTER_LOG: Stop Logger ERR: ${e.toString()}");
      }
      if (statErr != null) {
        stats.addAll({"StatError": statErr.toString()});
      }
      stats.addAll({
        "number of ALL Locations": myLocations.length,
        "number of ALL ODID messages": odidMessages.length
      });

      var data = <String, dynamic>{};
      data.addAll(devInfoJson);
      data.addAll({
        'myLocations':
            myLocations.map((position) => position.toJson()).toList(),
        'odidData': odidMessages.map((message) => message.toJson()).toList(),
        'distancesRssi':
            droneDistanceRssi.map((message) => message.toJson()).toList(),
        'stats': stats,
      });

      log(data.toString());
      try {
        await saveFileAllData!
            .writeAsString(jsonEncode(data), mode: FileMode.append);
      } on Exception catch (e) {
        log("stopLogger: saveFileAllData!.writeAsString ERR: ${e.toString()}");
        print(
            "stopLogger: saveFileAllData!.writeAsString ERR: ${e.toString()}");
      }

      if (positionStream != null) {
        positionStream!.cancel();
      }

      logging = false;
      blankFileLoc = true;
      blankFileOdid = true;
      print("EXPORTER_LOG: Stopped Logger");

      _shareExportFile();
      return true;
    } on Exception catch (e) {
      print("EXPORTER_LOG: Stop Logger ERR: ${e.toString()}");
      return e;
    }
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

  void newPack(MessageContainer pack, int id) {
    if (saveFileAllData != null) {
      var txTime = pack.selfIdMessage != null
          ? parseTime(pack.selfIdMessage!.description.toString())
          : null;
      pack.txTime = txTime;
      odidMessages.add(pack);

      try {
        saveFileODID!.writeAsString(
            "${blankFileOdid ? "" : ","}${jsonEncode(pack.toJson())}",
            mode: FileMode.append);
      } on Exception catch (e) {
        print("newPack writeAsString ERR: ${e.toString()}");
        log("newPack writeAsString ERR: ${e.toString()}");
      }
      blankFileOdid = false;

      if (myLastLocation != null &&
          pack.locationMessage != null &&
          pack.locationValid &&
          pack.lastMessageRssi != null) {
        if (pack.locationMessage!.location != null) {
          var dat = RssiDistance(
              myPosition: myLastLocation!,
              dronePosition: pack.locationMessage!,
              distanceMetres: Geolocator.distanceBetween(
                  pack.locationMessage!.location!.latitude,
                  pack.locationMessage!.location!.longitude,
                  myLastLocation!.latitude,
                  myLastLocation!.longitude),
              rssi: pack.lastMessageRssi!,
              sourceTech: pack.source.toString());
          droneDistanceRssi.add(dat);
        }
      }
    }

    // print("EXPORTER_LOG: Got message pack ($id): TECH: ${pack.source.toString()} RSSI: ${pack.lastMessageRssi} TxT: ($txTime) RxT: (${pack.rxTime!.toIso8601String()}), PostProcessingTime: (${pack.postProcessTime!.toIso8601String()})");

    // print("EXPORTER_VERBOSE: Got message pack ($id) ($txTime): ${pack.toString()}");
  }

  Future<String> getDeviceInformation() async {
    var deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var androidInfo = await deviceInfo.androidInfo;

        var deviceInfoJson = '''
          "device_info": {
            "Device": "${androidInfo.device}",
            "Model": "${androidInfo.model}",
            "Android_Version": "${androidInfo.version.release}",
            "Android_SDK": "${androidInfo.version.sdkInt}",
            "Android_BaseOS": "${androidInfo.version.baseOS}",
            "Product": "${androidInfo.product}",
            "Manufacturer": "${androidInfo.manufacturer}",
            "Board": "${androidInfo.board}",
            "Brand": "${androidInfo.brand}",
            "Hardware": "${androidInfo.hardware}",
            "ID": "${androidInfo.id}"
          }
      ''';
        return deviceInfoJson;
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        var deviceInfoJson = '''
          "device_info": {
            "Device": "${iosInfo.name}",
            "Model": "${iosInfo.model}",
            "System_Version": "${iosInfo.systemVersion}",
            "Identifier": "${iosInfo.identifierForVendor}",
            "Localized_Model": "${iosInfo.localizedModel}",
            "UTDID": "${iosInfo.utsname.machine}"
          }
      ''';
        return deviceInfoJson;
      }
    } catch (e) {
      print('EXPORTER_LOG: Failed to get device info: $e');
    }
    // Return an empty string if device info retrieval fails
    return '"device_info": "Error getting data"';
  }

  Future<Map<String, dynamic>> getDeviceInformationJson() async {
    var deviceInfo = DeviceInfoPlugin();
    var deviceInfoMap = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        var androidInfo = await deviceInfo.androidInfo;
        deviceInfoMap = {
          'device_info': {
            'Device': androidInfo.device,
            'Model': androidInfo.model,
            'Android_Version': androidInfo.version.release,
            'Android_SDK': androidInfo.version.sdkInt,
            'Android_BaseOS': androidInfo.version.baseOS,
            'Product': androidInfo.product,
            'Manufacturer': androidInfo.manufacturer,
            'Board': androidInfo.board,
            'Brand': androidInfo.brand,
            'Hardware': androidInfo.hardware,
            'ID': androidInfo.id,
          }
        };
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        deviceInfoMap = {
          'device_info': {
            'Device': iosInfo.name,
            'Model': iosInfo.model,
            'System_Version': iosInfo.systemVersion,
            'Identifier': iosInfo.identifierForVendor,
            'Localized_Model': iosInfo.localizedModel,
            'UTDID': iosInfo.utsname.machine,
          }
        };
      }
    } catch (e) {
      print('EXPORTER_LOG: Failed to get device info: $e');
      // Set an error message in the map
      deviceInfoMap = {
        'device_info': {'error': 'Failed to get device info: $e'}
      };
    }

    return deviceInfoMap;
  }

  void locationUpdate(Position? position) {
    if (position != null) {
      var pos = PositionDetail(
          longitude: position.longitude,
          latitude: position.latitude,
          timestamp: position.timestamp,
          accuracy: position.accuracy,
          altitude: position.altitude,
          altitudeAccuracy: position.altitudeAccuracy,
          heading: position.heading,
          headingAccuracy: position.headingAccuracy,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
          dateTime: DateTime.now());
      myLastLocation = pos;
      myLocations.add(pos);

      if (saveFileDeviceLocation != null) {
        saveFileDeviceLocation!.writeAsString(
            "${blankFileLoc ? "" : ","}${jsonEncode(pos.toJson())}",
            mode: FileMode.append);
        blankFileLoc = false;
      }
    }
    print(position == null
        ? 'EXPORTER_LOG: Got location update: Unknown'
        : 'EXPORTER_LOG: Got location update: ${position.latitude.toString()}, ${position.longitude.toString()}');
  }

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print("EXPORTER: Location services are disabled.");

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print("EXPORTER_LOG: Location permissions are denied");

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print(
          "EXPORTER_LOG: Location permissions are permanently denied, we cannot request permissions.");

      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return true;
  }

  void startLocationTracker() async {
    print("EXPORTER_LOG: Started Location Tracker");

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen(locationUpdate);
  }

  // Future<bool> exportAllPacksToCSV() async {
  //   final hasPerm = await checkStoragePermission();
  //   if (!hasPerm) {
  //     return false;
  //   }
  //   var data = '';
  //   aircraftCubit.state.packHistory().forEach((key, value) {
  //     data += _createCSV(includeHeader: data == '', packs: value);
  //     data += '\n';
  //   });
  //   if (data.isEmpty) return false;
  //   return await _shareExportFile(
  //       format: ExportFormat.csv, data: data, name: 'all');
  // }

  // Future<bool> exportPack({
  //   required ExportFormat format,
  //   required String mac,
  // }) async {
  //   final aircraftState = aircraftCubit.state;
  //   if (aircraftState.packHistory()[mac] == null) return false;
  //   // request permission
  //   final hasPermission = await checkStoragePermission();
  //   if (!hasPermission) return false;

  //   String? data;
  //   if (format == ExportFormat.csv) {
  //     data = _createCSV(
  //         includeHeader: true, packs: aircraftState.packHistory()[mac]!);
  //   } else if (format == ExportFormat.gpx) {
  //     data = GPXLogger.createGPX(aircraftState.packHistory()[mac]!);
  //   }
  //   if (data == null || data.isEmpty) return false;

  //   return await _shareExportFile(
  //       format: format, data: data, name: _createFilename(mac));
  // }

  Future<bool> checkStoragePermission() async {
    if (Platform.isIOS) {
      return _storagePermissionCheck();
    } else {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      // Since Android SDK 33, storage is not used
      if (androidInfo.version.sdkInt >= 33) {
        return await _mediaStoragePermissionCheck();
      } else {
        return await _storagePermissionCheck();
      }
    }
  }

  String _createCSV(
          {required bool includeHeader,
          required List<MessageContainer> packs}) =>
      const ListToCsvConverter()
          .convert(CSVLogger.createCSV(packs, includeHeader: includeHeader));

  String _createFilename(String mac) {
    final aircraftState = aircraftCubit.state;

    late final String filename;
    if (aircraftState.packHistory()[mac]!.isNotEmpty &&
        aircraftState
                .packHistory()[mac]
                ?.last
                .basicIdMessage
                ?.uasID
                .asString() !=
            null) {
      filename = aircraftState
          .packHistory()[mac]!
          .last
          .basicIdMessage!
          .uasID
          .asString()!;
    } else {
      filename = mac;
    }
    return filename;
  }

  Future<bool> _storagePermissionCheck() async {
    final storage = await Permission.storage.status.isGranted;
    if (!storage) {
      return await Permission.storage.request().isGranted;
    }
    return storage;
  }

  Future<bool> _mediaStoragePermissionCheck() async {
    var videos = await Permission.videos.status.isGranted;
    var photos = await Permission.photos.status.isGranted;
    if (!videos || !photos) {
      // request at once, will produce 1 dialog
      videos = await Permission.videos.request().isGranted;
      photos = await Permission.videos.request().isGranted;
    }
    return videos && photos;
  }

  Future<bool> _shareExportFile() async {
    late final ShareResult result;
    if (Platform.isAndroid) {
      result = await Share.shareXFiles(
        [
          XFile(saveFileDeviceLocationPath!),
          XFile(saveFileODIDPath!),
          XFile(saveFileAllDataPath!)
        ],
      );
    } else {
      result = await Share.shareXFiles(
        [
          XFile(saveFileDeviceLocationPath!),
          XFile(saveFileODIDPath!),
          XFile(saveFileAllDataPath!)
        ],
      );
    }
    if (result.status == ShareResultStatus.success) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _shareExportFileOld(
      {required ExportFormat format,
      required String data,
      required String name}) async {
    // final directory = await getApplicationDocumentsDirectory();
    // final suffix = format == ExportFormat.csv ? 'csv' : 'gpx';

    // final pathOfTheFileToWrite =
    //     '${directory.path}/drone_scanner_export_$name.$suffix';
    // var file = File(pathOfTheFileToWrite);
    // file = await file.writeAsString(data);
    // file.writeAsString(contents, mode: FileMode.append);

    late final ShareResult result;
    if (Platform.isAndroid) {
      result = await Share.shareXFiles([
        XFile(saveFileDeviceLocationPath!),
        XFile(saveFileODIDPath!),
        XFile(saveFileAllDataPath!)
      ], subject: 'Drone Scanner Export', text: 'Your Remote ID Data');
    } else {
      result = await Share.shareXFiles(
        [
          XFile(saveFileDeviceLocationPath!),
          XFile(saveFileODIDPath!),
          XFile(saveFileAllDataPath!)
        ],
      );
    }
    if (result.status == ShareResultStatus.success) {
      return true;
    } else {
      return false;
    }
  }
}
