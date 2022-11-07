#!/bin/sh
# -*- mode: sh; sh-basic-offset: 2 -*-

set -e

if [ $# != 1 ]; then
    echo 1>&2 "usage: $0 BUILDDIR"
    exit 1
fi
builddir="$1"

ensure_exists ()
{
  test -r "$1" && return 0
  echo 1>&2 "error: $1: file not found"
  exit 1
}

extract_into ()
{
  dstdir="$1"
  while true; do
    shift
    if [ $# -le 0 ]; then
      return 0
    fi
    tar -xf "$srcdir/$1.tar.gz" -C "$dstdir"
    subdir=$(echo $1 | sed 's/-REL.*$//')
    ensure_exists "$dstdir/$subdir/version"
  done
}

topdir=$(cd $(dirname "$0") && pwd)
srcdir="$topdir/source"

# Extract the main tarball.
srctar="$srcdir/mediawiki-1.35.2.tar.gz"
ensure_exists "$srctar"
git clean -fdxq "$builddir"
tar -xf "$srctar" -C "$builddir" --strip-components=1
ensure_exists "$builddir/README.md"

# Extract the extensions we use.
extdir="$builddir/extensions"
extract_into "$extdir" \
    MobileFrontend-REL1_35-1421405 \
    Scribunto-REL1_35-d21b655 \
    TemplateStyles-REL1_35-7a40a6a

ensure_exists "$extdir/TemplateStyles/vendor/autoload.php"

# Extract the skins we use.
skindir="$builddir/skins"
extract_into "$skindir" \
    MinervaNeue-REL1_35-d82e32c

# Remove any .gitignore files that got dropped in.
find "$builddir" -name .gitignore -print0 | xargs -0 rm -f
