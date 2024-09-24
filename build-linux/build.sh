#!/bin/bash

set -e

# Config

export SCONS="scons -j${NUM_CORES} verbose=yes warnings=no progress=no"
export OPTIONS="production=yes"
export OPTIONS_MONO="module_mono_enabled=yes"
export TERM=xterm

# Classical

if [ "${CLASSICAL}" == "1" ]; then
  echo "Starting classical build for Linux..."

  pushd /root/out/godot_x86_64_linux-release
    export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"
    rm -rf bin || true
    $SCONS platform=linuxbsd $OPTIONS arch=x86_64 target=editor
    $SCONS platform=linuxbsd $OPTIONS arch=x86_64 target=template_release

    # write `extension_api.json`
    ./bin/godot.linuxbsd.editor.x86_64 --headless --dump-extension-api
    cp extension_api.json /root/files/linux_x86_64_extension_api.json
  popd

  # pushd /root/out/godot_arm64_linux-release
  #   export PATH="${GODOT_SDK_LINUX_ARM64}/bin:${BASE_PATH}"
  #   rm -rf bin || true
  #   $SCONS platform=linuxbsd $OPTIONS arch=arm64 target=editor
  #   $SCONS platform=linuxbsd $OPTIONS arch=arm64 target=template_release
  # popd
fi

# Mono

if [ "${MONO}" == "1" ]; then
  echo "Starting Mono build for Linux..."

  pushd /root/out/godot_x86_64_linux_mono-release
    rm -rf bin || true
    cp -r /root/out/mono-glue/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/
    cp -r /root/out/mono-glue/GodotSharp/GodotSharpEditor/Generated modules/mono/glue/GodotSharp/GodotSharpEditor/

    export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"
    $SCONS platform=linuxbsd $OPTIONS $OPTIONS_MONO arch=x86_64 target=editor
    $SCONS platform=linuxbsd $OPTIONS $OPTIONS_MONO arch=x86_64 target=template_release
    ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=linuxbsd

    ./bin/godot.linuxbsd.editor.x86_64.mono --headless --dump-extension-api
    cp extension_api.json /root/files/linux_x86_64_mono_extension_api.json
  popd

  # pushd /root/out/godot_arm64_linux_mono-release
  #   rm -rf bin || true
  #   cp -r /root/out/mono-glue/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/
  #   cp -r /root/out/mono-glue/GodotSharp/GodotSharpEditor/Generated modules/mono/glue/GodotSharp/GodotSharpEditor/

  #   export PATH="${GODOT_SDK_LINUX_ARM64}/bin:${BASE_PATH}"
  #   $SCONS platform=linuxbsd $OPTIONS $OPTIONS_MONO arch=arm64 target=editor
  #   $SCONS platform=linuxbsd $OPTIONS $OPTIONS_MONO arch=arm64 target=template_release
  #   ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=linuxbsd
  # popd
fi

echo "Linux build successful"
