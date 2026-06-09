# How to Release

Releases for Get Up Ledger are managed with [knope](https://knope.tech) and
per-change changesets. This document describes the day-to-day changeset workflow
and the release process.

## Prerequisites

Install knope locally. The pinned version is **0.22.4**, matching the
`knope-dev/action@v2.1.2` step in [`.github/workflows/release.yml`](.github/workflows/release.yml).

```sh
brew install knope-dev/tap/knope
knope --version   # should report 0.22.4
```

Configuration lives in [`knope.toml`](knope.toml). The version source is
[`Version.xcconfig`](Version.xcconfig) — its `MARKETING_VERSION` key is the
canonical marketing version (`CFBundleShortVersionString`), referenced by the
Xcode project at the project level so every target inherits it. Release notes
accumulate in [`CHANGELOG.md`](CHANGELOG.md).

## Adding a changeset

Every PR that makes a user-visible change **must** add a changeset — the
[Changeset exists](.github/workflows/changeset-exists.yml) check fails the PR
otherwise.

Run the `document-change` workflow and answer the prompts:

```sh
knope document-change
```

You will be asked for:

1. **Severity** — `patch`, `minor`, or `major` (Semantic Versioning).
2. **A summary** — becomes the entry title in `CHANGELOG.md`.

This writes a new `.md` file into [`.changeset/`](.changeset/). The format
matches the existing entries:

```markdown
---
default: minor
---

# Short description of the change
```

You can also create the file by hand if you prefer, as long as it follows the
format above.

Commit the generated changeset alongside your code changes.

> **Note:** knope parses *every* `.md` file in `.changeset/`, so don't put a
> `README.md` (or any other non-changeset markdown) in that directory. The empty
> directory is held by `.gitkeep`.

## Cutting a release

Releases are marked on GitHub with a **release branch** (`release/X.Y.Z`) and an
annotated **tag** (`vX.Y.Z`). The marketing version itself is bumped by knope;
the branch and tag are created by hand until the publish pipeline is automated.

### 1. Preview the version

From an up-to-date `main`, preview the bump without writing anything:

```sh
git switch main && git pull
knope release --dry-run
```

The `Would add ... MARKETING_VERSION = X.Y.Z` line is the next version. knope
picks it from the highest severity among the pending `.changeset/*.md` files
(`patch` → `minor` → `major`). Use that `X.Y.Z` in the steps below.

### 2. Create the release branch

```sh
git switch -c release/X.Y.Z
```

### 3. Apply the release

```sh
knope release
```

This consumes all `.changeset/*.md` files, bumps `MARKETING_VERSION` in
[`Version.xcconfig`](Version.xcconfig), writes release notes to
[`CHANGELOG.md`](CHANGELOG.md), and stages the changed files. The new marketing
version flows into the app on the next Xcode build (xcconfig →
`CFBundleShortVersionString`).

### 4. Commit, tag, and push

```sh
git commit -m "Release X.Y.Z"
git tag -a vX.Y.Z -m "Release X.Y.Z"
git push -u origin release/X.Y.Z
git push origin vX.Y.Z
```

Tags are `v`-prefixed (`v1.2.0`); the branch and `MARKETING_VERSION` are not
(`1.2.0`).

### 5. Merge and publish

1. Open a PR from `release/X.Y.Z` into `main` and **merge with a merge commit**
   (not squash) so the tagged commit stays in `main`'s history.
2. Create the GitHub Release from the tag, using the new `CHANGELOG.md` section
   as the notes:

   ```sh
   # Extracts the topmost CHANGELOG section (the release just cut):
   gh release create vX.Y.Z --title "X.Y.Z" \
     --notes-file <(awk '/^## /{n++; if (n==2) exit} n>=1' CHANGELOG.md)
   ```

   Or create it from the GitHub UI ("Releases" → "Draft a new release" → pick
   `vX.Y.Z`) and paste the changelog section manually.

> **Status:** `knope release` only bumps the version and changelog — it does not
> yet commit, push, tag, or open the GitHub Release; those are the manual steps
> above. [`.github/workflows/release.yml`](.github/workflows/release.yml) is still
> a smoke test (verifies the pinned knope version installs and `knope.toml`
> parses). Automating steps 4–5 is tracked for a later ticket.

## CI checks

- **Changeset exists** — every PR against `main` must add a file under
  `.changeset/`.
- **Release** — verifies the pinned knope version installs and `knope.toml` is
  valid.
