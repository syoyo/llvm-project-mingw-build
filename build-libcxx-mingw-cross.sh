#!/bin/bash

# Based on: https://github.com/mstorsjo/llvm-mingw/blob/master/build-libcxx.sh

set -x
set -e

# --- config ---

LLVM_MINGW_PATH=${LLVM_MINGW_DIR:-/home/syoyo/local/llvm-mingw-20200325-ubuntu-18.04}

# --------------

curdir=`pwd`
distdir=`pwd`/dist-w64-mingw32
native_distdir=`pwd`/dist-native
libunwind_builddir=`pwd`/build-libunwind-mingw-cross
libcxxabi_builddir=`pwd`/build-libcxxabi-mingw-cross
libcxx_builddir=`pwd`/build-libcxx-mingw-cross

arch=x86_64
buildarchname=x86_64

# --- libunwind ------------------------------------

build_libunwind() {

  if [ -d "${libunwind_builddir}" ]; then
    rm -rf ${libunwind_builddir}
  fi
  
  mkdir ${libunwind_builddir}
  
  # -DLLVM_COMPILER_CHECKED=TRUE \
  # -DCXX_SUPPORTS_CXX_STD=TRUE \
  
  # CXX_SUPPORTS_CXX11 is not strictly necessary here. But if building
  # with a stripped llvm install, and the system happens to have an older
  # llvm-config in /usr/bin, it can end up including older cmake files,
  # and then CXX_SUPPORTS_CXX11 needs to be set.
  cd ${libunwind_builddir} && cmake \
              -G Ninja \
              -DCMAKE_BUILD_TYPE=MinSizeRel \
              -DCMAKE_INSTALL_PREFIX="${distdir}" \
              -DCMAKE_C_COMPILER=${LLVM_MINGW_PATH}/bin/${arch}-w64-mingw32-clang \
              -DCMAKE_CXX_COMPILER=${LLVM_MINGW_PATH}/bin/${arch}-w64-mingw32-clang++ \
              -DCMAKE_CROSSCOMPILING=TRUE \
              -DCMAKE_SYSTEM_NAME=Windows \
              -DCMAKE_C_COMPILER_WORKS=TRUE \
              -DCMAKE_CXX_COMPILER_WORKS=TRUE \
              -DCXX_SUPPORTS_CXX11=TRUE \
              -DLIBUNWIND_USE_COMPILER_RT=TRUE \
              -DLIBUNWIND_ENABLE_THREADS=TRUE \
              -DLIBUNWIND_ENABLE_SHARED=1 \
              -DLIBUNWIND_ENABLE_STATIC=1 \
              -DLIBUNWIND_ENABLE_CROSS_UNWINDING=FALSE \
              -DCMAKE_CXX_FLAGS="-Wno-dll-attribute-on-redeclaration" \
              -DCMAKE_C_FLAGS="-Wno-dll-attribute-on-redeclaration" \
              ../llvm-project/libunwind
  
  cmake --build ${libunwind_builddir} && cmake --build ${libunwind_builddir} --target install

}

# --- libcxxabi ------------------------------------

build_libcxxabi() {

  # args1 : "shared" or "static"
  build_type="$1"
  echo ${build_type}

  if [ "$build_type" = "shared" ]; then
      LIBCXXABI_VISIBILITY_FLAGS="-D_LIBCPP_BUILDING_LIBRARY= -U_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS"
  else
      LIBCXXABI_VISIBILITY_FLAGS="-D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS"
  fi
  
  if [ -d "${libcxxabi_builddir}" ]; then
    rm -rf ${libcxxabi_builddir}
  fi
  
  mkdir ${libcxxabi_builddir}
  
  cd ${libcxxabi_builddir} && cmake \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DCMAKE_INSTALL_PREFIX="${distdir}" \
      -DCMAKE_C_COMPILER=${LLVM_MINGW_PATH}/bin/${arch}-w64-mingw32-clang \
      -DCMAKE_CXX_COMPILER=${LLVM_MINGW_PATH}/bin/${arch}-w64-mingw32-clang++ \
      -DCMAKE_CROSSCOMPILING=TRUE \
      -DCMAKE_SYSTEM_NAME=Windows \
      -DCMAKE_C_COMPILER_WORKS=TRUE \
      -DCMAKE_CXX_COMPILER_WORKS=TRUE \
      -DLIBCXXABI_USE_COMPILER_RT=ON \
      -DLIBCXXABI_ENABLE_EXCEPTIONS=ON \
      -DLIBCXXABI_ENABLE_THREADS=ON \
      -DLIBCXXABI_TARGET_TRIPLE=$arch-w64-mingw32 \
      -DLIBCXXABI_ENABLE_SHARED=OFF \
      -DLIBCXXABI_LIBCXX_INCLUDES=`pwd`/../llvm-project/libcxx/include \
      -DLIBCXXABI_LIBDIR_SUFFIX="" \
      -DLIBCXXABI_ENABLE_NEW_DELETE_DEFINITIONS=OFF \
      -DCMAKE_CXX_FLAGS="$LIBCXXABI_VISIBILITY_FLAGS -D_LIBCPP_HAS_THREAD_API_WIN32" \
      ../llvm-project/libcxxabi
  
  cmake --build ${libcxxabi_builddir} && cmake --build ${libcxxabi_builddir} --target install

}

# --- libcxx ------------------------------------

build_libcxx() {

  # args1 : "shared" or "static"
  build_type="$1"
  echo ${build_type}

  if [ "$build_type" = "shared" ]; then
      LIBCXX_VISIBILITY_FLAGS="-D_LIBCXXABI_BUILDING_LIBRARY"
      SHARED=1
      STATIC=0
  else
      LIBCXX_VISIBILITY_FLAGS="-D_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS"
      SHARED=0
      STATIC=1
  fi

  if [ -d "${libcxx_builddir}" ]; then
    rm -rf ${libcxx_builddir}
  fi
  
  mkdir ${libcxx_builddir}
  
  cd ${libcxx_builddir} && cmake \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DCMAKE_INSTALL_PREFIX="${distdir}" \
      -DCMAKE_C_COMPILER=${LLVM_MINGW_PATH}/bin/${arch}-w64-mingw32-clang \
      -DCMAKE_CXX_COMPILER=${LLVM_MINGW_PATH}/bin/${arch}-w64-mingw32-clang++ \
      -DCMAKE_CROSSCOMPILING=TRUE \
      -DCMAKE_SYSTEM_NAME=Windows \
      -DCMAKE_C_COMPILER_WORKS=TRUE \
      -DCMAKE_CXX_COMPILER_WORKS=TRUE \
      -DLIBCXX_USE_COMPILER_RT=ON \
      -DLIBCXX_INSTALL_HEADERS=ON \
      -DLIBCXX_ENABLE_EXCEPTIONS=ON \
      -DLIBCXX_ENABLE_THREADS=ON \
      -DLIBCXX_HAS_WIN32_THREAD_API=ON \
      -DLIBCXX_ENABLE_MONOTONIC_CLOCK=ON \
      -DLIBCXX_ENABLE_SHARED=$SHARED \
      -DLIBCXX_ENABLE_STATIC=$STATIC \
      -DLIBCXX_SUPPORTS_STD_EQ_CXX11_FLAG=TRUE \
      -DLIBCXX_HAVE_CXX_ATOMICS_WITHOUT_LIB=TRUE \
      -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
      -DLIBCXX_ENABLE_FILESYSTEM=OFF \
      -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=TRUE \
      -DLIBCXX_CXX_ABI=libcxxabi \
      -DLIBCXX_CXX_ABI_INCLUDE_PATHS=`pwd`/../llvm-project/libcxxabi/include \
      -DLIBCXX_CXX_ABI_LIBRARY_PATH=${distdir}/lib \
      -DLIBCXX_LIBDIR_SUFFIX="" \
      -DLIBCXX_INCLUDE_TESTS=FALSE \
      -DCMAKE_CXX_FLAGS="$LIBCXX_VISIBILITY_FLAGS" \
      -DCMAKE_SHARED_LINKER_FLAGS="-lunwind" \
      -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=FALSE \
      ../llvm-project/libcxx

  cmake --build ${libcxx_builddir} && cmake --build ${libcxx_builddir} --target install
}

cd ${curdir}
build_libunwind

cd ${curdir}
build_libcxxabi shared

cd ${curdir}
build_libcxx shared

# TODO(syoyo): static build?
