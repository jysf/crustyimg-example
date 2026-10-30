#!/usr/bin/env bash
# Checks that photos.json and the photo folders agree: every listed photo
# exists, every photo is listed, file types are ones browsers can show, and
# each guest entry credits a valid GitHub username.
set -euo pipefail

fail=0
err() { echo "::error file=$1::$2"; fail=1; }

jq -e . photos.json > /dev/null || { echo "::error file=photos.json::photos.json is not valid JSON"; exit 1; }

check_list() {
  local key="$1" dir="$2"
  while IFS= read -r f; do
    [ -f "$dir/$f" ] || err photos.json "$key lists '$f', but $dir/$f does not exist"
  done < <(jq -r ".${key}[].file" photos.json)

  while IFS= read -r path; do
    f="$(basename "$path")"
    case "$f" in
      .gitkeep) continue ;;
      hero.jpg) [ "$key" = gallery ] && continue ;;  # the hero is set in index.html
      *.jpg|*.jpeg|*.png|*.webp) ;;
      *) err "$path" "use a .jpg, .jpeg, .png or .webp file (browsers can't show every format)"; continue ;;
    esac
    jq -e --arg f "$f" ".${key} | any(.file == \$f)" photos.json > /dev/null \
      || err "$path" "this photo isn't listed under \"$key\" in photos.json, so it won't appear on the site"
  done < <(find "$dir" -maxdepth 1 -type f)
}

check_list gallery assets/photos
check_list guests assets/photos/guests

while IFS= read -r bad; do
  err photos.json "guest entry '$bad' needs \"credit\" set to your GitHub username"
done < <(jq -r '.guests[] | select((.credit // "") | test("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,38})$") | not) | .file' photos.json)

while IFS= read -r bad; do
  err photos.json "guest entry '$bad' needs a caption and alt text"
done < <(jq -r '.guests[] | select((.caption // "") == "" or (.alt // "") == "") | .file' photos.json)

if [ "$fail" = 0 ]; then echo "photos.json matches the photo folders."; fi
exit "$fail"
