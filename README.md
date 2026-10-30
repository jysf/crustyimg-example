# crustyimg-example — Mr. Whiskers' portfolio

A small, real website that uses the [crustyimg](https://github.com/jysf/crustyimg) GitHub Actions
the way you would in your own repo. It's the portfolio of Mr. Whiskers, a cat who is available
for naps, with help from an associate.

**Live site:** https://jysf.github.io/crustyimg-example/

**See the linter catch problems:** [pull request #1](https://github.com/jysf/crustyimg-example/pull/1)
tries to add four new photos, and each one has a problem crustyimg flags right on the file:

| Photo | Finding | Why it matters |
|---|---|---|
| `headshot.jpg` | **error** `privacy/gps-metadata-leak` | The photo carries GPS coordinates, which would publish where it was taken. |
| `hero-loaf.jpg` | **error** `size/oversized-bytes`, **warn** `dims/oversized-dimensions` | A 4 MB, 4608 px camera original, far over this site's 1 MB budget and 1600 px width (`.crustyimg-lint.toml`). |
| `sunbeam.jpg` | **warn** `orient/orientation-not-baked` | Stored sideways and rotated only by a metadata flag, which some viewers ignore. |
| `hairball.jpg` | **error** `size/truncated-or-corrupt` | Not a readable image at all. |

That PR stays open on purpose, so the failing check and the annotations are always there to look
at.

## What's wired up

| Workflow | What it does | Action used |
|---|---|---|
| [`lint.yml`](.github/workflows/lint.yml) | Lints `assets/**/*` on every PR and push. Findings become annotations on the changed files, and errors fail the check. A second job checks that [`photos.json`](photos.json) and the photo folders agree. | [`jysf/crustyimg-action@v1`](https://github.com/marketplace/actions/crustyimg) |
| [`code-scanning.yml`](.github/workflows/code-scanning.yml) | Uploads the same findings as SARIF to the repo's **Security** tab. Skipped on pull requests from forks, which GitHub doesn't allow to write there. | [`jysf/setup-crustyimg@v1`](https://github.com/marketplace/actions/setup-crustyimg) + the CLI |
| [`pages.yml`](.github/workflows/pages.yml) | Builds the site: `crustyimg optimize` caps every photo at 1600 px and re-encodes it, then deploys to GitHub Pages. The run summary lists each photo's size before and after. | `jysf/setup-crustyimg@v1` |
| [`canary.yml`](.github/workflows/canary.yml) | Weekly, on Linux, macOS and Windows, with the newest crustyimg. It first checks that a known-bad image still **fails**, then that the site passes. | both |

There's also a [`.pre-commit-config.yaml`](.pre-commit-config.yaml) if you'd rather catch problems
before they're committed.

## Submit your cat

Send a photo of your cat as a pull request and it joins the **Guest stars** section, credited to
you. It goes through the same checks as every photo here, so if your phone saved where it was
taken, you'll find out. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Use it in your repo

The core of it is three lines in a workflow:

```yaml
      - uses: actions/checkout@v4
      - uses: jysf/crustyimg-action@v1
        with:
          paths: assets/**/*
```

A directory in `paths` covers only the images directly inside it; use a glob like `assets/**/*`
to include subfolders. Size budgets and rule settings go in a
[`.crustyimg-lint.toml`](.crustyimg-lint.toml).

For the full walkthrough (budgets, required checks, pull requests from forks, fixing findings),
see the [GitHub Actions guide](https://github.com/jysf/crustyimg/blob/main/docs/github-actions.md).

## About the photos

The photos are of real cats and are not covered by the code license. The GPS coordinates in the
"leaked" photos are fake: they point at the Hemingway House in Key West, home of the famous
six-toed cats.

## License

The code (HTML, CSS, JavaScript, workflows, config) is under the [MIT license](LICENSE-MIT). The
photos in `assets/photos/` are © their owner, all rights reserved. Guest photos in
`assets/photos/guests/` are © their contributors and shown under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
