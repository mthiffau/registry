#!/bin/bash

cd "$(dirname "$0")"

# Generate the patch files.
diff --label "/dev/null" --label "BUILD.bazel" -u /dev/null build_file > add_build_file.patch
diff --label "/dev/null" --label "MODULE.bazel" -u /dev/null module_dot_bazel > add_module_dot_bazel.patch

# Get the patch sha256 hashes in the format that source.json wants.
BUILD_SHA=`cat add_build_file.patch | openssl dgst -sha256 -binary | openssl base64 -A`
MODULE_SHA=`cat add_module_dot_bazel.patch | openssl dgst -sha256 -binary | openssl base64 -A`

# Re-write source.json using the new patch hashes.
read -r -d '' SOURCE_JSON_START <<EOF
{
    "integrity": "sha256-SSQf1eUESCuUlUtYQ8fWnOOOvBq0etO2d+i7d+DLj+Y=",
    "strip_prefix": "ArduinoCore-avr-1.8.6",
    "url": "https://github.com/arduino/ArduinoCore-avr/archive/refs/tags/1.8.6.tar.gz",
    "patch_strip": 0,
    "patches": {
EOF

echo "$SOURCE_JSON_START" > ../source.json
echo "       \"add_build_file.patch\": \"sha256-$BUILD_SHA\"," >> ../source.json
echo "       \"add_module_dot_bazel.patch\": \"sha256-$MODULE_SHA\"" >> ../source.json
echo "    }" >> ../source.json
echo "}" >> ../source.json

# Copy the module file up to MODULE.bazel to keep them in sync.
cp module_dot_bazel ../MODULE.bazel
