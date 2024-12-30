#!/bin/bash

cd "$(dirname "$0")"

# Generate the patch files.
diff --label "/dev/null" --label "BUILD.bazel" -u /dev/null build_file > add_build_file.patch
diff --label "/dev/null" --label "MODULE.bazel" -u /dev/null module_dot_bazel > add_module_dot_bazel.patch

# Get the patch sha256 hashes in the format that source.json wants.
BUILD_SHA=`cat add_build_file.patch | openssl dgst -sha256 -binary | openssl base64 -A`
MODULE_SHA=`cat add_module_dot_bazel.patch | openssl dgst -sha256 -binary | openssl base64 -A`

CMATH_SHA=`cat cmath.patch | openssl dgst -sha256 -binary | openssl base64 -A`
CSTDLIB_SHA=`cat cstdlib.patch | openssl dgst -sha256 -binary | openssl base64 -A`
STD_ABS_SHA=`cat std_abs.h.patch | openssl dgst -sha256 -binary | openssl base64 -A`

# Re-write source.json using the new patch hashes.
read -r -d '' SOURCE_JSON_START <<EOF
{
    "integrity": "sha256-b44SLhuG4hmmoPAGQR2u9jJ/+NwidlW5aO0AQww9N2E=",
    "strip_prefix": "avr-libstdcpp-master",
    "url": "https://github.com/modm-io/avr-libstdcpp/archive/refs/heads/master.zip",
    "patch_strip": 0,
    "patches": {
EOF

echo "$SOURCE_JSON_START" > ../source.json
echo "       \"add_build_file.patch\": \"sha256-$BUILD_SHA\"," >> ../source.json
echo "       \"add_module_dot_bazel.patch\": \"sha256-$MODULE_SHA\"," >> ../source.json
echo "       \"cmath.patch\": \"sha256-$CMATH_SHA\"," >> ../source.json
echo "       \"cstdlib.patch\": \"sha256-$CSTDLIB_SHA\"," >> ../source.json
echo "       \"std_abs.h.patch\": \"sha256-$STD_ABS_SHA\"" >> ../source.json
echo "    }" >> ../source.json
echo "}" >> ../source.json

# Copy the module file up to MODULE.bazel to keep them in sync.
cp module_dot_bazel ../MODULE.bazel
