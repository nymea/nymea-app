#!/bin/bash

function exportImage() {
  mkdir AppIcon.iconset
  size=$1
  scaleFactor=$2
  echo Exporting AppIcon with size $size and scale factor $scaleFactor
  if [ ${scaleFactor} -ne 1 ]; then
    finalSize=$((size * scaleFactor))
    echo final size is ${finalSize}
    inkscape AppIcon.svg -e AppIcon.iconset/icon_${size}x${size}@${scaleFactor}x.png -C -w $finalSize -h $finalSize
  else
    inkscape AppIcon.svg -e AppIcon.iconset/icon_${size}x${size}.png -C -w ${size} -h ${size}
  fi
}

SIZES=(
  "16:1"
  "16:2"
  "32:1"
  "32:2"
  "128:1"
  "128:2"
  "256:1"
  "256:2"
  "512:1"
  "512:2"
)

for size in "${SIZES[@]}" ; do
  pixels="${size%%:*}"
  scale="${size##*:}"
  exportImage $pixels $scale
done
