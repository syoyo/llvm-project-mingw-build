#!/bin/bash

# --- config ---

LLVM_MINGW_DIR=/home/syoyo/local/llvm-mingw-20200325-ubuntu-18.04/

# --------------

curdir=`pwd`
distdir=`pwd`/dist-w64-mingw32
native_distdir=`pwd`/dist-native
builddir=`pwd`/build-llvm-mingw-cross

rm -rf ${builddir}
mkdir ${builddir}

LLVM_TBLGEN_PATH=${native_distdir}/bin/llvm-tblgen
CLANG_TBLGEN_PATH=${native_distdir}/bin/clang-tblgen
LLVM_CONFIG_FILENAME=${native_distdir}/bin/llvm-config


# LLVM_BUILD_LLVM_DYLIB=On: build libLLVM.dll
# turn off libxml2 since it requires iconv library
cd ${builddir} && cmake -G Ninja ../llvm-project/llvm \
   -DCMAKE_CROSSCOMPILING=True \
   -DCMAKE_SYSTEM_NAME=Windows \
   -DCMAKE_INSTALL_PREFIX=${distdir} \
   -DLLVM_TABLEGEN=${LLVM_TBLGEN_PATH} \
   -DCLANG_TABLEGEN=${CLANG_TBLGEN_PATH} \
   -DLLVM_CONFIG_PATH=${LLVM_CONFIG_FILENAME} \
   -DCMAKE_C_COMPILER=${LLVM_MINGW_DIR}/bin/x86_64-w64-mingw32-gcc \
   -DCMAKE_CXX_COMPILER=${LLVM_MINGW_DIR}/bin/x86_64-w64-mingw32-g++ \
   -DCMAKE_RC_COMPILER=${LLVM_MINGW_DIR}/bin/x86_64-w64-mingw32-windres \
   -DLLVM_ENABLE_LIBXML2=Off \
   -DLLVM_ENABLE_PROJECTS="clang" \
   -DLLVM_TARGETS_TO_BUILD="X86" \
   -DCMAKE_BUILD_TYPE=MinSizeRel \
   -DLLVM_BUILD_LLVM_DYLIB=On \
   -DLLVM_ENABLE_ASSERTIONS=ON && cd ${curdir}

cmake --build ${builddir} && cmake --build ${builddir} --target install
