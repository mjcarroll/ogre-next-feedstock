#!/bin/sh

# Workaround for PRIu64 not being defined
# See https://github.com/conda-forge/staged-recipes/pull/18792#issuecomment-1114606992
export CXXFLAGS="-D__STDC_FORMAT_MACROS $CXXFLAGS"

if [[ ${target_platform} == "linux-ppc64le" || ${target_platform} == "linux-aarch64" ]]; then
  export OGRE_SIMD_SSE2=OFF
  export OGRE_SIMD_NEON=OFF
elif [[ ${target_platform} == "osx-arm64" ]]; then
  export OGRE_SIMD_SSE2=OFF
  export OGRE_SIMD_NEON=ON
else
  export OGRE_SIMD_SSE2=ON
  export OGRE_SIMD_NEON=OFF
fi

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DBUILD_TESTING:BOOL=ON \
      -DOGRE_BUILD_TESTS:BOOL=ON \
      -DOGRE_BUILD_DOCS:BOOL=OFF \
      -DOGRE_BUILD_COMPONENT_HLMS:BOOL=ON \
      -DOGRE_BUILD_COMPONENT_HLMS_PBS:BOOL=ON \
      -DOGRE_BUILD_COMPONENT_HLMS_UNLIT:BOOL=ON \
      -DOGRE_BUILD_COMPONENT_OVERLAY:BOOL=ON \
      -DOGRE_BUILD_COMPONENT_PLANAR_REFLECTIONS:BOOL=ON \
      -DOGRE_BUILD_LIBS_AS_FRAMEWORKS:BOOL=OFF \
      -DOGRE_BUILD_RENDERSYSTEM_GLES2:BOOL=OFF \
      -DOGRE_BUILD_RENDERSYSTEM_METAL:BOOL=OFF \
      -DOGRE_BUILD_SAMPLES:BOOL=OFF \
      -DOGRE_BUILD_SAMPLES2:BOOL=OFF \
      -DOGRE_BUILD_TOOLS:BOOL=OFF \
      -DOGRE_CONFIG_UNIX_NO_X11:BOOL=OFF \
      -DOGRE_CONFIG_THREADS=0 \
      -DOGRE_CONFIG_THREAD_PROVIDER=std \
      -DOGRE_INSTALL_SAMPLES:BOOL=OFF \
      -DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=OFF \
      -DOGRE_INSTALL_TOOLS:BOOL=OFF \
      -DOGRE_GLSUPPORT_USE_EGL_HEADLESS:BOOL=ON \
      -DOGRE_USE_NEW_PROJECT_NAME:BOOL=ON \
      -DOGRE_SIMD_SSE2:BOOL=${OGRE_SIMD_SSE2} \
      -DOGRE_SIMD_NEON:BOOL=${OGRE_SIMD_NEON} \
      ..

cmake --build . --config Release --parallel ${CPU_COUNT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release
fi

cmake --build . --config Release --target install
