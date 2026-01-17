#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="${1:-}"
DEST_DIR="${2:-/storage/emulated/0/Download/pal}"

if [[ -z "${SRC_DIR}" ]]; then
  echo "Usage: $0 <path-to-pal-data> [device-dest-dir]"
  echo "Example: $0 /path/to/pal /storage/emulated/0/Download/pal"
  exit 1
fi

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "Source directory not found: ${SRC_DIR}"
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found in PATH."
  exit 1
fi

if ! adb get-state >/dev/null 2>&1; then
  echo "No device detected by adb. Check USB debugging and run: adb devices"
  exit 1
fi

required_files=(
  abc.mkf ball.mkf data.mkf f.mkf
  fbp.mkf fire.mkf gop.mkf map.mkf
  mgo.mkf pat.mkf rgm.mkf rng.mkf
  sss.mkf
)

missing=0

adb shell "mkdir -p '${DEST_DIR}'"

for f in "${required_files[@]}"; do
  if [[ -f "${SRC_DIR}/${f}" ]]; then
    adb push "${SRC_DIR}/${f}" "${DEST_DIR}/"
  else
    echo "Missing required file: ${f}"
    missing=1
  fi
done

push_any() {
  local label="$1"
  shift
  local found=0
  local f
  for f in "$@"; do
    if [[ -f "${SRC_DIR}/${f}" ]]; then
      adb push "${SRC_DIR}/${f}" "${DEST_DIR}/"
      found=1
    fi
  done
  if [[ "${found}" -eq 0 ]]; then
    echo "Missing ${label} file(s): $*"
    missing=1
  fi
}

push_any "message" m.msg word.dat
push_any "sound" voc.mkf sounds.mkf
push_any "music" midi.mkf mus.mkf

if [[ "${missing}" -ne 0 ]]; then
  echo "Done with warnings. Some required files are missing."
  exit 1
fi

echo "All files pushed to ${DEST_DIR}."
