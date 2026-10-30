# Maintaining the site

How the site is put together, and how to add photos and change things. For outside contributors
sending in their own cat, see [CONTRIBUTING.md](CONTRIBUTING.md) instead.

## How it's built

The site is plain HTML, CSS and a little JavaScript, hosted on GitHub Pages. There's no framework
or site generator. crustyimg is the only build tool.

| Part | File | What it does |
|---|---|---|
| Page | [`index.html`](index.html) | All the text: hero, services, rejected shots, footer. |
| Look | [`style.css`](style.css) | Colors, fonts, layout, dark mode. |
| Photo list | [`photos.json`](photos.json) | Which photos appear, in what order, with their captions and alt text. |
| Gallery | [`site.js`](site.js) | Reads `photos.json` and builds the gallery and Guest stars sections. |
| Images | [`crustyimg.build.toml`](crustyimg.build.toml) and [`recipes/`](recipes/) | Turn each source photo into a signed AVIF plus a JPEG fallback, and make the link-preview card. |
| Deploy | [`.github/workflows/pages.yml`](.github/workflows/pages.yml) | On every push to `main`, runs `crustyimg build` and publishes `_site/`. |

Source photos in `assets/photos/` are committed as they are. Visitors only ever see the versions
the build writes into `_site/`, which isn't committed.

## Add a photo

**1. Prepare it.** A photo straight off the camera is about 3.5 MB and 4608 px wide, and carries
an empty GPS block and the camera's serial number, so the lint check would reject it. Shrink it
and strip its metadata first:

```bash
crustyimg optimize DSCN2530.JPG --profile preserve --max 1600 -o gallery-7.jpg -y
```

```bash
crustyimg meta strip gallery-7.jpg -o gallery-7.jpg -y
```

**2. Put it in `assets/photos/`.** Your own cats' photos go there. Guest photos go in
`assets/photos/guests/`.

**3. Add a line to the `"gallery"` list in `photos.json`.** Photos appear in the order of this
list:

```json
{ "file": "gallery-7.jpg", "caption": "Your Funny Caption", "alt": "What the photo shows" }
```

The gallery crops every photo to a square. If that cuts off the cat, add
`"position": "75% 50%"` to the entry to shift the crop; the first number moves it left or right.

**4. Check it.** These run the same checks CI does:

```bash
crustyimg lint 'assets/**/*'
```

```bash
./scripts/check-photos.sh
```

**5. Commit on a branch and open a pull request.** The `lint` and `photos-json` checks run on it,
and `main` requires both to pass. Once you merge, the site redeploys within a couple of minutes,
and the new photo gets the signature and its AVIF version automatically.

The gallery shows three photos per row, so adding them in threes keeps the grid even.

## Other changes

- **Change the hero photo:** replace `assets/photos/hero.jpg` with the new photo, keeping that
  name. The link-preview card is made from it, so that updates too.
- **Change any text:** edit `index.html`. The cat's name, the services and the jokes all live
  there.
- **Remove a photo:** delete the file and its line in `photos.json`. The `photos-json` check fails
  if you do only one of the two.
- **Change the signature or the card caption:** edit
  [`recipes/portfolio.toml`](recipes/portfolio.toml) or
  [`recipes/social-card.toml`](recipes/social-card.toml).

## Preview before pushing

Build the images and serve the result:

```bash
crustyimg build && ./scripts/record-modern-formats.sh && cp index.html style.css site.js _site/ && python3 -m http.server -d _site 8000
```

Then open http://localhost:8000. Opening `index.html` straight from disk doesn't work, because
the gallery loads `photos.json`. Stop the server with Ctrl-C.

## Reviewing a guest's pull request

1. If it's their first contribution, click **Approve and run** so the checks start.
2. Look at the photo yourself. The checks can't tell whether it's a cat, whether it's
   appropriate, or whether it shows a house number or a face.
3. If the checks fail, the annotations on their files tell them how to fix it. Nothing more is
   needed from you.
4. Merge when it's green. The site redeploys on its own.

## Keep pull request #1 failing

[Pull request #1](https://github.com/jysf/crustyimg-example/pull/1) adds four deliberately broken
photos so visitors can see the lint check catch them. **Never merge it.**

Whenever `photos.json` changes on `main`, for example when you add a photo, #1 gets a merge
conflict in `photos.json`. A conflicted pull request stops running its checks, so fix it by
merging `main` into its branch:

```bash
git switch demo/rejected-shots
```

```bash
git fetch origin && git merge origin/main
```

Resolve `photos.json` by keeping everything from `main` and adding the four entries for
`headshot.jpg`, `hero-loaf.jpg`, `sunbeam.jpg` and `hairball.jpg` at the end of `"gallery"`. Then
commit and push. The `lint` check should fail again with the same findings.
