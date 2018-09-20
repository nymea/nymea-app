#!/bin/bash

function exportImage() {
  size=$1
  path=icons/hicolor/${size}x${size}/apps/
  echo Exporting AppIcon with size $size to ${path}
  mkdir -p ${path}
  inkscape nymea-app.svg -e ${path}/nymea-app.png -C -w ${size} -h ${size}
}

SIZES=(
  "16"
  "22"
  "24"
  "32"
  "48"
  "64"
  "256"
)

for size in "${SIZES[@]}" ; do
  pixels="${size}"
  exportImage $pixels
done
