#!/bin/bash

clear

MODE="debug"
PLATFORM="$(uname)"
SRC_DIR="src"
BUILD_DIR="build"
TARGET_DIR=""

mkdir -p build

for arg in "$@"; do
    case $arg in 
        --mode=*)
            MODE="${arg#*=}"
            ;;
        --platform=*)
            PLATFORM="${arg#*=}"
            ;;
        --copy-to=*) TARGET_DIR="${arg#*=}"
            ;;
        *)
            echo "Unknown option: $arg"
            ;;
    esac
done

MODE="${MODE,,}"
PLATFORM="${PLATFORM,,}"

LIBS=""
WARNINGS=""
FLAGS=""

case $MODE in
    debug|release) ;;
    *)
        echo "Invalid mode: $MODE"
        exit 1
        ;;
esac

case $PLATFORM in
    linux|windows) ;;
    *)
        echo "Invalid platform: $PLATFORM"
        exit 1
        ;;
esac

echo "Building for platform: $PLATFORM"
echo "Building in $MODE mode"

OUTPUT_NAME="game_${PLATFORM}_${MODE}"

if [ "$PLATFORM" = "windows" ]; then
        LIBS="-luser32 -lgdi32"
        WARNINGS=""
    if [ "$MODE" = "release" ]; then
        FLAGS="-mwindows"
    else
        FLAGS=""
    fi

    echo "Building with libraries: $LIBS"
    echo "Building with flags: $FLAGS"

    OUTPUT_PATH="$BUILD_DIR/$OUTPUT_NAME.exe"

    # Cross compile for windows
    x86_64-w64-mingw32-g++ "$SRC_DIR/main.cpp" -o$OUTPUT_PATH $LIBS $WARNINGS $FLAGS

    # Because I am using windows VM to test out the built binary
    if [ -n "$TARGET_DIR" ]; then
        mkdir -p "$TARGET_DIR"
        cp "$OUTPUT_PATH" "$TARGET_DIR/"
        echo "Copied executable to: $TARGET_DIR"
    fi
elif [ "$PLATFORM" = "linux" ]; then

    echo "Building with libraries: $LIBS"
    echo "Building with flags: $FLAGS"

    OUTPUT_PATH="$BUILD_DIR/$OUTPUT_NAME.out"

    clang "$SRC_DIR/main.cpp" -o$OUTPUT_PATH $WARNINGS $FLAGS $LIBS
fi

