#!/bin/bash

set -e

# Config

export SCONS="scons -j${NUM_CORES} verbose=yes warnings=no progress=no"
export OPTIONS="production=yes angle_libs=/root/angle mesa_libs=/root/mesa d3d12=no"
export OPTIONS_MONO="module_mono_enabled=yes"
export TERM=xterm

# Classical

if [ "${CLASSICAL}" == "1" ]; then
  echo "Starting classical build for Windows..."

  pushd /root/out/godot_x86_64_windows-release
    rm -rf bin || true
    $SCONS platform=windows arch=x86_64 $OPTIONS target=editor
    mkdir -p /root/out/x86_64/tools
    cp -rvp bin/* /root/out/x86_64/tools
    rm -rf bin

    $SCONS platform=windows arch=x86_64 $OPTIONS target=template_release
    mkdir -p /root/out/x86_64/templates
    cp -rvp bin/* /root/out/x86_64/templates
    rm -rf bin
  popd

  # $SCONS platform=windows arch=x86_32 $OPTIONS target=editor
  # mkdir -p /root/out/x86_32/tools
  # cp -rvp bin/* /root/out/x86_32/tools
  # rm -rf bin

  # $SCONS platform=windows arch=x86_32 $OPTIONS target=template_release
  # mkdir -p /root/out/x86_32/templates
  # cp -rvp bin/* /root/out/x86_32/templates
  # rm -rf bin
fi

# Mono

if [ "${MONO}" == "1" ]; then
  echo "Starting Mono build for Windows..."

  cp -r /root/mono-glue/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/
  cp -r /root/mono-glue/GodotSharp/GodotSharpEditor/Generated modules/mono/glue/GodotSharp/GodotSharpEditor/

  $SCONS platform=windows arch=x86_64 $OPTIONS $OPTIONS_MONO target=editor
  ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=windows
  mkdir -p /root/out/x86_64/tools-mono
  cp -rvp bin/* /root/out/x86_64/tools-mono
  rm -rf bin

  $SCONS platform=windows arch=x86_64 $OPTIONS $OPTIONS_MONO target=template_debug
  $SCONS platform=windows arch=x86_64 $OPTIONS $OPTIONS_MONO target=template_release
  mkdir -p /root/out/x86_64/templates-mono
  cp -rvp bin/* /root/out/x86_64/templates-mono
  rm -rf bin

  # $SCONS platform=windows arch=x86_32 $OPTIONS $OPTIONS_MONO target=editor
  # ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=windows
  # mkdir -p /root/out/x86_32/tools-mono
  # cp -rvp bin/* /root/out/x86_32/tools-mono
  # rm -rf bin

  # $SCONS platform=windows arch=x86_32 $OPTIONS $OPTIONS_MONO target=template_debug
  # $SCONS platform=windows arch=x86_32 $OPTIONS $OPTIONS_MONO target=template_release
  # mkdir -p /root/out/x86_32/templates-mono
  # cp -rvp bin/* /root/out/x86_32/templates-mono
  # rm -rf bin
fi

echo "Windows build successful"
