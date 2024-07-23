#!/bin/bash

set -e

# Config

export SCONS="scons -j${NUM_CORES} verbose=yes warnings=no progress=no"
export OPTIONS="production=yes"
export OPTIONS_MONO="module_mono_enabled=yes"
export TERM=xterm

cd out/godot

# Classical

if [ "${CLASSICAL}" == "1" ]; then
  echo "Starting classical build for Linux..."

  export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"

  $SCONS platform=linuxbsd arch=x86_64 $OPTIONS target=editor
  mkdir -p /root/out/x86_64/tools
  cp -rvp bin/* /root/out/x86_64/tools
  rm -rf bin

  # write `extension_api.json`
  pushd /root/out/x86_64/tools/
  ./godot.linuxbsd.editor.x86_64 --headless --dump-extension-api
  cp extension_api.json /root/files/linux_x86_64_extension_api.json
  popd

  $SCONS platform=linuxbsd arch=x86_64 $OPTIONS target=template_release
  mkdir -p /root/out/x86_64/templates
  cp -rvp bin/* /root/out/x86_64/templates
  rm -rf bin

  # export PATH="${GODOT_SDK_LINUX_ARM64}/bin:${BASE_PATH}"

  # $SCONS platform=linuxbsd arch=arm64 $OPTIONS target=editor
  # mkdir -p /root/out/arm64/tools
  # cp -rvp bin/* /root/out/arm64/tools
  # rm -rf bin

  # # `extension_api.json` generation for arm64 is done later via qemu

  # $SCONS platform=linuxbsd arch=arm64 $OPTIONS target=template_release
  # mkdir -p /root/out/arm64/templates
  # cp -rvp bin/* /root/out/arm64/templates
  # rm -rf bin
fi

# Mono

if [ "${MONO}" == "1" ]; then
  echo "Starting Mono build for Linux..."

  cp -r /root/out/mono-glue/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/
  cp -r /root/out/mono-glue/GodotSharp/GodotSharpEditor/Generated modules/mono/glue/GodotSharp/GodotSharpEditor/

  export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"

  $SCONS platform=linuxbsd arch=x86_64 $OPTIONS $OPTIONS_MONO target=editor
  ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=linuxbsd
  mkdir -p /root/out/x86_64/tools-mono
  cp -rvp bin/* /root/out/x86_64/tools-mono
  rm -rf bin

  $SCONS platform=linuxbsd arch=x86_64 $OPTIONS $OPTIONS_MONO target=template_release
  mkdir -p /root/out/x86_64/templates-mono
  cp -rvp bin/* /root/out/x86_64/templates-mono
  rm -rf bin

  # write `extension_api.json`
  pushd /root/out/x86_64/tools-mono/
  ./godot.linuxbsd.editor.x86_64.mono --headless --dump-extension-api
  cp extension_api.json /root/out/files/linux_x86_64_mono_extension_api.json
  popd

  # export PATH="${GODOT_SDK_LINUX_ARM64}/bin:${BASE_PATH}"

  # $SCONS platform=linuxbsd arch=arm64 $OPTIONS $OPTIONS_MONO target=editor
  # ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=linuxbsd
  # mkdir -p /root/out/arm64/tools-mono
  # cp -rvp bin/* /root/out/arm64/tools-mono
  # rm -rf bin

  # # `extension_api.json` generation for arm64 is done later via qemu

  # $SCONS platform=linuxbsd arch=arm64 $OPTIONS $OPTIONS_MONO target=template_release
  # mkdir -p /root/out/arm64/templates-mono
  # cp -rvp bin/* /root/out/arm64/templates-mono
  # rm -rf bin
fi

echo "Linux build successful"
