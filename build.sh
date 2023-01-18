#!/bin/sh
# -*- mode: sh; sh-basic-offset: 2 -*-

set -e

if [ $# != 0 ]; then
    echo 1>&2 "usage: $0"
    exit 1
fi

try_download ()
{
  if basename "$1" | grep -q '^mediawiki-.*\.tar\..*$'; then
    url='https://releases.wikimedia.org/mediawiki'
    url="$url/$(basename "$1" \
	          | sed 's/^mediawiki-\([^.]*\.[^.]*\).*\.tar\.[^.]*$/\1/')"
    url="$url/$(basename "$1")"
  else
    return 0
  fi
  mkdir -p $(dirname "$1")
  echo 1>&2 "$url:"
  curl -o "$1" $url
}

ensure_exists ()
{
  test -r "$1" && return 0
  try_download "$1"
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

clean_builddir ()
{
  builddir="$1"
  for i in "$builddir"/.[^.]* "$builddir"/*; do
    case "$i" in
      "$builddir"/.git*) ;;
      "$builddir"/LocalSettings*.php) ;;
      *) rm -rf "$i"
    esac
  done
}

topdir=$(cd $(dirname "$0") && pwd)
srcdir="$topdir/source"
builddir="$topdir/build"
configdir="$HOME/.hivesite"

# Create the deployment directory to build into.
if [ ! -d "$builddir" ]; then
  read -p "Whats the git remote for $builddir? " remote
  git clone "$remote" "$builddir"
fi

# Extract the main tarball.
srctar="$srcdir/mediawiki-1.35.2.tar.gz"
ensure_exists "$srctar"
clean_builddir "$builddir"
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

# Drop in our configuration.
rsync -a "$configdir"/ "$builddir"

# Remove any .gitignore files that got dropped in.
find "$extdir" "$skindir" -name .gitignore -print0 | xargs -0 rm -f
