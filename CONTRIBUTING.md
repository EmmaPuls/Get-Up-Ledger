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

Configuration lives in [`knope.toml`](knope.toml). The version source is the
[`VERSION`](VERSION) file, and release notes accumulate in
[`CHANGELOG.md`](CHANGELOG.md).

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

When the accumulated changesets are ready to ship, run the `release` workflow:

```sh
knope release
```

This consumes all `.changeset/*.md` files, bumps the version in
[`VERSION`](VERSION) according to the highest severity present, and updates
[`CHANGELOG.md`](CHANGELOG.md).

> **Status:** The `release` workflow is currently a stub (scaffolded by GUA-22).
> The full publish pipeline — commit, push, GitHub Release, and forge
> configuration — is being finalised in GUA-24. Until then,
> [`.github/workflows/release.yml`](.github/workflows/release.yml) only smoke-tests
> that the pinned knope version installs in CI and that `knope.toml` parses.

## CI checks

- **Changeset exists** — every PR against `main` must add a file under
  `.changeset/`.
- **Release** — verifies the pinned knope version installs and `knope.toml` is
  valid.
