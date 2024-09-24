#!/bin/bash

set -e

# Config

export SCONS="scons -j${NUM_CORES} verbose=yes warnings=no progress=no"
export OPTIONS="osxcross_sdk=darwin23.6 production=yes use_volk=no vulkan_sdk_path=/root/out/deps/moltenvk angle_libs=/root/out/deps/angle"
export OPTIONS_MONO="module_mono_enabled=yes"
export STRIP="x86_64-apple-darwin23.6-strip -u -r"
export TERM=xterm

# Classical

if [ "${CLASSICAL}" == "1" ]; then
  echo "Starting classical build for macOS..."

  # pushd /root/out/godot_x86_64_macos-release
  #   rm -rf bin || true
  #   $SCONS platform=macos $OPTIONS arch=x86_64 target=editor
  #   $SCONS platform=macos $OPTIONS arch=x86_64 target=template_release
  # popd

  pushd /root/out/godot_arm64_macos-release
    rm -rf bin || true
    $SCONS platform=macos $OPTIONS arch=arm64 target=editor
    $SCONS platform=macos $OPTIONS arch=arm64 target=template_release
  popd
fi

# Mono

if [ "${MONO}" == "1" ]; then
  echo "Starting Mono build for macOS..."

  pushd /root/out/godot_x86_64_macos_mono-release
    rm -rf bin || true
    cp -r /root/out/mono-glue/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/
    cp -r /root/out/mono-glue/GodotSharp/GodotSharpEditor/Generated modules/mono/glue/GodotSharp/GodotSharpEditor/

    $SCONS platform=macos $OPTIONS $OPTIONS_MONO arch=x86_64 target=editor
    $SCONS platform=macos $OPTIONS $OPTIONS_MONO arch=x86_64 target=template_release
    ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=macos
  popd

  pushd /root/out/godot_arm64_macos_mono-release
    rm -rf bin || true
    cp -r /root/out/mono-glue/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/
    cp -r /root/out/mono-glue/GodotSharp/GodotSharpEditor/Generated modules/mono/glue/GodotSharp/GodotSharpEditor/

    $SCONS platform=macos $OPTIONS $OPTIONS_MONO arch=arm64 target=editor
    $SCONS platform=macos $OPTIONS $OPTIONS_MONO arch=arm64 target=template_release
    ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=macos
  popd
fi

echo "macOS build successful"
