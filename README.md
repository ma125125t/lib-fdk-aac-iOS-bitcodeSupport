# build-fdk-aac-for-iOS-with-bitcode

Shell script to build fdk-aac for use in iOS apps.

## directly use

unzip lib-fdk-aac-2.0.1,this lib contains architecture : i386 armv7 x86_64 arm64 arm64e.and it support bitcode already

If you want to build yourself,please continue.

## Preparation

```
brew install automake libtool
```

## Compile

Unzip fdk-aac-master.zip,here we use master branch.

```
cd fdk-aac-2.0.1
./autogen
cd ..
./build-fdk-aac
```

* Build all:

```
build-fdk-aac.sh
```

* Build for some architectures:

```
build-fdk-aac.sh armv7s x86_64
```

* Build universal library from separately built architectures:

```
build-fdk-aac.sh lipo
```

*If you don't need bitcode support,remove `-fembed-bitcode` in build-fdk-aac.sh


## Verify bitcode

`lipo -thin arm64 libfdk-aac.a  -output libfdk-aac-arm64.a `

`otool -l libfdk-aac-arm64.a | grep __LLVM | wc -l`

