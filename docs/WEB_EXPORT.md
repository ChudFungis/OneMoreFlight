# Browser export and deployment

A **Web** preset is included in `export_presets.cfg`, with threads and extensions disabled. The game uses GDScript and Compatibility rendering. No deployment has been performed.

1. In Godot 4.7.2, open **Editor → Manage Export Templates** and install the templates matching the editor version. The matching 4.7.2 single-thread Web debug/release templates were installed during v0.3.1 validation; other platform templates are not installed.
2. Open **Project → Export → Web**. Keep Thread Support off. Choose an output folder **outside this repository**, such as `/tmp/one-more-flight-web/index.html` for temporary local tests. Export all generated companion files together. The preset excludes tests/docs and includes all imported textures for path-based artwork.
3. Export the project. With templates installed, the equivalent command is:

   ```sh
   mkdir -p /tmp/one-more-flight-web
   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release Web /tmp/one-more-flight-web/index.html
   python3 -m http.server 8000 --directory /tmp/one-more-flight-web
   ```

4. Open `http://localhost:8000`. Do not open `index.html` with `file://`. For an iPhone on the same Wi-Fi, use the Mac's local IP address and port, subject to firewall/network access. For production, use HTTPS static hosting and upload the entire output folder after obtaining the owner's approval.
5. Check portrait Safari on the actual phone: rapid taps, scrolling upgrade choices, safe areas, address-bar resizing, rotation, tab switching/pause, and fresh starts from the home heart. Reload midway through a run: the game should return home and the heart should start from chapter 1 while completed records survive.
6. Change settings, finish a workday, close/reopen the tab, and confirm local persistence. Keep the same host/origin and allow browser storage. Private browsing, storage clearing, OS eviction, and blocked IndexedDB can prevent or erase saves. This is device-local storage, not a cloud account.

Single-thread export avoids the SharedArrayBuffer/cross-origin-isolation requirement of threaded builds. Godot maps `user://` persistence to browser storage when permitted. See [Godot's official Web export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) for platform constraints and hosting details.

The Web preset contains no service worker/offline cache, external analytics, or network requests. Browser download size is mainly the Godot runtime plus illustrations; optimize replacement images before exporting. Initial load, mobile performance and durable Safari storage must be verified on a real device before sharing the game.

## v0.3 check

The Web release export command was run during v0.3 validation. Godot reported missing 4.7.2 `web_nothreads_debug.zip` and `web_nothreads_release.zip` templates; no runnable browser artifact was produced. The preset remains unchanged. After installing templates, check the new heart input, all three compact reward cards, event/relic artwork, reduced-motion preference, focus pause, touch scrolling and device safe areas in the browser.

## v0.3.1 successful export

The missing-template issue was resolved using the standard template package linked from the [official 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/). Only the two Web no-thread templates were extracted, their archive CRCs checked, and the matching files installed in the local Godot `export_templates/4.7.2.stable/` directory. The ordinary, unchanged Web preset then exported successfully using:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release Web /tmp/one-more-flight-v031-web/index.html
```

The output contains HTML, JavaScript, WASM, PCK, icons and audio helper files. No hosting, publishing or deployment occurred. No browser is connected to the available UI tool, so actual browser rendering, reload persistence and iPhone/Android touch behavior could not be checked. Serve the complete output directory over HTTP as above to finish those checks. Completed results must remain on the same origin with browser storage enabled; clearing site data removes local records.

## v0.3.3 flow check

The normal Web release command succeeds for `/tmp/one-more-flight-v033-web/index.html` using the installed matching templates. The preset still disables threads and extensions. The export includes the existing artwork, local-results support and new transition phase. A browser connection was unavailable during validation; confirm automatic day starts, release guards after cards/events, focus pause, day-3/day-6 events, reload during the brief transition and local results on actual mobile browsers before sharing the build. The build was not published.

Version 0.4 also exports successfully with the same installed 4.7.2 templates and unchanged Web preset. Output is `/tmp/one-more-flight-v04-web/index.html`; Baloo 2 is packaged locally. Browser/device runtime validation remains outstanding.

The suitcase collection also passes the unchanged Web release preset; local output is `/tmp/one-more-flight-suitcase-web/index.html`. It uses standard Controls, drawing and Tweens, with no shaders, physics or additional dependencies. Actual browser/device interaction still needs manual validation.

## GitHub Actions build preparation (no publication)

The `.github/workflows/build-web.yml` workflow builds a downloadable website package only. It has read-only repository permissions, no Pages deployment job and no publishing credentials. Creating or merging this change does not publish the game.

The workflow runs for pull requests targeting `main` or `feature/v0.4-cozy-pixel-arcade`, pushes to `main` or `build/web-export`, and manual dispatch. GitHub normally exposes the manual Run workflow button only once the workflow exists on the default branch; the preparation branch push / pull request can run it beforehand.

It installs Godot 4.7.2 Standard and the matching no-thread Web templates from the official Godot build release, imports the project, runs the existing isolated-save regression scene, and exports to `build/web/index.html`. Engine error output fails the job even if Godot exits successfully. Build output is ignored by Git and excluded from export inputs so an earlier export cannot be packed into a later one. Do not commit generated HTML/JS/WASM/PCK files or the `.godot` cache.

### Download and test

1. Open the repository's **Actions** tab, select **Build Web (no deployment)** and open a successful run.
2. Download the `one-more-flight-web-...` artifact from the run's Artifacts section and extract the entire ZIP. The package contains `index.html` and all companion files at its root, plus `build-commit.txt` identifying the tested source.
3. Serve the extracted directory over HTTP, for example `python3 -m http.server 8000 --directory /path/to/extracted-artifact`. Opening the HTML directly using `file://` is unsupported.
4. Test mobile Safari and Android Chrome: fresh launch, rapid heart taps, nested suitcase scrolling, reward/event selection, safe areas, rotation/address-bar resizing, focus loss/resume, and a complete three-chapter run.
5. Reload and close/reopen the browser. Completed best/recent records and settings should survive when browser storage is allowed. The home heart intentionally starts a new run; unfinished campaign resumption is not the acceptance criterion.
6. Confirm bundled Baloo text and decorative symbols, every dynamically loaded illustration, and the absence of browser-console errors. Repeat under a `/OneMoreFlight/` URL subpath before Pages publication.
7. Download `godot-logs-...` if a run fails. A successful export is not proof of physical-device compatibility.

### Later Pages release (separate approval)

The current newer game lives on `feature/v0.4-cozy-pixel-arcade`; do not deploy the older `main` by accident. Review and integrate that game version into the intended release branch separately.

After browser acceptance and explicit publishing approval, set Pages source to GitHub Actions and add a deployment job using the official configure-pages/upload-pages-artifact/deploy-pages actions. Only that job needs `pages: write`, `id-token: write` and the `github-pages` environment. Restrict publication to the approved release branch, while pull requests keep building without deploying. The website artifact must contain `index.html` at its root. Publish all companion files together over HTTPS and retain the same game name/storage paths for local scores. GitHub Pages is free for this public repository.

No browser/device checks or new CI run are claimed by this preparation commit. Results must be recorded after the workflow actually executes.
