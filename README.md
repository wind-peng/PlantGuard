# PlantGuard — 植物守卫 App

iOS app (TrollStore) for the 植物守卫 word-learning game: a WKWebView shell
around the game. No login, no browser chrome, fullscreen.

- App name: 植物守卫， bundle id `com.peng.plantguard`, iOS 16.0+, iPhone + iPad.
- **Landscape is the main experience.** The app imposes no orientation lock
  (all four orientations declared for iPhone and iPad); in landscape the game
  shows its wide lawn (8 columns, plant bar along the bottom). Portrait works too.
- Install: take the `PlantGuard-v1.0.0.tipa` from the Actions artifact and
  install it with TrollStore.

## How content updates reach the user (no reinstall)

The game HTML is served from GitHub Pages at
`https://wind-peng.github.io/PlantGuard/` (`index.html` in this repo root),
plus `version.json` (`{"version": N, ...}`).

On launch the app fetches `version.json` (8s timeout). If the remote version
is newer than the version it has stored, it downloads `index.html`, saves it
locally and loads it. If offline or the fetch fails, it loads the locally
cached copy. First launch with no cache and no network loads the copy bundled
inside the app (`PlantGuard/index.html`), so the game always opens.

To publish a content change (words, audio, plants, layout):

1. Edit the game in Muse (web artifact `zhi-wu-shou-wei-xiao-you-xi`) and
   export it: the fresh file lands at
   `~/workspace/your_files/zhi-wu-shou-wei-xiao-you-xi/zhi-wu-shou-wei-xiao-you-xi.html`.
2. Replace **both** copies in this repo with the exported file:
   - `index.html` (repo root — served by GitHub Pages)
   - `PlantGuard/index.html` (bundled fallback inside the app)
3. Bump `version.json`: `version` + 1, update `updated` to today's date.
4. Push to `main` (see `plantguard_push.py` in the workspace, or push with git).
   The push also triggers a rebuild, but the already-installed app does NOT
   need the new build: it picks up the new game from GitHub Pages on next
   launch, because `version.json` changed.
5. The user just opens the app. No reinstall, no new .tipa needed for
   content-only changes. A new .tipa is only needed when the app shell
   itself (Swift code, Info.plist, icon) changes.

## Build

`build.sh` runs `xcodebuild` on `macos-15-intel` (see
`.github/workflows/build.yml`) and packages the unsigned `.app` as
`PlantGuard-v1.0.0.tipa` (zip of `Payload/PlantGuard.app`) for TrollStore.
Public-repo builds are free; private-repo Actions minutes are exhausted.
