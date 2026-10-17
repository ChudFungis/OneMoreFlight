# Browser export and deployment

A **Web** preset is included in `export_presets.cfg`, with threads and extensions disabled. The game uses GDScript and Compatibility rendering. No deployment has been performed.

1. In Godot 4.7.2, open **Editor → Manage Export Templates** and install the templates matching the editor version. This environment does not have Web export templates installed.
2. Open **Project → Export → Web**. Keep Thread Support off. Choose an output folder **outside this repository**, such as `/tmp/one-more-flight-web/index.html` for temporary local tests. Export all generated companion files together. The preset excludes tests/docs and includes all imported textures for path-based artwork.
3. Export the project. With templates installed, the equivalent command is:

   ```sh
   mkdir -p /tmp/one-more-flight-web
   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release Web /tmp/one-more-flight-web/index.html
   python3 -m http.server 8000 --directory /tmp/one-more-flight-web
   ```

4. Open `http://localhost:8000`. Do not open `index.html` with `file://`. For an iPhone on the same Wi-Fi, use the Mac's local IP address and port, subject to firewall/network access. For production, use HTTPS static hosting and upload the entire output folder after obtaining the owner's approval.
5. Check portrait Safari on the actual phone: rapid taps, scrolling upgrade choices, safe areas, address-bar resizing, rotation, tab switching/pause, and restart/Continue. Choose New Game and cancel once to verify progress survives.
6. Change settings, finish a workday, close/reopen the tab, and confirm local persistence. Keep the same host/origin and allow browser storage. Private browsing, storage clearing, OS eviction, and blocked IndexedDB can prevent or erase saves. This is device-local storage, not a cloud account.

Single-thread export avoids the SharedArrayBuffer/cross-origin-isolation requirement of threaded builds. Godot maps `user://` persistence to browser storage when permitted. See [Godot's official Web export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) for platform constraints and hosting details.

The Web preset contains no service worker/offline cache, external analytics, or network requests. Browser download size is mainly the Godot runtime plus illustrations; optimize replacement images before exporting. Initial load, mobile performance and durable Safari storage must be verified on a real device before sharing the game.
