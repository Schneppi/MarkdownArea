# CLAUDE.md

## App Store changelog (Marketing folder)

The program version is `MajorVersion.MinorVersion.SubVersion` in `MarkdownArea.xojo_project` (e.g. `1.0.0`).

- Keep one changelog file per version: `Marketing/Changelog-<version>.txt`, e.g. `Marketing/Changelog-1.0.0.txt`.
- When the version number changes, create a new file for the new version. Leave the files of earlier versions as they are.
- Until the version changes, keep updating the current version's file. Whenever you make a change a user or buyer would notice or care about (a new feature, a visible improvement, a fixed bug), add or adjust a line in it in the same commit.
- Skip changes users can't notice: refactoring, code comments, documentation, build or project housekeeping.
- The text is pasted as is into the "What's New in This Version" field in App Store Connect:
  - Plain text in English, no Markdown (no `#`, `**` or backticks). Start each item with `• `.
  - Short and friendly, minimal to no technical jargon: say what the user gets, not how it was built.
  - Describe what changed since the previous version, not the whole history. Merge or reword items when a later change supersedes an earlier one.
  - Stay well below App Store Connect's 4,000-character limit.
