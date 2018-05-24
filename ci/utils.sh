#!/bin/bash

# Various utility functions used through CI.

# Finds Cargo's `OUT_DIR` directory from the most recent build.
#
# This requires one parameter corresponding to the target directory
# to search for the build output.
cargo_out_dir() {
    # This works by finding the most recent stamp file, which is produced by
    # every ripgrep build.
    target_dir="$1"
    find "$target_dir" -name ripgrep-stamp -print0 \
      | xargs -0 ls -t \
      | head -n1 \
      | xargs dirname
}

make_dist() {
    local _out_dir="$(cargo_out_dir target/)"
    mkdir -p dist
    cp -t dist "$_out_dir/rg.1" "$_out_dir/rg.bash"
    cp -t dist target/release/rg
    cp install.mk dist/Makefile
    for p in *.patch
    do
        patch --quiet -p1 < $p || exit
    done
}

host() {
    case "$TRAVIS_OS_NAME" in
        linux)
            echo x86_64-unknown-linux-gnu
            ;;
        osx)
            echo x86_64-apple-darwin
            ;;
    esac
}

architecture() {
    case "$TARGET" in
        x86_64-*)
            echo amd64
            ;;
        i686-*|i586-*|i386-*)
            echo i386
            ;;
        arm*-unknown-linux-gnueabihf)
            echo armhf
            ;;
        *)
            die "architecture: unexpected target $TARGET"
            ;;
    esac
}

gcc_prefix() {
    case "$(architecture)" in
        armhf)
            echo arm-linux-gnueabihf-
            ;;
        *)
            return
            ;;
    esac
}

is_musl() {
    case "$TARGET" in
        *-musl) return 0 ;;
        *)      return 1 ;;
    esac
}

is_x86() {
    case "$(architecture)" in
      amd64|i386) return 0 ;;
      *)          return 1 ;;
    esac
}

is_x86_64() {
    case "$(architecture)" in
      amd64) return 0 ;;
      *)          return 1 ;;
    esac
}

is_arm() {
    case "$(architecture)" in
        armhf) return 0 ;;
        *)     return 1 ;;
    esac
}

is_linux() {
    case "$TRAVIS_OS_NAME" in
        linux) return 0 ;;
        *)     return 1 ;;
    esac
}

is_osx() {
    case "$TRAVIS_OS_NAME" in
        osx) return 0 ;;
        *)   return 1 ;;
    esac
}

builder() {
    if is_musl && is_x86_64; then
        # cargo install cross
        # To work around https://github.com/rust-embedded/cross/issues/357
        cargo install --git https://github.com/rust-embedded/cross --force
        echo "cross"
    else
        echo "cargo"
    fi
}
