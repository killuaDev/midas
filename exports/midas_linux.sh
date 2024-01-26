#!/bin/sh
echo -ne '\033c\033]0;Midas\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/midas_linux.x86_64" "$@"
