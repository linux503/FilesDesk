# FilesDesk

**Smart File Renamer for Mac**

Simple, native, safe, and fast. FilesDesk batch-renames files on macOS with live preview, undo, history, and presets. It never overwrites a file that already exists.

![FilesDesk](docs/assets/og.png)

## Download

- Website: [linux503.github.io/FilesDesk](https://linux503.github.io/FilesDesk)
- Releases: [GitHub Releases](https://github.com/linux503/FilesDesk/releases)
- In-app updates: Sparkle + [appcast.xml](https://linux503.github.io/FilesDesk/appcast.xml)

Requires macOS 14+.

## Features

- Drag and drop, Add Files, Add Folder
- Live new-name preview
- Replace, Prefix, Suffix, Remove, Numbering, Case, Date, Cleanup, Regex
- Validation before rename
- Undo and History
- Saved presets

## Source layout

```
FilesDesk/           App sources
FilesDeskTests/      Rename engine tests
docs/                Website, FAQ, privacy, changelog, Sparkle feed
scripts/             Build, test, tag, release
```

## Development

```bash
make test
make build
```

Open `FilesDesk.xcodeproj` in Xcode 16 or later.

## Release

```text
Build → Test → Tag → Release → Website sync
```

```bash
make test
make release VERSION=1.0.1
```

The script builds the app, runs tests, tags `vVERSION`, publishes a GitHub Release, signs the zip for Sparkle, and updates `docs/appcast.xml`.

Store the Sparkle private key as `sparkle/eddsa-private.key` locally. The GitHub secret `SPARKLE_EDDSA_PRIVATE_KEY` is already configured for this repository. Never commit the private key.

GitHub Actions files live in `.github/workflows`. Pushing them requires a token with the `workflow` scope:

```bash
gh auth refresh -h github.com -s workflow
git add .github
git commit -m "Add CI, Pages, and Release workflows."
git push
```

## License

MIT
