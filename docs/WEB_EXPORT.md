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

## GitHub Actions publishing

The owner approved first publication on 2026-10-17. The workflow `.github/workflows/build-web.yml` installs Godot 4.7.2 Standard and matching single-thread Web templates, imports assets, runs the existing isolated-save regression suite, and exports `build/web/index.html`. Generated files are ignored by Git and excluded from export inputs.

Pull requests build and upload a downloadable `one-more-flight-web-...` artifact without deploying. Pushes to `main`, or a manual run on `main`, additionally upload the complete Pages artifact and deploy through the `github-pages` environment. Build jobs have read-only repository permissions; only the deployment job has Pages write and OIDC permissions. No personal access token or external deployment service is required.

### One-time repository setting

In repository **Settings → Pages → Build and deployment → Source**, select **GitHub Actions**. The ordinary workflow token cannot enable a previously unconfigured Pages site. If the configuration step reports that the site is missing, set this option, then rerun failed jobs from the Actions run.

The intended URL is https://chudfungis.github.io/OneMoreFlight/ . Do not call it live until the deployment succeeds and the URL is verified.

### Updates and testing

Merge reviewed game updates into `main`; the same import/test/export/deploy process updates the website automatically. Failed tests or exports prevent deployment. Keep the game name and local storage paths stable to preserve browser records where browser storage permits.

Download the complete website artifact from a successful Actions run to test locally. Extract the whole ZIP and serve it over HTTP, for example `python3 -m http.server 8000 --directory /path/to/extracted-artifact`. Do not open `index.html` using `file://`. The artifact includes `build-commit.txt` identifying the source revision.

Before wider sharing, check mobile Safari and Android Chrome: launch, rapid taps, nested suitcase scrolling, choices, safe areas, address-bar resizing, rotation, tab switching/pause and a complete run. Verify bundled Baloo text, decorative symbols and every illustration at the actual `/OneMoreFlight/` URL. Reload and close/reopen the browser to check completed records/settings. The home heart intentionally starts a fresh run. Private mode, storage clearing or eviction can remove local scores.

Initial build-only CI passed 10,978 checks with zero failures and produced a 10.8 MB website artifact (run 39061289621). Intentional corrupt-save recovery warnings were the only warnings in that run. Physical-device/browser persistence validation remains outstanding.
