#!/bin/sh

# This wrapper lives in $APPDIR/bin and shadows the game's own PokeMMO.sh via
# PATH, so resolve the real PokeMMO installation directory here.
# Mirrors pokemmo-launcher: a custom dir set via `-H` is stored in
# $XDG_CONFIG_HOME/pokemmo/pokemmodir, otherwise the default of
# $XDG_DATA_HOME/pokemmo (or $HOME/.local/share/pokemmo) is used.
getPokemmoDir() {
    PKMOCONFIGDIR="${XDG_CONFIG_HOME:-$HOME/.config}/pokemmo"
    if [ -f "$PKMOCONFIGDIR/pokemmodir" ]; then
        head -n1 "$PKMOCONFIGDIR/pokemmodir"
    elif [ -n "$XDG_DATA_HOME" ] && [ -d "$XDG_DATA_HOME" ]; then
        echo "$XDG_DATA_HOME/pokemmo"
    else
        echo "$HOME/.local/share/pokemmo"
    fi
}

POKEMMO=$(getPokemmoDir)
if [ ! -d "$POKEMMO" ]; then
    echo "Error: PokeMMO installation not found at $POKEMMO"
    exit 1
fi

cd "$POKEMMO" || exit 1
POKEMMO=$(pwd)

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

# When running inside the AppImage, $APPDIR is exported by AppRun.sh.
# Fall back to deriving it from this script's own location otherwise.
if [ -z "$APPDIR" ]; then
    APPDIR=$(cd "$(dirname "$0")/.." && pwd)
fi

exec "$APPDIR"/sharun "$POKEMMO/$BINARY"
