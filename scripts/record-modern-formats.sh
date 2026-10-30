#!/usr/bin/env bash
# Run after `crustyimg build`. For each photo in photos.json, finds the
# modern-format file the build wrote next to the JPEG (crustyimg picks the
# format per photo, usually AVIF) and records its name, so the page can
# offer it with the JPEG as a fallback. Writes _site/photos.json.
set -euo pipefail

modern_for() {
  local dir="$1" file="$2" stem
  stem="${file%.*}"
  for ext in avif webp png; do
    if [ -f "_site/assets/photos/${dir}${stem}.${ext}" ]; then
      echo "${stem}.${ext}"
      return
    fi
  done
}

json="$(cat photos.json)"
for key in hero gallery guests; do
  dir=""; [ "$key" = guests ] && dir="guests/"
  count="$(jq --arg k "$key" 'if .[$k] | type == "array" then .[$k] | length elif .[$k] then 1 else 0 end' <<<"$json")"
  for ((i = 0; i < count; i++)); do
    path=".${key}"; [ "$key" != hero ] && path=".${key}[$i]"
    file="$(jq -r "${path}.file" <<<"$json")"
    modern="$(modern_for "$dir" "$file")"
    if [ -n "$modern" ]; then
      json="$(jq --arg m "$modern" "${path}.modern = \$m" <<<"$json")"
    fi
  done
done
printf '%s\n' "$json" > _site/photos.json
