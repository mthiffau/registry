#!/bin/bash

cd "$(dirname "$0")"

# Generate the patch files.
diff --label "/dev/null" --label "BUILD.bazel" -u /dev/null build_file > add_build_file.patch
diff --label "/dev/null" --label "MODULE.bazel" -u /dev/null module_dot_bazel > add_module_dot_bazel.patch
diff --label "/dev/null" --label "toolchain.bzl" -u /dev/null toolchain_bzl > add_toolchain_bzl.patch

# Get the patch sha256 hashes in the format that source.json wants.
BUILD_SHA=`cat add_build_file.patch | openssl dgst -sha256 -binary | openssl base64 -A`
MODULE_SHA=`cat add_module_dot_bazel.patch | openssl dgst -sha256 -binary | openssl base64 -A`
TOOLCHAIN_SHA=`cat add_toolchain_bzl.patch | openssl dgst -sha256 -binary | openssl base64 -A`

# Re-write source.json using the new patch hashes.
read -r -d '' SOURCE_JSON_START <<EOF
{
    "integrity": "sha256-pUF3HPwWfhOjIGA3Yl4V42nFYsKJUE7cqce3Z0OXQJY=",
    "strip_prefix": "avr8-gnu-toolchain-linux_x86_64",
    "url": "https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/avr8-gnu-toolchain-3.7.0.1796-linux.any.x86_64.tar.gz",
    "patch_strip": 0,
    "patches": {
EOF

echo "$SOURCE_JSON_START" > ../source.json
echo "       \"add_build_file.patch\": \"sha256-$BUILD_SHA\"," >> ../source.json
echo "       \"add_module_dot_bazel.patch\": \"sha256-$MODULE_SHA\"," >> ../source.json
echo "       \"add_toolchain_bzl.patch\": \"sha256-$TOOLCHAIN_SHA\"" >> ../source.json
echo "    }" >> ../source.json
echo "}" >> ../source.json

# Copy the module file up to MODULE.bazel to keep them in sync.
cp module_dot_bazel ../MODULE.bazel
