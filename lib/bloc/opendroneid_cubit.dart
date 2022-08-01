import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:flutter_opendroneid/pigeon.dart';

import 'aircraft/aircraft_cubit.dart';
import 'aircraft/selected_aircraft_cubit.dart';
import 'map/map_cubit.dart';

class ScanningState {
  bool isScanningWifi;
  bool isScanningBluetooth;
  UsedTechnologies usedTechnologies;

  ScanningState({
    required this.isScanningWifi,
    required this.isScanningBluetooth,
    required this.usedTechnologies,
  });

  ScanningState copyWith({
    bool? isScanningWifi,
    bool? isScanningBluetooth,
    UsedTechnologies? usedTechnologies,
  }) =>
      ScanningState(
        isScanningBluetooth: isScanningBluetooth ?? this.isScanningBluetooth,
        isScanningWifi: isScanningWifi ?? this.isScanningWifi,
        usedTechnologies: usedTechnologies ?? this.usedTechnologies,
      );
}

class OpendroneIdCubit extends Cubit<ScanningState> {
  StreamSubscription? listener;
  StreamSubscription? btStateListener;
  StreamSubscription? wifiStateListener;
  MapCubit mapCubit;
  SelectedAircraftCubit selectedAircraftCubit;
  AircraftCubit aircraftCubit;

  OpendroneIdCubit({
    required this.mapCubit,
    required this.selectedAircraftCubit,
    required this.aircraftCubit,
  }) : super(
          ScanningState(
            isScanningBluetooth: false,
            isScanningWifi: false,
            usedTechnologies: UsedTechnologies.None,
          ),
        ) {
    btStateListener = FlutterOpenDroneId.bluetoothState.listen(btStateCallback);
    wifiStateListener = FlutterOpenDroneId.wifiState.listen(
      (scanning) => wifiStateCallback(
        isScanning: scanning,
      ),
    );
  }

  void cancelListener() {
    listener?.cancel();
    btStateListener?.cancel();
    wifiStateListener?.cancel();
  }

  void btStateCallback(BluetoothState btstate) {
    emit(
      state.copyWith(isScanningBluetooth: btstate == BluetoothState.PoweredOn),
    );
  }

  void wifiStateCallback({required bool isScanning}) {
    emit(
      state.copyWith(isScanningWifi: isScanning),
    );
  }

  void scanCallback(MessagePack pack) {
    aircraftCubit.addPack(pack);
    if (mapCubit.state.lockOnPoint &&
        pack.macAddress == selectedAircraftCubit.state.selectedAircraftMac &&
        pack.locationMessage != null &&
        pack.locationMessage!.latitude != null &&
        pack.locationMessage!.longitude != null) {
      mapCubit.centerToLocDouble(
        pack.locationMessage!.latitude!,
        pack.locationMessage!.longitude!,
      );
    }
  }

  Future<void> start() async {
    if (state.usedTechnologies == UsedTechnologies.None) return;
    listener = FlutterOpenDroneId.allMessages.listen(scanCallback);
    unawaited(FlutterOpenDroneId.startScan(state.usedTechnologies));
  }

  Future<bool> isBtTurnedOn() async {
    return FlutterOpenDroneId.btTurnedOn;
  }

  Future<void> stop() async {
    await listener?.cancel();
    unawaited(FlutterOpenDroneId.stopScan());
  }

  Future<void> setBtUsed({required bool btUsed}) async {
    var restart = false;
    var usedT = state.usedTechnologies;
    // turning on bt, if wifi was active, restart scans
    if (btUsed) {
      if (state.usedTechnologies != UsedTechnologies.Wifi) {
        usedT = UsedTechnologies.Bluetooth;
      } else {
        usedT = UsedTechnologies.Both;
      }
      if (state.isScanningWifi) await FlutterOpenDroneId.stopScan();
      restart = true;
    }
    // turning off Bt, if wifi is still active, restart scans
    else {
      if (state.usedTechnologies == UsedTechnologies.Wifi ||
          state.usedTechnologies == UsedTechnologies.Both) {
        if (state.isScanningWifi) {
          await FlutterOpenDroneId.stopScan();
          restart = true;
        }
        usedT = UsedTechnologies.Wifi;
      } else {
        await stop();
        usedT = UsedTechnologies.None;
      }
    }
    emit(state.copyWith(usedTechnologies: usedT));
    if (restart) {
      unawaited(start());
    }
  }

  Future<void> setWifiUsed({required bool wifiUsed}) async {
    var restart = false;
    var usedT = state.usedTechnologies;
    // turning on Wifi, if bt was active, restart scans
    if (wifiUsed) {
      if (state.usedTechnologies != UsedTechnologies.Bluetooth) {
        usedT = UsedTechnologies.Wifi;
      } else {
        usedT = UsedTechnologies.Both;
      }
      if (state.isScanningBluetooth) await FlutterOpenDroneId.stopScan();
      restart = true;
    }
    // turning off Wifi, if bt is still active, restart scans
    else {
      if (state.usedTechnologies == UsedTechnologies.Bluetooth ||
          state.usedTechnologies == UsedTechnologies.Both) {
        if (state.isScanningBluetooth) {
          await FlutterOpenDroneId.stopScan();
          restart = true;
        }
        usedT = UsedTechnologies.Bluetooth;
      } else {
        await stop();
        usedT = UsedTechnologies.None;
      }
    }
    emit(state.copyWith(usedTechnologies: usedT));
    if (restart) {
      unawaited(start());
    }
  }
}
