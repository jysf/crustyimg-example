# Submit your cat

Guest stars are welcome. Send a photo of your cat as a pull request, and once it's reviewed and
merged it appears in the [Guest stars](https://mrwhiskers.jysf.org/#guests) section
with credit to you.

This repo is a live demo of [crustyimg](https://github.com/jysf/crustyimg), an image linter, so
your photo goes through the same automated checks as every other photo on the site.

## Steps

1. **Fork** this repo.
2. **Add your photo** to `assets/photos/guests/`, named `<your-github-username>-<cat-name>.jpg`,
   for example `octocat-mittens.jpg`. JPEG, PNG and WebP all work.
3. **Add an entry** to the `"guests"` list in [`photos.json`](photos.json):

   ```json
   {
     "file": "octocat-mittens.jpg",
     "cat": "Mittens",
     "caption": "Unimpressed by Mondays",
     "alt": "A grey cat glaring from the top of a bookshelf",
     "credit": "octocat"
   }
   ```

   `credit` is your GitHub username. `alt` describes the photo for people using screen readers.
4. **Open a pull request** and tick the boxes in the template.

## If a check fails

That's the fun part, and it's not a rejection. The checks write a note right on your file saying
what's wrong and how to fix it. The common ones (each command rewrites the file in place):

| What the check says | What to do |
|---|---|
| `privacy/gps-metadata-leak` | Your phone saved where the photo was taken. Remove it with `crustyimg meta clean --gps <file> -o <file> -y`, or `exiftool -gps:all= <file>`. |
| `size/oversized-bytes` | The file is over 1 MB. Shrink it with `crustyimg optimize <file> --profile preserve --max 1600 -o <file> -y`. |
| `orient/orientation-not-baked` | The photo is stored sideways. Fix it with `crustyimg auto-orient <file> -o <file> -y`. |
| `photos.json` errors | The filename in `photos.json` doesn't match the file, or a field is missing. |

Install crustyimg with `brew install jysf/tap/crustyimg` or from the
[releases page](https://github.com/jysf/crustyimg/releases). Then you can run the same check on
your machine before you push:

```sh
crustyimg lint 'assets/**/*'
```

The first time you open a pull request here, the checks wait until a maintainer approves them.
That's a GitHub safety setting for first-time contributors, not a problem with your photo.

## Ground rules

- Cats only, and your own photo of your own cat (or one you have permission to share).
- No people, house numbers, street signs or anything else that shows where you live.
- Photos are shown under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), credited to
  your GitHub username. You keep the copyright.
- A maintainer reviews every photo before merging, and may decline one without giving a reason.
