#!/bin/sh

CONFIGURE_FLAGS="--enable-static --with-pic=yes --disable-shared"

ARCHS="arm64e arm64 x86_64 armv7 i386"

# directories
SOURCE="fdk-aac-2.0.1"
FAT="fdk-aac-ios"

SCRATCH="scratch"
# must be an absolute path
THIN=`pwd`/"thin"

COMPILE="y"
LIPO="y"

if [ "$*" ]
then
    if [ "$*" = "lipo" ]
    then
        # skip compile
        COMPILE=
    else
        ARCHS="$*"
        if [ $# -eq 1 ]
        then
            # skip lipo
            LIPO=
        fi
    fi
fi

if [ "$COMPILE" ]
then
    CWD=`pwd`
    for ARCH in $ARCHS
    do
        echo "building $ARCH..."
        mkdir -p "$SCRATCH/$ARCH"
        cd "$SCRATCH/$ARCH"

        CFLAGS="-arch $ARCH -Os"

        if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
        then
            PLATFORM="iPhoneSimulator"
            CPU=
            if [ "$ARCH" = "x86_64" ]
            then
                CFLAGS="$CFLAGS -mios-simulator-version-min=7.0"
            HOST="--host=x86_64-apple-darwin"
            else
                CFLAGS="$CFLAGS -mios-simulator-version-min=7.0"
            HOST="--host=i386-apple-darwin"
            fi
        else
            PLATFORM="iPhoneOS"
            if [ $ARCH = arm64 ]
            then
                HOST="--host=aarch64-apple-darwin"
                    else
                HOST="--host=arm-apple-darwin"
                fi
            CFLAGS="$CFLAGS -fembed-bitcode"
        fi

        XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
        CC="xcrun -sdk $XCRUN_SDK clang -Wno-error=unused-command-line-argument-hard-error-in-future -Os"
        AS="$CWD/$SOURCE/extras/gas-preprocessor.pl $CC"
        CXXFLAGS="$CFLAGS"
        LDFLAGS="$CFLAGS"

        $CWD/$SOURCE/configure \
            $CONFIGURE_FLAGS \
            $HOST \
            $CPU \
            CC="$CC" \
            CXX="$CC" \
            CPP="$CC -E" \
                    AS="$AS" \
            CFLAGS="$CFLAGS" \
            LDFLAGS="$LDFLAGS" \
            CPPFLAGS="$CFLAGS" \
            --prefix="$THIN/$ARCH"
            
            
#            **********************************
#            /Users/fang/Downloads/fdk-aac-master/configure
#            --enable-static --with-pic=yes --disable-shared
#            --host=aarch64-apple-darwin
#
#            CC=xcrun -sdk iphoneos clang -Wno-error=unused-command-line-argument-hard-error-in-future
#            CXX=xcrun -sdk iphoneos clang -Wno-error=unused-command-line-argument-hard-error-in-future
#            CPP=xcrun -sdk iphoneos clang -Wno-error=unused-command-line-argument-hard-error-in-future -E
#            AS=/Users/fang/Downloads/fdk-aac-master/extras/gas-preprocessor.pl xcrun -sdk iphoneos clang -Wno-error=unused-command-line-argument-hard-error-in-future
#            CFLAGS=-arch arm64 -fembed-bitcode
#            LDFLAGS=-arch arm64 -fembed-bitcode
#            CPPFLAGS=-arch arm64 -fembed-bitcode
#            --prefix=/Users/fang/Downloads/thin/arm64
#            **********************************

            echo '**********************************'
            echo "$CWD/$SOURCE/configure"
            echo "CONFIGURE_FLAGS=$CONFIGURE_FLAGS"
            echo "HOST=$HOST"
            echo "CPU=$CPU"
            echo "CC=$CC"
            echo "CXX=$CC"
            echo "CPP=$CC -E"
            echo "AS=$AS"
            echo "CFLAGS=$CFLAGS"
            echo "LDFLAGS=$LDFLAGS"
            echo "CPPFLAGS=$CFLAGS"
            echo "--prefix=$THIN/$ARCH"
            echo '**********************************'

        make -j3 install
        cd $CWD
    done
fi

if [ "$LIPO" ]
then
    echo "building fat binaries..."
    mkdir -p $FAT/lib
    set - $ARCHS
    CWD=`pwd`
    cd $THIN/$1/lib
    for LIB in *.a
    do
        cd $CWD
        lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB
    done

    cd $CWD
    cp -rf $THIN/$1/include $FAT
fi
