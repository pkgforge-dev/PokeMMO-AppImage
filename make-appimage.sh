#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q pokemmo | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/pixmaps/pokemmo-launcher.png
export DESKTOP=/usr/share/applications/pokemmo.desktop
export STARTUPWMCLASS=com.pokemmo.PokeMMO
export DEPLOY_GTK=1
export GTK_DIR=gtk-3.0
export DEPLOY_OPENGL=1
export DEPLOY_PULSE=1

# Deploy dependencies
quick-sharun /usr/bin/pokemmo-launcher \
    /usr/lib/jvm/java*/bin \
    /usr/lib/jvm/java*/conf \
    /usr/lib/jvm/java*/legal \
    /usr/lib/jvm/java*/lib \
    /usr/bin/openssl

# Additional changes can be done in between here
echo 'ANYLINUX_DO_NOT_LOAD_LIBS=libpipewire-0.3.so*:${ANYLINUX_DO_NOT_LOAD_LIBS}' >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --test ./dist/*.AppImage
