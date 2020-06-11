# llvm-project build scripts

![CI](https://github.com/syoyo/llvm-project-mingw-build/workflows/CI/badge.svg)


Releases https://github.com/syoyo/llvm-project-mingw-build/releases uses GitHub Actions 

https://github.com/syoyo/llvm-project-mingw-build/actions

## Requirement

* 20GB+ of disk size.
  * Using highspeed disk(e.g. SSD or NVMe) preferred.
* ninja-build
* cmake
* C/C++ compiler
* llvm-mingw cross compiler
  * https://github.com/mstorsjo/llvm-mingw : 20200325(LLVM 10.0) or newer

## Setup

Clone llvm-project repo.

```
$ ./clone-repo.sh
```

## Ubuntu 18.04(x86-64) build

### Requirements

* llvm-mingw cross compiler toolchain(`llvm-mingw-20200325-ubuntu-18.04.tar.xz`)

Set path to llvm-mingw in environment variable
See github actions workflow file for details.

![workflow](https://github.com/syoyo/llvm-project-mingw-build/blob/master/.github/workflows/build.yml)

### Build native llvm/clang tools

First we need to build native tools(e.g. clang-tblgen) on host.

```
$ ./build-native-tools.sh
```

### Build libclang, libllvm for Windows target.

Edit path to llvm-mignw in `build-llvm-mingw-cross.sh`, then

```
$ ./build-llvm-mingw-cross.sh
```

### Build libcxx, libcxxabi, compiler-rt

Edit path to llvm-mignw in `build-libcxx-mingw-cross.sh`, then

```
$ ./build-libcxx-mingw-cross.sh
```


### Build compiler-rt

You can build compiler-rt solely(no dependency with libclang, libllvm, etc).
Only you need is llvm-mingw clang compiler.

Edit path to llvm-mignw in `build-compiler-rt-mingw-cross.sh`, then

```
$ ./build-compiler-rt-mingw-cross.sh
```


## TODO

* [ ] Create artiface and release using git tag.

