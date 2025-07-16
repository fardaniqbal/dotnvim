#!/usr/bin/env bash
# This script downloads Eclipse's Java language server (JDTLS) from the
# official URL and installs it to the local machine.  Run with --help for
# more information.
self="$(basename "$0")"
here="$(cd "$(dirname "$0")"; pwd)"
cd "$here"

if [ -n "$USERPROFILE" ]; then
  install_prefix="$(printf '%s' "$USERPROFILE/local/jdtls" | sed -E 's,\\,/,g')"
else
  install_prefix="$HOME/local/jdtls"
fi

# Get comand-line args.
while [ $# -gt 0 ]; do
  arg="$2"
  shift_arg='shift'
  if [ $(expr "$1" : '^[^=]\+=.*$') -gt 0 ]; then
    arg="${1#*=}"
    shift_arg=''
  fi
  case "$1" in
    --) shift; break
      ;;
    --clean)
      rm -f "$here/"jdt-language-server-*.tar.gz
      exit 0
      ;;
    --prefix|--prefix=*)
      [ -z "$arg" ] && err "--prefix missing argument"
      install_prefix="$arg"
      $shift_arg
      ;;
    --help)
      printf 'Usage: %s [OPTION...]\n' "$self" >&2
      printf 'Download and install Eclipse JDTLS.\n' >&2
      printf 'OPTIONs are as follows:\n\n' >&2
      printf -- '--clean\n' >&2
      printf '    Remove temporary files.\n' >&2
      printf -- '--prefix=INSTALL-DIR\n' >&2
      printf '    Install to directory INSTALL-DIR (default %s).\n' "$install_prefix" >&2
      printf -- '--help\n' >&2
      printf '    Print this message and exit.\n' >&2
      exit 2
      ;;
    -*|--*)
      printf '%s: unknown option %s.\n' "$self" "$1" >&2
      printf 'Run with --help for usage info.\n' >&2
      exit 2
      ;;
    *) break
      ;;
  esac
  shift
done

if [ $# -ne 0 ]; then
  printf '%s: bad args; run with --help for usage info.\n' "$self" >&2
  exit 2
fi

# Change JDTLS_VERSION to your preferred version.  Official versions here:
# https://download.eclipse.org/jdtls/milestones
JDTLS_VERSION="1.48.0"
JDTLS_DOWNLOAD_BASE_URL="https://download.eclipse.org/jdtls/milestones"

have_wget=$(which wget >/dev/null 2>&1 && echo true || echo false)
have_curl=$(which curl >/dev/null 2>&1 && echo true || echo false)
if (! $have_wget) && (! $have_curl); then
  printf '%s: need wget or curl to download JDTLS; found neither.\n' "$self" >&2
  printf 'Please install wget and/or curl and try again.\n' >&2
  exit 1
fi

# Define function download() based on whether we have a working version of
# wget or curl, and use it to determine jdtls archive file name.
wget_works=false
curl_works=false
jdtls_archive=""
if $have_wget; then
  download() { wget --no-check-certificate -O - "$*"; }
  jdtls_archive="$(download "$JDTLS_DOWNLOAD_BASE_URL/$JDTLS_VERSION/latest.txt")" &&
  wget_works=true
fi
if (! $wget_works) && $have_curl; then
  download() { curl -k --proxy-insecure "$*"; }
  jdtls_archive="$(download "$JDTLS_DOWNLOAD_BASE_URL/$JDTLS_VERSION/latest.txt")" &&
  curl_works=true
fi

# Nothing we can do if we don't have a working wget or curl.
if (! $wget_works) && (! $curl_works); then
  printf '%s: you have wget and/or curl, but neither work.\n' "$self" >&2
  printf 'Check your proxy/cert configuration for wget/curl and your\n' >&2
  printf 'firewall configuration, and make sure they allow access to\n' >&2
  printf '%s.\n' "$JDTLS_DOWNLOAD_BASE_URL" >&2
  exit 1
fi

printf '%s: latest JDTLS %s archive:\n\t%s\n' "$self" "$JDTLS_VERSION" "$jdtls_archive"
printf '%s: downloading:\n\t%s\n' "$self" "$JDTLS_DOWNLOAD_BASE_URL/$JDTLS_VERSION/$jdtls_archive"
download "$JDTLS_DOWNLOAD_BASE_URL/$JDTLS_VERSION/$jdtls_archive" > "$here/$jdtls_archive"
if [ $? -ne 0 ]; then
  printf '%s: error: failed to download JDTLS archive.\n' "$self" >&2
  exit 1
fi

# Extract the JDTLS tar.gz archive to the install_prefix directory.
(mkdir -p "$install_prefix" &&
 cd "$install_prefix" &&
 tar xvzf "$here/$jdtls_archive")
if [ $? -ne 0 ]; then
  printf "$self: failed to extract %s to %s\n" "$jdtls_archive" "$install_prefix" >&2
  exit 1
fi

# Clean up.
rm -f "$here/$jdtls_archive"
printf '\n%s: JDTLS installed to %s.\n' "$self" "$install_prefix"
printf 'Make sure %s/bin is in your path.\n' "$install_prefix"
