import 'dart:typed_data';

class LocationMessages {
  static final correctMessage = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final directionLessThan180 = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment < 180, Speed Multiplier = 0.75x
    0x15,
    // Track Direction = 30
    0x1E,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final speedMultiplier025 = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.25x
    0x16,
    // Track Direction = 225
    0x2D,
    // Speed = 4.5 m/s
    0x12,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final positiveVerticalSpeed = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = 11.5 m/s
    0x17,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final negativeLatitude = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = -33.93067431876772
    0x09,
    0x97,
    0xC6,
    0xEB,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final negativeLongitude = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = -77.03332958707917
    0x91,
    0xA5,
    0x15,
    0xD2,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final negativePressureAltitude = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = -345m
    0x1E,
    0x05,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final positiveGeodeticAltitude = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = 888.5m
    0xC1,
    0x0E,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final negativeHeight = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = -35m
    0x8A,
    0x07,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final verticalAccuracyLessThan25Meters = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <25m, Horizontal Accuracy = <10 m
    0x3A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final horizontalAccuracyLessThan7Kilometers = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <7.408km
    0x62,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final baroAltitudeLessThan150Meters = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <150 m, Speed Accuracy = <1 m/s
    0x13,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final speedAccLessThan03Mps = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <0.3 m/s
    0x44,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final timestamp59Minutes = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 59m (35400s) after last UTC hour
    0x48,
    0x8A,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final timestampAcc1200Milliseconds = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 1.2s
    0x0C,
    // Reserved field
    0x00,
  ]);

  static final unknownTrackDirection = Uint8List.fromList([
    // Message Type = Location, Protocol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.25x
    0x16,
    // Track Direction = 361 (designates unknown direction)
    0x1E,
    // Speed = 4.5 m/s
    0x12,
    // Vertical speed = 11.5 m/s
    0x17,
    // Latitude = -12.018694047593621
    0xC4,
    0x17,
    0xD6,
    0xF8,
    // Longitude = -77.03332958707917
    0x91,
    0xA5,
    0x15,
    0xD2,
    // Pressure Altitude = -345m
    0x1E,
    0x05,
    // Geodetic Altitude = 888.5m
    0xC1,
    0x0E,
    // Height = -35m
    0x8A,
    0x07,
    // Vertical Accuracy = <25m, Horizontal Accuracy = <7.408km
    0x32,
    // Baro Altitude Accuracy = <150 m, Speed Accuracy = <1 m/s
    0x14,
    // Timestamp = 59m (35400s) after last UTC hour
    0x48,
    0x8A,
    // Reserved field, Timestamp Accuracy = 1.2s
    0x0C,
    // Reserved field
    0x00,
  ]);

  static final unknownSpeed = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = Unknown (designated by 255 m/s)
    0xFF,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final unknownVerticalSpeed = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = Unknown (designated by 63 m/s)
    0x7E,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final unknownLocation = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = Unknown (designated by both Lat/Lng = 0)
    0x00,
    0x00,
    0x00,
    0x00,
    // Longitude = Unknown (designated by both Lat/Lng = 0)
    0x00,
    0x00,
    0x00,
    0x00,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final unknownPressureAltitude = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = Unknown (designated by -1000 m)
    0x00,
    0x00,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final unknownGeodeticAltitude = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = Unknown (designated by -1000 m)
    0x00,
    0x00,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final unknownHeight = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = Unknown (designated by -1000 m)
    0x00,
    0x00,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final unknownTimestamp = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = Unknown (designated by 0xFFFF)
    0xFF,
    0xFF,
    // Reserved field, Timestamp Accuracy = 0.2s
    0x02,
    // Reserved field
    0x00,
  ]);

  static final unknownTimestampAccuracy = Uint8List.fromList([
    // Message Type = Location, Protcol ver. = 2
    0x12,
    // Operational Status = Ground, Height Type = Above Ground Level, E/W Direction Segment >= 180, Speed Multiplier = 0.75x
    0x17,
    // Track Direction = 225
    0x2D,
    // Speed = 69.75 m/s
    0x08,
    // Vertical speed = -15 m/s
    0xE2,
    // Latitude = 50.086597690331196
    0xB8,
    0x9B,
    0xDA,
    0x1D,
    // Longitude = 14.411429315989649
    0x75,
    0x02,
    0x97,
    0x08,
    // Pressure Altitude = 248.5m
    0xC1,
    0x09,
    // Geodetic Altitude = -123.5m
    0xD9,
    0x06,
    // Height = 24m
    0x00,
    0x02,
    // Vertical Accuracy = <1 m, Horizontal Accuracy = <10 m
    0x6A,
    // Baro Altitude Accuracy = <10 m, Speed Accuracy = <1 m/s
    0x43,
    // Timestamp = 32.2s after last UTC hour
    0x42,
    0x01,
    // Reserved field, Timestamp Accuracy = Unknown (designated by 0)
    0x00,
    // Reserved field
    0x00,
  ]);

  static final correctCapturedMessage1 = Uint8List.fromList([
    0x12,
    0x07,
    0xB5,
    0xFF,
    0x7E,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  ]);

  static final correctCapturedMessage2 = Uint8List.fromList([
    0x12,
    0x13,
    0xB5,
    0xFF,
    0x7E,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0xC5,
    0x09,
    0x68,
    0x0A,
    0xD0,
    0x07,
    0x00,
    0x00,
    0xBE,
    0x14,
    0x01,
    0x00
  ]);

  static final correctCapturedMessage3 = Uint8List.fromList([
    0x12,
    0x20,
    0x08,
    0x00,
    0x00,
    0xCC,
    0xDD,
    0xDF,
    0x1D,
    0xBA,
    0xD4,
    0x8C,
    0x08,
    0x89,
    0x0A,
    0x89,
    0x0A,
    0xEE,
    0x07,
    0x6C,
    0x04,
    0x94,
    0x7E,
    0x00,
    0x00
  ]);

  static final correctCapturedMessage4 = Uint8List.fromList([
    0x12,
    0x20,
    0x2A,
    0x00,
    0x00,
    0xB9,
    0xDD,
    0xDF,
    0x1D,
    0x47,
    0xD6,
    0x8C,
    0x08,
    0x15,
    0x0A,
    0xCF,
    0x0A,
    0xCF,
    0x07,
    0x4A,
    0x03,
    0x1E,
    0x6E,
    0x00,
    0x00
  ]);

  static final correctCapturedMessage5 = Uint8List.fromList([
    0x12,
    0x10,
    0x2D,
    0x00,
    0x00,
    0x7A,
    0xDD,
    0xDF,
    0x1D,
    0xB8,
    0xD4,
    0x8C,
    0x08,
    0x17,
    0x0A,
    0xC7,
    0x0A,
    0xD0,
    0x07,
    0x5B,
    0x04,
    0xF0,
    0x69,
    0x00,
    0x00
  ]);
}
