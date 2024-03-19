# dart_opendroneid

A Dart library for parsing Remote ID advertisements from raw binary payload.

The format of data is defined in the [ASTM F3411](https://www.astm.org/f3411-22a.html) Remote ID and the [ASD-STAN prEN 4709-002](http://asd-stan.org/downloads/asd-stan-pren-4709-002-p1/) Direct Remote ID specifications.

## Features

Currently supports parsing of the following message types:
- Basic ID
- Location
- Self ID
- System
- Operator ID
- Auth
- Message Pack


## Prerequisites

- Dart 2.19 or newer

## Getting started

To start using the library, simply add it to your `pubspec.yaml` file and run `dart pub get`.

## Usage

```dart
import 'dart:typed_data';

import 'package:dart_opendroneid/dart_opendroneid.dart';

final Uint8List messageData = Uint8List.fromList([
  // Message Type = Basic ID, Protcol ver. = 2
  0x02,
  // ID type = Serial Number (ANSI/CTA-2063-A), UA Type = Aircraft
  0x11,
  // UAS ID = 15968DEADBEEF
  0x31, 0x35, 0x39, 0x36, 0x38, 0x44, 0x45, 0x41, 0x44, 0x42, 0x45, 0x45, 0x46,
  // NULL padding
  // ...
]);

final type = determineODIDMessageType(messageData);
// Returns BasicIDMessage

final message = parseODIDMessage(messageData);
// Returns BasicIDMessage(...)
```


## Testing

### Local

The provided test suite uses [opendroneid-core-c](https://github.com/opendroneid/opendroneid-core-c) (present in `test/opendroneid_core_library`) as reference implementation. Dart FFI is used to call this reference implementation and it is expected that built binary is present in the following path:

- Linux: `test/opendroneid_core_library/libopendroneid.so`
- Windows: `test/opendroneid_core_library/libopendroneid.dll`
- Mac OS: `test/opendroneid_core_library/libopendroneid.dylib`

Before running the tests, Dart FFI bindings have to be generated. Make sure you have the necessary [ffigen requirements](https://pub.dev/packages/ffigen) and run `dart run ffigen`.

With all the requirements in place, tests can be run with `dart test`.
### Docker

To test the library, the provided Docker image can be used by running the following command from repository root:
```
docker build --target test .
```

A short-hand for running the test can be used if you have [RPS](https://pub.dev/packages/rps) installed:
```
rps test
```

## Publishing

dart-opendroneid is automatically published to pub.dev using our GitHub Actions workflows.
[Semantic Release](https://semantic-release.gitbook.io/semantic-release/) is used to determine release version.

---

&copy; 2023 [Dronetag](https://www.dronetag.cz)  
[www.dronetag.cz](https://www.dronetag.cz) 