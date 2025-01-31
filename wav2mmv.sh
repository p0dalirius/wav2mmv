#!/usr/bin/env bash

log()  { echo -e "\x1b[1m[\x1b[93mLOG\x1b[0m\x1b[1m]\x1b[0m ${@}";  }
info() { echo -e "\x1b[1m[\x1b[92mINFO\x1b[0m\x1b[1m]\x1b[0m ${@}"; }
warn() { echo -e "\x1b[1m[\x1b[91mWARN\x1b[0m\x1b[1m]\x1b[0m ${@}"; }

echo '                         ___                                            '
echo '    _      ______ __   _|__ \ ____ ___  ____ ___ _   __                 '
echo '   | | /| / / __ `/ | / /_/ // __ `__ \/ __ `__ \ | / /                 '
echo '   | |/ |/ / /_/ /| |/ / __// / / / / / / / / / / |/ /  v1.1            '
echo '   |__/|__/\__,_/ |___/____/_/ /_/ /_/_/ /_/ /_/|___/   by Remi GASCOU (Podalirius) '
echo ''

if [[ $# -eq 0 ]]; then
    warn "No inputfile given.";
    exit 1;
fi

if [[ ! -f $1 ]]; then
    warn "Cannot read or find this file.";
    exit 1;
fi

file_header=$(mktemp)
file_content=$(mktemp)
dir=$(dirname "${1}")
filename=$(basename "${1}")

# MMV Header
printf "\x55\xaa\x00\x00" > "${file_header}"

# ffmpeg
#   -i infile
#   -ar rate       set audio sampling rate (in Hz)
#   -ac channels   set number of audio channels
#   -f fmt         force format
#   -c codec       codec name
#   -y             overwrite output files

log "ffmpeg -v 0 -i ${1} -ac 1 -ar 11025 -f s16le -c:a pcm_s16le -y ${file_content}"

ffmpeg \
    -v 0 \
    -i "${1}" \
    -ac 1 \
    -ar 11025 \
    -f s16le \
    -c:a pcm_s16le \
    -y \
    "${file_content}" \


# Creating final file
cat "${file_header}" "${file_content}" > "${dir}/${filename%.*}.mmv"

info "MMV file saved to ${dir}/${filename%.*}.mmv !"

# Cleanup
if [[ -f "${file_header}" ]];  then rm "${file_header}";  fi
if [[ -f "${file_content}" ]]; then rm "${file_content}"; fi
