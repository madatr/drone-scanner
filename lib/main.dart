import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'bloc/aircraft/aircraft_cubit.dart';
import 'bloc/aircraft/aircraft_expiration_cubit.dart';
import 'bloc/aircraft/export_cubit.dart';
import 'bloc/aircraft/selected_aircraft_cubit.dart';
import 'bloc/geocoding_cubit.dart';
import 'bloc/help/help_cubit.dart';
import 'bloc/map/map_cubit.dart';
import 'bloc/opendroneid_cubit.dart';
import 'bloc/proximity_alerts_cubit.dart';
import 'bloc/screen_cubit.dart';
import 'bloc/showcase_cubit.dart';
import 'bloc/sliders_cubit.dart';
import 'bloc/standards_cubit.dart';
import 'bloc/zones/selected_zone_cubit.dart';
import 'bloc/zones/zones_cubit.dart';
import 'services/geocoding_rest_client.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/ornithology_rest_client.dart';
import 'widgets/app/app.dart';

const sentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue: '',
);

const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool kDebugMode = !kReleaseMode && !kProfileMode;

/// Runs app with Sentry monitoring (only for production environment)
void runAppWithSentry(void Function() appRunner) async {
  if (sentryDsn == '') {
    Logger.root.info('There is no Sentry DSN specified!');
    appRunner();
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.debug = kDebugMode;
    },
    appRunner: appRunner,
  );
}

void main() async {
  // init high priority services
  WidgetsFlutterBinding.ensureInitialized();

  // Set-up logging to console
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.time} [${record.level.name}] ${record.loggerName}: '
        '${record.message}');
  });

  // init local notifications
  final notificationService = NotificationService();
  await notificationService.setup();
  // Init Google services
  final locationService = LocationService();
  final mapCubit = MapCubit(locationService);
  final selectedCubit = SelectedAircraftCubit();
  final aircraftExpirationCubit = AircraftExpirationCubit();
  final aircraftCubit = AircraftCubit(
      expirationCubit: aircraftExpirationCubit,
      ornithologyRestClient: OrnithologyRestClient());
  final proximityAlertsCubit =
      ProximityAlertsCubit(notificationService, aircraftCubit);
  final sheetLicense = await rootBundle.loadString('assets/docs/SHEET-LICENSE');
  LicenseRegistry.addLicense(() => Stream<LicenseEntry>.value(
        LicenseEntryWithLineBreaks(
          <String>['sliding_sheet'],
          sheetLicense,
        ),
      ));

  runAppWithSentry(
    () => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<StandardsCubit>(
            create: (context) => StandardsCubit(),
            lazy: false,
          ),
          BlocProvider<ScreenCubit>(
            create: (context) => ScreenCubit(),
            lazy: false,
          ),
          BlocProvider<SlidersCubit>(
            create: (context) => SlidersCubit(),
            lazy: false,
          ),
          BlocProvider<MapCubit>(
            create: (context) => mapCubit,
            lazy: false,
          ),
          BlocProvider<ShowcaseCubit>(
            create: (context) => ShowcaseCubit(),
            lazy: false,
          ),
          BlocProvider<ZonesCubit>(
            create: (context) => ZonesCubit(),
            lazy: false,
          ),
          BlocProvider<SelectedZoneCubit>(
            create: (context) => SelectedZoneCubit(),
            lazy: false,
          ),
          BlocProvider<AircraftCubit>(
            create: (context) => aircraftCubit,
            lazy: false,
          ),
          BlocProvider<ExportCubit>(
            create: (context) => ExportCubit(aircraftCubit: aircraftCubit),
            lazy: false,
          ),
          BlocProvider<AircraftExpirationCubit>(
            create: (context) => aircraftExpirationCubit,
            lazy: false,
          ),
          BlocProvider<ProximityAlertsCubit>(
            create: (context) => proximityAlertsCubit,
            lazy: false,
          ),
          BlocProvider<SelectedAircraftCubit>(
            create: (context) => selectedCubit,
            lazy: false,
          ),
          BlocProvider<OpendroneIdCubit>(
            create: (context) => OpendroneIdCubit(
              mapCubit: mapCubit,
              selectedAircraftCubit: selectedCubit,
              aircraftCubit: aircraftCubit,
            ),
            lazy: false,
          ),
          BlocProvider<HelpCubit>(
            create: (context) => HelpCubit(),
            lazy: false,
          ),
          BlocProvider<GeocodingCubit>(
            create: (context) => GeocodingCubit(
              geocodingRestClient: NominatimGeocodingRestClient(),
            ),
            lazy: false,
          ),
        ],
        child: App(),
      ),
    ),
  );
}
