#!/bin/bash

# Update the glibc and libstdc++ of VSCode server
# Read README.md for detail

set -exuo pipefail

script_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Disable VSCode glibc/libstdc++ version checking
if [[ ! -e "/tmp/vscode-skip-server-requirements-check" ]]; then
  touch "/tmp/vscode-skip-server-requirements-check"
fi

files="$@"

if [[ -z "${file:-}" ]]; then
  files=($HOME/.vscode-server/bin/*/node )
fi

echo "${files[@]}"
patchelf="$script_dir/patchelf-0.9/bin/patchelf"
interpreter="$script_dir/glibc-2.30/lib/ld-linux-x86-64.so.2"
lib_dir="$script_dir/glibc-2.30/lib:$script_dir/gcc-10.3.0/lib64"

for exe in "${files[@]}"; do
  ${patchelf} --set-interpreter ${interpreter} "$exe"
  ${patchelf} --set-rpath "${lib_dir}" "$exe" --force-rpath
done

echo "Succeeded to update glibc and libstdc++ of vscode server"
