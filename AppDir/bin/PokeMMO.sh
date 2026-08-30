#!/bin/sh

# Change directory to the directly containing PokeMMO.sh
cd "$(dirname "$0")" || exit 1

OS=$(uname -s)
case "$OS" in
    Linux)
        OS_DIR="linux"
        ;;
    *)
        echo "Warning: Unsupported Operating System detected: $OS"
        exit 1
        ;;
esac

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        ARCH_DIR="x64"
        ;;
    arm64|aarch64)
        ARCH_DIR="arm64"
        ;;
    *)
        echo "Warning: Unsupported Architecture detected: $ARCH"
        exit 1
        ;;
esac

BINARY="bin/${OS_DIR}/${ARCH_DIR}/PokeMMO"
if [ ! -f "$BINARY" ]; then
    echo "Error: PokeMMO not found at $BINARY"
    exit 1
fi

# Check if file is executable, if not try to fix it
if [ ! -x "$BINARY" ]; then
    echo "Warning: PokeMMO not executable. Attempting to set permissions..."
    if ! chmod +x "$BINARY"; then
        echo "Error: Failed to set executable permissions on $BINARY"
        echo "Please run manually: chmod +x $BINARY"
        exit 1
    fi
fi

exec "$APPDIR"/sharun "$BINARY"
