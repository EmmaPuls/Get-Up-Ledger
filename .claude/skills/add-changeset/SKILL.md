---
name: add-changeset
description: Add a knope changeset for a PR in this repo. Every PR with a user-visible change must include a changeset under .changeset/ or the "Changeset exists" CI check fails the merge. Use when finishing a change, opening a PR, or when the user asks to add/create a changeset.
---

# Add a changeset

Every PR against `main` that makes a user-visible change **must** add a changeset
file under `.changeset/`. The [Changeset exists](../../../.github/workflows/changeset-exists.yml)
CI check fails the PR otherwise, blocking the merge.

Changesets are managed by [knope](https://knope.tech). At release time knope
consumes every `.changeset/*.md` file, bumps the version in `VERSION` by the
highest severity present, and writes release notes to `CHANGELOG.md`.

## Steps

1. **Ask the user whether they want to add a changeset.** If the change is
   user-visible (a feature, fix, or behaviour change), one is required to merge.
   Skip only for non-user-visible changes (internal refactors, CI tweaks, docs)
   if the user confirms.

2. **Pick a severity** (Semantic Versioning):
   - `patch` — bug fixes, no API/behaviour change for users.
   - `minor` — new, backwards-compatible features.
   - `major` — breaking changes.

   Propose one based on the diff; let the user override.

3. **Pick a one-line summary** describing the change from the user's
   perspective. This becomes the entry title in `CHANGELOG.md`. Base it on the
   actual changes (inspect the diff with `git diff main...HEAD` if unsure).

4. **Create the changeset** with the helper script:

   ```sh
   .claude/skills/add-changeset/create-changeset.sh <severity> "<summary>"
   ```

   Example:

   ```sh
   .claude/skills/add-changeset/create-changeset.sh minor "Add dark mode toggle to settings"
   ```

   The script writes `.changeset/<slug>.md` in the format knope expects:

   ```markdown
   ---
   default: minor
   ---

   # Add dark mode toggle to settings
   ```

5. **Commit the changeset** alongside the code changes.

## Notes

- knope parses *every* `.md` file in `.changeset/`, so never put a `README.md`
  or other non-changeset markdown in that directory. The empty dir is held by
  `.gitkeep`.
- `knope document-change` is the interactive equivalent of this script (prompts
  for severity + summary). The script is preferred for agent use because it's
  non-interactive.
- Full workflow details: [`HOW_TO_RELEASE.md`](../../../HOW_TO_RELEASE.md).
