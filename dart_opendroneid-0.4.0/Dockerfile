# Dart build base
FROM dart:stable as base

WORKDIR /src
# COPY pubspec.* .
# RUN dart pub get

# TODO fix dart pub get before copy
COPY . .
RUN dart pub get

# OpenDroneID core library build
FROM silkeh/clang:latest as opendroneidcore

WORKDIR /opendroneidcore
COPY ./test/opendroneid_core_library/ ./
RUN cmake . && make

# OpenDroneID core library bindings generation
FROM dart:stable as bindgen

WORKDIR /src
COPY pubspec.* .
COPY test/opendroneid_core_library/ ./test/opendroneid_core_library/
RUN apt-get update && apt-get install -y libclang-dev && dart pub get && dart run ffigen

# Test image
FROM base as test

WORKDIR /src
COPY --from=opendroneidcore /opendroneidcore/libopendroneid.so /src/test/opendroneid_core_library/
COPY --from=bindgen /src/test/opendroneid_core_library/generated_bindings.dart /src/test/opendroneid_core_library/

RUN ["dart", "test"]
