#!/bin/bash
if [ $# -lt 2 ]; then
  echo "usage: $0 file-to-add target" 1>&2
  exit 1
fi
set -e

file_to_add="$1"
target="$2"

if [ ! -e "${file_to_add}" ]; then
  exit 0
fi

if [ -d "${target}" ]; then
  target="${target}/binpkgbot"
fi

echo "modify-etc-portage: modifying ${target}"

temp="$(mktemp)"
if [ -f "${target}" ]; then
  cat "${target}" > "${temp}"
  echo >> "${temp}"
elif [ -d "${target}" ]; then
fi
cat "${file_to_add}" >> "${temp}"

mv "${temp}" "${target}"
