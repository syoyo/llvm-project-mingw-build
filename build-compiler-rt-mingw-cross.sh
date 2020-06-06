#!/bin/bash

# --- config ---

LLVM_MINGW_PATH=${LLVM_MINGW_DIR:-/home/syoyo/local/llvm-mingw-20200325-ubuntu-18.04}

# --------------

echo "Use llvm-mingw path: " ${LLVM_MINGW_PATH}

curdir=`pwd`
distdir=`pwd`/dist-w64-mingw32
native_distdir=`pwd`/dist-native
builddir=`pwd`/build-compiler-rt-mingw-cross

arch=x86_64
buildarchname=x86_64

if [ -d "${builddir}" ]; then
  rm -rf ${builddir}
fi

mkdir ${builddir}

#  -DCMAKE_AR="${native_distdir}/bin/llvm-ar" \
#  -DCMAKE_RANLIB="${native_distdir}/bin/llvm-ranlib" \


cd ${builddir} && cmake \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DCMAKE_INSTALL_PREFIX="${distdir}" \
  -DCMAKE_SYSTEM_NAME=Windows \
  -DCMAKE_C_COMPILER=${LLVM_MINGW_PATH}/bin/${arch}-w64-mingw32-clang \
  -DCMAKE_CXX_COMPILER=${LLVM_MINGW_PATH}/bin/${arch}-w64-mingw32-clang++ \
  -DCMAKE_C_COMPILER_WORKS=1 \
  -DCMAKE_CXX_COMPILER_WORKS=1 \
  -DCMAKE_C_COMPILER_TARGET=$buildarchname-windows-gnu \
  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=TRUE \
  -DCOMPILER_RT_USE_BUILTINS_LIBRARY=TRUE \
  ../llvm-project/compiler-rt

cmake --build ${builddir} && cmake --build ${builddir} --target install
