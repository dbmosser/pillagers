# Browser and Canvas 2D technology for PILLAGERS (2025 to October 2026)

Scope note: research by web search and web fetch only (no browser pane). Version numbers marked "BCD" come from the MDN browser-compat-data JSON files fetched on 2026-10-25. Items marked OLDER are from before 2025 and may have changed. A few findings come from the game file itself (grep counts on `C:\claudecode\dark raiders\dark_raiders.html`) so the ranking can point at real code; those are marked LOCAL.

## 1. Canvas 2D performance in Chrome, Edge and Firefox (2025 to 2026)

### Takeaway
Canvas 2D is GPU rasterized in Chromium (Skia; the new Graphite backend shipped July 2025 but only on Apple Silicon Macs, so Windows Chrome and Edge still run the older Ganesh path over ANGLE/D3D), and the expensive operations are still the same ones: blur (ctx.filter blur, shadowBlur), readbacks (getImageData), and per-frame creation of large gradients and offscreen work. All the "new" Canvas 2D API pieces a game would use (reset, roundRect, conic gradients, letterSpacing, contextlost events, willReadFrequently) have shipped in Chrome and Firefox; layers (beginLayer/endLayer) and HTML-in-Canvas have not shipped as stable features.

### Cited Findings
- Graphite launch: Google announced on July 8, 2025 that Skia Graphite launched in Chrome on Apple Silicon Macs, with a nearly 15% MotionMark 1.3 score increase on a MacBook Pro M3 (the jump shows between M133 and M134), plus unquantified improvements in INP, LCP and "graphics smoothness (percent of dropped frames)". ([Google blog, The Fast and the Curious](https://blog.google/chromium/introducing-skia-graphite-chromes/))
- In Graphite, one "Recorder" handles web content tiles and Canvas2D on the main thread; a second Recorder handles compositing; Recordings are submitted to the GPU on the main thread, with rasterization across 2 to N threads planned. ([Google blog](https://blog.google/chromium/introducing-skia-graphite-chromes/))
- Graphite gives each draw a z value so opaque objects cut overdraw through the depth buffer, and uses depth-only draws for clipping; Ganesh did not use depth testing. Ganesh's many specialized pipelines caused shader compilation jank "when new effects appeared"; Graphite consolidates pipelines so they can be compiled at startup. ([Google blog](https://blog.google/chromium/introducing-skia-graphite-chromes/))
- The same announcement describes the older path as GPU rasterization on top of GL, via ANGLE on Windows (D3D9/11). No source found says Graphite is enabled on Windows as of October 2026. ([Google blog](https://blog.google/chromium/introducing-skia-graphite-chromes/); [Phoronix](https://www.phoronix.com/news/Chromium-Skia-Graphite))
- A third-party SkiaSharp issue says Graphite is expanding to other platforms and that on Windows Chrome's path would run through Dawn over D3D12 or Vulkan; secondary source, no date given. ([SkiaSharp issue 3962](https://github.com/mono/SkiaSharp/issues/3962))
- BCD versions for CanvasRenderingContext2D: `reset()` Chrome 99, Firefox 113, Safari 17.2; `roundRect()` Chrome 99, Firefox 112, Safari 16; `filter` Chrome 52, Firefox 49, Safari 18; `createConicGradient()` Chrome 99, Firefox 112 (older spec 90 to 112), Safari 16.1; `letterSpacing` Chrome 99, Firefox 115, Safari 18.4; `fontKerning` Chrome 99, Firefox 104, Safari no; `isContextLost()` Chrome 99, Firefox 125, Safari no; `imageSmoothingQuality` Chrome 54, Firefox not supported, Safari 9.1; `lang` Chrome 136, Firefox 151; `drawElementImage` listed as Chrome 157, experimental and not on a standards track. ([MDN BCD CanvasRenderingContext2D.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/CanvasRenderingContext2D.json))
- BCD versions for getContext('2d') options: `alpha` Chrome 32, Firefox 30; `desynchronized` Chrome 81 ("ChromeOS and Windows"; 75 to 81 ChromeOS only), Firefox not supported, Safari 15; `willReadFrequently` Chrome 99, Firefox 28, Safari 18; `colorSpace` Chrome 92, Safari 15.2, Firefox not supported; `colorType` Chrome 137, experimental. `transferControlToOffscreen` Chrome 69, Firefox 105, Safari 16.4. ([MDN BCD HTMLCanvasElement.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/HTMLCanvasElement.json))
- Chrome's Canvas2D feature post (OLDER, last updated 2022-03-03) lists roundRect, conic gradients, CSS-matching text properties (letterSpacing, wordSpacing, fontVariant, fontKerning, fontStretch, textDecoration, textUnderlinePosition, textRendering), `ctx.reset()` as the replacement for the `canvas.width = canvas.width` hack, the `CanvasFilter` object (`new CanvasFilter([{filter:'gaussianBlur', stdDeviation:5}])`), `willReadFrequently` ("getImageData() can be very slow"), and contextlost/contextrestored events, with running out of GPU memory as the example cause. It does not mention layers. ([Chrome for Developers, Canvas2D](https://developer.chrome.com/blog/canvas2d))
- Readback heuristics (OLDER): a Chromium review deferred the GPU or CPU choice until a canvas is first flushed, and "if that first flush is a readback, GPU-acceleration will be disabled for the canvas"; another change fell back to software when drawing very large images because texture upload overhead was prohibitive. A 2022 WebKit thread says Firefox, Edge and Chrome were removing CPU/GPU switching heuristics to make behaviour predictable, with `willReadFrequently` as the explicit opt-in. Current Chrome heuristic state not confirmed. ([Chromium review 2388293002](https://codereview.chromium.org/2388293002); [WebKit bug 235196](https://bugs.webkit.org/show_bug.cgi?id=235196))
- Blur cost: Mozilla bug 1978851 (opened about a year ago, still open, updated about two months ago) reports applying a ctx.filter blur N times is 28x slower in Firefox than Chrome; with the blur value changing each iteration, 9.5 s in Firefox vs 2.7 s in Chrome (Chrome has a fast path for re-setting the same filter). ([Bugzilla 1978851](https://bugzilla.mozilla.org/show_bug.cgi?id=1978851))
- shadowBlur (OLDER): a Firefox profile showed most time spent drawing a drop shadow for a canvas fill in Skia; a later commenter said shadowBlur was still "orders of magnitude slower in Firefox than Blink". Anecdotal. ([Bugzilla 1190398](https://bugzilla.mozilla.org/show_bug.cgi?id=1190398))
- Canvas 2D layers: Chromium asked WebKit for a position on `beginLayer()`/`endLayer()` in December 2021 (draw a series of instructions as a unit instead of a temporary canvas); WPT layer tests exist in Chromium's tree. BCD as fetched did not list beginLayer, and no shipped status was found. ([webkit-dev Request for Position](https://lists.webkit.org/pipermail/webkit-dev/2021-December/032066.html); [WPT commit](https://chromium.googlesource.com/external/w3c/web-platform-tests/+/refs/tags/merge_pr_40073%5E%21/))
- HTML-in-Canvas (draw DOM into a 2D canvas while it stays interactive) is a Chrome origin trial; Chrome 150 and 155 changed it (renamed methods, required texture memory pre-allocation, new DOM sync) and the trial was extended. A Better Stack guide (April 2026) calls it experimental and not for production. ([Chrome blog, HTML-in-Canvas OT](https://developer.chrome.com/blog/html-in-canvas-origin-trial); [Chrome blog, HTML-in-Canvas updates](https://developer.chrome.com/blog/html-in-canvas-ot-changes); [Better Stack guide](https://betterstack.com/community/guides/scaling-nodejs/html-in-canvas-api/))
- OffscreenCanvas in a worker keeps heavy drawing off the main thread so input and UI stay responsive and a worker-driven animation keeps running when the main thread is busy; the worker has no DOM, so input handling stays on the main thread and talks to the worker by messages. Example: `const off = canvas.transferControlToOffscreen(); worker.postMessage({canvas: off}, [off]);` (OLDER article, updated since; support Firefox 105, Safari 16.4). ([web.dev OffscreenCanvas](https://web.dev/articles/offscreen-canvas))
- LOCAL: `dark_raiders.html` contains 59 `createRadialGradient` calls, 15 `shadowBlur` uses, 16 canvas `filter` strings (including full-screen `blur(...)`, `hue-rotate(...)` and `invert(1)` post effects around lines 41992 to 42066 drawn with `c2.drawImage(cnv,...)`), 208 `globalCompositeOperation` sets, 9 `getImageData`, 3 `willReadFrequently`, a CSS SVG gamma filter applied to the canvas element (`cv.style.filter='url(#gamf)'`, line 52940) when brightness is not 1, and no use of `OffscreenCanvas`, `createImageBitmap` or `desynchronized`. ([LOCAL grep of dark_raiders.html](file:///C:/claudecode/dark%20raiders/dark_raiders.html))

### Inferences
- The biggest Canvas 2D costs in a game like this are fill-rate costs that JS timers do not see: full-screen blur filters, shadowBlur on text and shapes, and large radial gradients redrawn each frame. Pre-rendering those into sprites (an offscreen canvas made once at load or on resolution change, then `drawImage`) moves the cost to load time.
- A full-screen `ctx.filter='blur()'` whose radius changes every frame defeats Chrome's same-filter fast path and is the case Firefox bug 1978851 shows is 3.5x to 28x slower on Firefox; quantize the radius to a few steps and reuse.
- `willReadFrequently: true` should only go on canvases that are read back (it puts that canvas on the CPU path); the main play canvas should never be read back during play, or Chromium may move it off the GPU.
- The CSS `url(#svg filter)` gamma on the full 4K canvas element is worth measuring with brightness set away from 1; an alternative is a `multiply`/`screen` full-screen rect or a gamma lookup baked into the light pass.
- Hold off on layers and HTML-in-Canvas: neither is a stable shipped API across Chrome and Firefox.

### Gaps
- No 2025 or 2026 published benchmark comparing Canvas 2D operation costs (drawImage counts, composite modes, gradients) across current Chrome, Edge and Firefox was found.
- Whether Graphite is on by default for Windows Chrome or Edge in October 2026 could not be confirmed.
- Current Chromium behaviour of the "first flush is a readback" heuristic could not be confirmed.
- beginLayer/endLayer ship status in any browser not found.

## 2. Frame pacing: rAF on high and variable refresh, refresh detection, throttling, two windows

### Takeaway
There is still no web API to read the display refresh rate; the only method is timing requestAnimationFrame intervals, which is unreliable on multi-monitor and VRR setups. Chrome on Windows stops rendering windows that are fully covered (occlusion tracking since Chrome 86) but keeps rendering visible unfocused windows, so two side-by-side windows both get rAF. Cross-origin iframes (which is what an itch.io embed is) are throttled when not visible in the viewport.

### Cited Findings
- The animation timing spec intends rAF to run "at a regular interval matching the display's refresh rate"; behaviour on multiple monitors is not strictly defined. A Blur Busters forum post (OLDER) says Chrome uses the refresh rate of the monitor holding the largest area of the window. ([Blur Busters forum](https://forums.blurbusters.com/viewtopic.php?p=25739))
- Conflicting reports (OLDER): one developer says rAF-based methods report the primary monitor's Hz, and a Blur Busters user saw Chrome run rAF at 144 Hz with the window on a 60 Hz monitor; the Blur Busters author calls multi-monitor detection "an unfixable problem... a combined limitation by the OS + the web browser". ([Ourcodeworld](https://ourcodeworld.com/articles/read/1390/how-to-determine-the-screen-refresh-rate-in-hz-of-the-monitor-with-javascript-in-the-browser); [Blur Busters forum, how tests work](https://forums.blurbusters.com/viewtopic.php?p=44677))
- No refresh-rate API has shipped; a 2017 W3C thread proposed something like `display.getRefreshRate()`. rAF timing relies on presentation at exact multiples of the vsync interval, which breaks down on G-Sync/FreeSync. ([W3C public-webapps 2017](https://lists.w3.org/Archives/Public/public-webapps-github/2017Nov/0901.html); [W3C web-perf 2013](https://lists.w3.org/Archives/Public/public-web-perf/2013Aug/0057.html))
- Practical detection: time consecutive rAF callbacks over a rolling window, average, convert to Hz, and discard implausible samples from hidden or paused rendering. ([rapidtoolset refresh tester](https://rapidtoolset.com/en/tool/monitor-refresh-rate-tester))
- Chrome Windows native window occlusion tracking: shipped Chrome 86 (October 2020); when a window is occluded Chromium stops rendering its foreground tabs and throttles their JavaScript like background tabs; occlusion is not recalculated more than once every 16 ms; about 20% of Chrome windows were fully covered; 20.4% fewer renderer frames drawn and 3.1% less GPU memory. ([Chromium blog, Dec 2021](https://blog.chromium.org/2021/12/chrome-windows-performance-improvements-native-window-occlusion.html); [Chromium docs](https://chromium.googlesource.com/chromium/src/+/master/docs/windows_native_window_occlusion_tracking.md); [ghacks](https://www.ghacks.net/?p=176034))
- Chromium throttles cross-origin frames that are not visible in the root viewport, skipping rAF, style, layout and paint for them; 0x0 frames were later exempted (Gmail). Microsoft Edge (from Edge 116) has a policy to throttle display:none cross-origin iframes whether same-process or cross-process. ([Chromium review 2333653002](https://codereview.chromium.org/2333653002); [Microsoft Edge iframe throttling](https://learn.microsoft.com/en-us/deployedge/edge-learnmore-iframe-throttling-display))
- Safari throttles rAF in cross-origin iframes until a click or tap (not mouse or touchstart); iOS Low Power Mode roughly halves rAF to about 30 fps; Firefox `resistFingerprinting` reduces `performance.now()` precision to 100 ms, which makes rAF timestamps skip about six frames (OLDER, Oct 2020). ([Motion magazine](https://motion.dev/magazine/when-browsers-throttle-requestanimationframe))
- Long Animation Frames API (LoAF): shipped Chrome 123 (origin trial 116 to 122); a long frame is a rendering update delayed beyond 50 ms; entries carry `startTime`, `duration` (excludes presentation time), `renderStart`, `styleAndLayoutStart`, `firstUIEventTimestamp`, `blockingDuration` and `scripts` attribution (scripts over 5 ms; none for cross-origin iframes or workers). Observe with `new PerformanceObserver(...).observe({type:'long-animation-frame', buffered:true})`. ([Chrome for Developers, LoAF](https://developer.chrome.com/docs/web-platform/long-animation-frames))
- Low-latency canvas: `getContext('2d', {desynchronized:true})` Chrome 81 on ChromeOS and Windows, Safari 15, not Firefox. ([MDN BCD HTMLCanvasElement.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/HTMLCanvasElement.json))

### Inferences
- Two PILLAGERS windows side by side on one PC both keep rendering at full rate as long as neither is fully covered; covering one completely (or minimizing it) will stop its rendering and throttle its timers, which also stalls its simulation if the sim is driven from rAF.
- On itch.io the game runs in a cross-origin iframe, so scrolling the embed out of view can stop rAF; the loop must clamp large frame deltas and treat a long gap like a pause, not a 3 second physics step.
- For frame caps 75 to 240, the safest refresh estimate is the median rAF interval over about 1 to 2 seconds of steady play, re-measured when the window moves (resize, screen change) or visibility changes, and snapped to common rates (60, 75, 90, 100, 120, 144, 165, 180, 240). On VRR screens the measured value is the cap, not the panel, so the estimate should not be fed back into the cap.
- LoAF entries (Chrome and Edge only) are a cheap way to feed the flight recorder with real long-frame events from players.

### Gaps
- No 2025 or 2026 primary source found on how current Chrome or Firefox pace rAF on G-Sync/FreeSync monitors in windowed vs fullscreen mode.
- No current source confirming which monitor's vsync Chrome follows when a window spans or moves between monitors with different refresh rates.
- No source on how Windows/Chrome schedules GPU time between two visible windows of the same browser (shared GPU process); no measured data found.

## 3. Dynamic resolution and quality scaling in canvas games

### Takeaway
Canvas 2D gives no GPU timer, and Chrome records Canvas 2D commands on the main thread then rasterizes them elsewhere, so JS timing around draw calls measures recording, not GPU raster. The only reliable control signal is the wall-clock interval between frames (rAF timestamps), compared against measured CPU time per frame. Low-resolution offscreen layers (lighting especially) are the proven quality lever.

### Cited Findings
- In Chromium Graphite, Canvas2D is recorded by a Recorder on the main thread and submitted to the GPU separately, so GPU raster cost is not inside the JS call. ([Google blog](https://blog.google/chromium/introducing-skia-graphite-chromes/))
- LoAF `duration` excludes presentation time, and the LoAF documentation only describes main-thread work (callbacks, style, layout), not GPU or compositor time. ([Chrome for Developers, LoAF](https://developer.chrome.com/docs/web-platform/long-animation-frames))
- A Love2D lighting engine author reports that scaling the lightmap to 10% of width and height "still does not look that bad" while cutting the lightmap's pixels by 99%. ([LOVE forums, Luven](https://www.love2d.org/forums/viewtopic.php?p=226009))
- Excalibur.js warns its Canvas 2D lighting overlay is "potentially performance impacting" because it is rasterized with the 2D Canvas API and re-uploaded to the GPU every frame. ([Excalibur LightingSystem](https://excaliburjs.com/api/class/LightingSystem))
- `imageSmoothingQuality` (the quality of upscaling a low-res layer) is not supported in Firefox per BCD (Chrome 54, Safari 9.1), so upscaled layers look different between browsers. ([MDN BCD CanvasRenderingContext2D.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/CanvasRenderingContext2D.json))

### Inferences
- Classify each frame as CPU-bound or GPU-bound: if (rAF delta) is well over budget while (JS time from loop start to end of draw submission) is well under budget, the GPU or compositor is the bottleneck and resolution scale should drop; if JS time itself is over budget, resolution scaling will not help and particle or AI budgets should drop instead.
- Avoid resizing the main canvas backing store every few frames (each resize reallocates and clears the GPU surface); use a small set of fixed scale steps (for example 100, 85, 70, 50%) with hysteresis (drop after N slow frames, rise only after a longer good streak) so the scale does not oscillate.
- Scale the expensive layers independently: the lightmap and fog can sit at 25% to 50% resolution almost invisibly, while sprites, text and the HUD stay at native resolution on the HUD canvas.
- A forced sync (reading 1 pixel with getImageData) would expose GPU time but stalls the pipeline and can de-accelerate the canvas in Chromium; do not use it in shipping code.

### Gaps
- No 2025 or 2026 write-up or postmortem of a dynamic resolution system in a Canvas 2D game was found.
- No source on whether `EXT_disjoint_timer_query`-style GPU timing exists for Canvas 2D (it does not appear in any fetched spec or BCD entry).

## 4. Gamepad API in 2025 and 2026

### Takeaway
Xbox pads work everywhere through the standard mapping, but rumble is Chromium and Safari only: dual-rumble via `vibrationActuator.playEffect` (Chrome 68, Safari 16.4), trigger-rumble only in Chrome and Edge 126+, and nothing in Firefox. Cross-origin iframes (itch.io) need the `gamepad` permission policy in Firefox (Chrome defaults to allowing it). Input is gated on page visibility in the spec and Chromium, but some OS input APIs (Windows.Gaming.Input) require window focus, so two-window same-PC play may only feed pads to the focused window depending on the pad and code path.

### Cited Findings
- BCD Gamepad: `vibrationActuator` Chrome 68, Edge yes, Firefox not supported, Safari 16.4; `hapticActuators` Firefox 55 only. ([MDN BCD Gamepad.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/Gamepad.json))
- BCD GamepadHapticActuator: `playEffect()` and `reset()` Chrome 68, Edge 15, Firefox not supported, Safari 16.4; `effects` attribute, the `trigger-rumble` effect type and `params.leftTrigger`/`params.rightTrigger` Chrome 126, experimental, not Firefox or Safari; `pulse()` Firefox 55 only; `canPlayEffectType` Safari 16.4 only, deprecated. ([MDN BCD GamepadHapticActuator.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/GamepadHapticActuator.json))
- Conflict: an MDN mirror page labels `playEffect()` "non-standard"; BCD marks it neither experimental nor deprecated. A 2021 W3C post said Firefox had the actuator IDL but no platform backend created actuators (OLDER). ([MDN playEffect](https://developer.mozilla.org/en-US/docs/Web/API/GamepadHapticActuator/playEffect); [W3C public-webapps 2021](https://lists.w3.org/Archives/Public/public-webapps-github/2021Apr/0119.html))
- Permissions policy: when blocked, `navigator.getGamepads()` throws `SecurityError` and connect/disconnect events do not fire; Chrome supports the policy from 86, only through the iframe `allow` attribute, with a default allowlist of `*` instead of the spec's `self`. Firefox 82 required third-party iframes to be explicitly granted access by the host page; the API also requires a secure context. ([MDN Permissions-Policy: gamepad](https://developer.mozilla.org/docs/Web/HTTP/Headers/Feature-Policy/gamepad); [Mozilla Hacks, Securing Gamepad API](https://hacks.mozilla.org/2020/07/securing-gamepad-api/))
- An example iframe for embedding an itch.io game lists `allow="autoplay; fullscreen; gamepad; cross-origin-isolated"`; this is third-party, not itch.io's own published markup. ([Rosebud blog, Nov 2024](https://rosebud.ai/blog/how-to-embed-your-rosebud-game-on-itch-io))
- Focus vs visibility: the Gamepad spec considers visibility, not focus; "Allowing gamepad access from non-foreground windows is intentional"; "The Chromium implementation requires visibility before events are dispatched"; "On some platforms the system APIs we use to access gamepad inputs have focus requirements that prevent background access", and behaviour "can differ between different gamepads on the same system" (Matt Reynolds, Chromium, Sept 2024). ([W3C public-webapps, Sept 2024](https://lists.w3.org/Archives/Public/public-webapps-github/2024Sep/0476.html))
- Microsoft's Windows gaming input documentation states "A Windows application must have focus to receive input from a controller"; Chromium has both a Windows.Gaming.Input fetcher (`WgiDataFetcherWin`) and a Raw Input fetcher on Windows. ([search summary of Microsoft docs and Chromium source](https://gitcode.com/openharmony-tpc/chromium_src/blob/master/device/gamepad/wgi_data_fetcher_win.h); [raw_input_data_fetcher_win.h](https://chromium.googlesource.com/chromium/src/+/66.0.3329.1/device/gamepad/raw_input_data_fetcher_win.h))
- A 2018 W3C thread considered gamepad data for the current tab in all visible windows a reasonable design, with hidden or background tabs getting nothing. ([W3C public-webapps 2018](https://lists.w3.org/Archives/Public/public-webapps-github/2018Oct/0905.html))
- Event-driven input: Microsoft runs an Edge origin trial "Gamepad Raw Input Event" where pages listen for `gamepadrawinputchanged` instead of polling `navigator.getGamepads()`; the trial page lists expiry December 8, 2026. Press coverage (May 2025) frames it as a fix for controller input lag in Chrome and Edge on Windows 11 and quotes other event names, so the name may still change. ([Edge origin trial page](https://developer.microsoft.com/microsoft-edge/origin-trials/trials/4ecdb530-835b-447d-b27e-0b3be8e0412b); [PCWorld](https://www.pcworld.com/article/2796377/microsoft-plans-to-fix-controller-input-lag-in-chrome-and-edge.html); [Windows Latest, May 27 2025](https://windowslatest.com/2025/05/27/microsoft-wants-to-make-gamepad-gaming-faster-on-chrome-for-windows-11))
- LOCAL: the game calls `getGamepads` (6 sites) and `vibrationActuator` (5 sites) but never `trigger-rumble`. ([LOCAL grep of dark_raiders.html](file:///C:/claudecode/dark%20raiders/dark_raiders.html))

### Inferences
- Trigger rumble is a cheap Chrome/Edge-only extra: feature-detect with `pad.vibrationActuator && pad.vibrationActuator.effects && pad.vibrationActuator.effects.includes('trigger-rumble')` and fall back to dual-rumble.
- Firefox players on itch.io get no rumble at all and, if itch's iframe lacks `gamepad` in its allow list, no pad input either; this needs a one-time test of a private itch upload in Firefox.
- For same-PC co-op the robust layout is one window reading all pads (pad index to player mapping inside one page); two windows depend on per-pad, per-OS-API focus behaviour that the browser does not control.
- Gamepad state should keep being polled once per rAF; the Edge raw-input event is an origin trial and should not be relied on for the release.

### Gaps
- itch.io's own iframe `allow` attribute list could not be read (page markup is built by script); not confirmed whether it includes `gamepad`.
- No current source confirms which Windows API Chrome 14x/15x uses for an Xbox pad over USB vs Bluetooth, and therefore whether a visible but unfocused window receives that pad's input.
- No measured gamepad input latency numbers for 2025 or 2026 browsers were found.

## 5. Web Audio for a shooter

### Takeaway
One-shot `AudioBufferSourceNode`s with `StereoPannerNode` or gain-based distance attenuation are the cheap path; HRTF panning and convolution reverb are the expensive nodes to avoid at scale. New in Chrome: `AudioContext.playbackStats` (Chrome 146) and an `error` event (Chrome 128), both Chrome only.

### Cited Findings
- Node costs (OLDER, Mozilla engineer's notes, about 2015 to 2017): Blink and WebKit resample `AudioBufferSourceNode` linearly (cheap, no latency); `StereoPannerNode` is cheaper than equal-power panning and stateless; `PannerNode` HRTF is "very expensive" (up to four convolvers for a moving stereo source); equal-power `PannerNode` is fairly cheap; `ConvolverNode` is very expensive and scales with impulse length; `DynamicsCompressorNode` is cheap but adds 6 ms look-ahead. ([Paul Adenot, Web Audio API performance and debugging notes](https://padenot.github.io/web-audio-perf/))
- Same source (OLDER): AudioParam automation lists are scanned linearly outside Gecko, so swapping in a fresh GainNode periodically keeps them short and constant values take faster paths; Windows WASAPI output latency is about 10 ms; an underrun happens when rendering 5 ms of audio takes over 5 ms; AudioBuffer memory is length x channels x 4 bytes; non-Gecko engines decode `decodeAudioData` calls serially on one thread; resample assets to the context rate offline. ([Paul Adenot notes](https://padenot.github.io/web-audio-perf/))
- BCD AudioContext: `latencyHint` Chrome 58, Safari 14.1, Firefox listed as not supported; `sinkId`/`setSinkId()`/`sinkchange` Chrome 110 only; `outputLatency` Chrome 102, Firefox 70, Safari 18.4; `getOutputTimestamp()` Chrome 57, Firefox 70, Safari 14.1; `playbackStats` Chrome 146 only; `error` event Chrome 128 only. ([MDN BCD AudioContext.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/AudioContext.json))
- itch.io "Click to Play" is on by default; with auto-start "audio may be muted on some browsers". ([itch.io HTML5 docs](https://itch.io/docs/creators/html5))
- LOCAL: the game uses `StereoPannerNode` (12 references) and no `PannerNode`. ([LOCAL grep of dark_raiders.html](file:///C:/claudecode/dark%20raiders/dark_raiders.html))

### Inferences
- For top-down, stereo pan from screen-space x plus gain falloff by distance (and a cheap low-pass for occluded sounds) gives most of the spatial value at a fraction of HRTF cost; the game's current StereoPanner approach is the right one.
- Cap simultaneous voices per sound type (for example 4 to 6 gunshots of one kind, oldest stolen) and globally, and put one `DynamicsCompressorNode` as a limiter on the master bus to stop clipping in big fights.
- On Chrome 146+, `playbackStats` can feed underrun counts into the flight recorder; feature-detect it.

### Gaps
- No 2025 or 2026 measured number for how many simultaneous voices current Chrome or Firefox sustain before underruns.
- No current source on Firefox `latencyHint` beyond BCD saying unsupported (may be a BCD data gap).

## 6. Saving progress on itch.io: localStorage, IndexedDB, partitioning, eviction

### Takeaway
All itch.io HTML5 games are served from one shared CDN origin (html-classic.itch.zone), each upload in its own sub-directory, inside a cross-origin iframe. Origin-scoped storage therefore survives new uploads but is shared with every other itch HTML5 game the player has run (one 5 MiB localStorage quota, one eviction unit), and since Chrome 115 it is partitioned under the top-level site, so saves on itch.io never meet saves from localhost or any other host. Safari can delete script-written storage after 7 days without interaction.

### Cited Findings
- itch.io: "Your project is hosted on a subdirectory on our HTML CDN"; itch is HTTPS only; the docs say nothing about localStorage, IndexedDB or saves; a single-file project can be uploaded as a bare `.html` file; limits 1,000 files, 500 MB extracted, 200 MB per file, 240-character paths; uncompressed html/js/css/svg/wasm/wav are gzipped automatically. ([itch.io HTML5 docs](https://itch.io/docs/creators/html5))
- itch.io admin (leafo, about 2021): "All HTML5 games are hosted on the same domain, but new uploads are placed new new sub-directories", and it is up to the engine how save data is scoped. ([itch.io forum, how does itch.io store save data](https://itch.io/t/1171960/how-does-itchio-store-save-data))
- Developers report both outcomes on updates: one thread says localStorage "is lost at every update" because the path changes, others report data kept. ([itch.io forum, lost at every update](https://itch.io/t/2346400/html5-local-storage-is-lost-at-every-update))
- A developer saw localStorage vanish about every half hour on html-classic.itch.zone; it was traced to Brave settings plus the iframe, and did not happen in Edge. ([itch.io forum, randomly losing localstorage](https://itch.io/t/5464689/web-browser-game-randomly-losing-localstorage-data))
- MDN (modified Jan 5, 2026): quotas and eviction apply per origin (scheme + host + port) even when it hosts several sites in sub-paths; browsers may further partition an origin's data inside third-party iframes; localStorage is 5 MiB per origin (the page also says 10 MiB total; not reconciled); over-quota writes throw `QuotaExceededError`; eviction deletes all of an origin's data together; best-effort data is evicted LRU under storage pressure; persistent data only by the user. ([MDN Storage quotas and eviction criteria](https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria))
- MDN: `navigator.storage.persist()` shows a prompt in Firefox; Chrome, Edge and Safari approve or deny silently based on the user's interaction with the site. IndexedDB best-effort quota: Chromium 60% of disk; Firefox the smaller of 10% of disk or 10 GiB per site group; Safari about 60% per origin in browser apps, and cross-origin frames get about 1/10 of their parent's quota. ([MDN Storage quotas](https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria))
- Safari proactive eviction: with cross-site tracking prevention on, an origin with no click or tap in the last seven days of browser use has its script-created data deleted. ([MDN Storage quotas](https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria))
- Chrome storage partitioning: enabled for all users on Chrome 115+; third-party storage including localStorage is keyed by the top-level site plus the origin (with an "ancestor bit" for nested cross-site frames); the unpartitioning deprecation trial expired September 3, 2024; the Storage Access API was extended to non-cookie storage in an origin trial from Chrome 120. ([Chrome Storage Partitioning](https://developer.chrome.com/docs/privacy-sandbox/storage-partitioning); [deprecation trial](https://developer.chrome.com/blog/storage-partitioning-deprecation-trial))
- LOCAL: the game writes `localStorage.setItem` at 29 sites, references `indexedDB` once, and never calls `navigator.storage.persist()`. ([LOCAL grep of dark_raiders.html](file:///C:/claudecode/dark%20raiders/dark_raiders.html))

### Inferences
- Because every itch HTML5 game shares html-classic.itch.zone, another game that calls `localStorage.clear()` or fills the 5 MiB quota can wipe or block the `salvagerun:profile` save on that player's browser. Mirroring the profile into IndexedDB (separate, much larger quota; still same-origin eviction) and handling `QuotaExceededError` without crashing removes most of that risk.
- Saves will survive re-uploads (same origin, and the key does not include the path), but the itch save will be a different save from the one on his localhost:8802 builds, and from the direct html-classic URL, because of partitioning by top-level site. Friends on the private link start fresh.
- A "save code" or export/import file on the profile screen is the only defence against browser-level wipes (Safari 7-day, Brave settings, cleared site data).
- Write safely: write the new profile to a second key, read it back and verify, then swap, so a crash mid-write never leaves a half profile; keep the previous good copy.
- Call `navigator.storage.persist()` after a user gesture (Chromium and Safari decide silently; Firefox prompts, so do it from a settings toggle there).

### Gaps
- Not verified whether `itch.io` is on the Public Suffix List, which decides whether the partition key is `itch.io` or `dbmosser.itch.io`.
- No official itch.io document on save data behaviour across uploads or on the iframe's storage access was found.
- No data on how often players actually lose itch.io saves.

## 7. Robustness: context loss, long sessions, automated testing, error reporting

### Takeaway
2D canvas context loss is now observable in Chrome 99+ and Firefox 125+ (`contextlost`/`contextrestored`), not in Safari. Headless Chrome renders with SwiftShader (CPU) by default, so headless runs are good for logic and crash testing but say nothing about GPU frame cost; perf checks need headed Chrome on a real GPU.

### Cited Findings
- `contextlost` and `contextrestored` events: Chrome 99, Firefox 125, Safari not supported; `isContextLost()` same versions. Chrome's post gives running out of GPU memory as a cause and says the events let the page redraw. ([MDN BCD HTMLCanvasElement.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/HTMLCanvasElement.json); [Chrome Canvas2D post](https://developer.chrome.com/blog/canvas2d))
- `AudioContext` `error` event: Chrome 128 only. ([MDN BCD AudioContext.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/AudioContext.json))
- LoAF gives in-the-field attribution of long frames to scripts and functions (`sourceURL`, `sourceFunctionName`, `sourceCharPosition`) in Chrome 123+. ([Chrome for Developers, LoAF](https://developer.chrome.com/docs/web-platform/long-animation-frames))
- Headless rendering (secondary sources): headless Chromium uses SwiftShader by default; `--enable-gpu` hands selection back to the normal driver logic but does not guarantee hardware acceleration; Puppeteer's docs reportedly say chrome-headless-shell needs `--enable-gpu`; explicit software GL is `--use-gl=angle --use-angle=swiftshader-webgl --enable-unsafe-swiftshader`; automatic WebGL fallback to SwiftShader is deprecated; Playwright passes `--enable-unsafe-swiftshader`; headed Chrome under xvfb uses the GPU pipeline. ([Chromium headless_mode_switches.h](https://chromium.googlesource.com/chromium/src/+/main/chrome/browser/headless/headless_mode_switches.h); [dev.to Playwright GPU](https://dev.to/perrocontodo/run-playwright-tests-with-hardware-acceleration-on-a-gpu-enabled-ec2-instance-with-docker-support-4j2); [Dave Snider, GPU tests](https://backiee.wasmer.app/https_davesnider_com/posts/gputests))
- Cross-origin isolation on itch.io: an itch admin said the embedding page must also send COOP and COEP headers for SharedArrayBuffer to work inside an embed, and recommended opening the game in a new tab when the host cannot. ([itch.io forum, SharedArrayBuffer in iframe](https://itch.io/t/3288882/cant-embed-into-iframe-sharedarraybuffer))
- LOCAL: the game already listens for `contextlost` (3 references), `visibilitychange` (5) and `onerror`/`unhandledrejection` (8). ([LOCAL grep of dark_raiders.html](file:///C:/claudecode/dark%20raiders/dark_raiders.html))

### Inferences
- On `contextlost`, every cached offscreen canvas (light sprites, baked walls, atlases) is gone too, so the cache layer needs one "rebuild all" function that the restore handler and resolution changes both call.
- Long sessions: offscreen canvases created per effect and never released (or kept in growing maps) are the usual Canvas 2D leak; a debug overlay counting live offscreen canvases and their pixel total, sampled in the flight recorder, would show growth over a 2-hour party session.
- Keep the existing headless crash robots on SwiftShader for logic; any performance gate (for example a 4K frame-time budget) must run headed on his GPU, ideally on the spare PC.

### Gaps
- No 2025 or 2026 source found on Chrome's current GPU-memory policy for background or hibernated 2D canvases, or how often players hit 2D context loss.
- `performance.measureUserAgentSpecificMemory()` requirements and 2025 status were not researched (it needs cross-origin isolation, which itch embeds make hard); treat as unverified.
- No sourced 2025 or 2026 guidance found on error-reporting services or the Reporting API for itch.io games.

## 8. 2D lighting, shadows and fog of war that stay fast in Canvas 2D

### Takeaway
The proven Canvas 2D pattern is a low-resolution light map: clear it to ambient darkness, add lights with additive compositing, cut shadows with visibility polygons computed on the CPU, then multiply the light map over the scene. Fog of war is a separate low-resolution mask updated only when the explored area changes. All of it maps cleanly onto the game's sim/render split: visibility is computed on flat coordinates, drawn in the render layer.

### Cited Findings
- Red Blob Games 2D visibility (published 2012, updated 2018 and 2020; OLDER but standard): sort wall endpoints by angle and sweep a ray 360 degrees, keeping the nearest wall; the union of the emitted triangles is the visible polygon; intersect it with a circle, gradient or cone for vision; light maps are the union of several lights' visible areas intersected with the player's view; rendered to bitmaps, AND is multiply and OR is clamped add; output is hard-edged, so soft shadows need post-processing; for CPU-bound games, render each wall segment's shadow as a quad (subtractive), or use lower-resolution light bitmaps or 1D shadow maps. ([Red Blob Games, 2D Visibility](https://www.redblobgames.com/articles/visibility/))
- Excalibur.js Canvas 2D lighting: ambient darkness veil, per-light `destination-out` punches, occluder shadows subtracted, then coloured tint passes; warns the overlay is re-uploaded to the GPU every frame. ([Excalibur LightingSystem](https://excaliburjs.com/api/class/LightingSystem))
- An RPG Maker lighting engine uses ambient darkness via MULTIPLY and additive light accumulation via ADD. ([ED5 lighting engine](https://chigoox.itch.io/ed5-lighting-engine))
- Lightmap at 10% width and height still looks acceptable with 99% fewer pixels (Love2D). ([LOVE forums, Luven](https://www.love2d.org/forums/viewtopic.php?p=226009))
- Godot's retro dithered lighting and fog of war is a shader approach (out of scope here, shown only as the GPU-shader equivalent). ([Godot Shaders](https://godotshaders.com/shader/2d-retro-dithered-lighting-fog-of-war/))

### Inferences
- Light sprites: bake each light kind's radial falloff once into a small offscreen canvas (for example 128 or 256 px) and `drawImage` it scaled with `globalCompositeOperation='lighter'`, instead of building `createRadialGradient` objects per light per frame (the game has 59 gradient call sites).
- Light map resolution: build it at 1/4 (or 1/2 on high quality) of the play resolution, then draw it once over the scene with `multiply` and smoothing on; the bilinear upscale also softens hard visibility-polygon edges for free, which replaces blur filters.
- Static lights against static walls can cache their shadowed light sprite until a wall changes (doors, breakables), so only moving lights (muzzle flash, player torch) recompute visibility each frame.
- Fog of war: keep explored state as a tile-resolution canvas (one pixel per tile or per half tile), punch newly seen cells with `destination-out` only on frames where the explored set grows, and draw it scaled up with smoothing for soft edges.
- WebGL/WebGPU would allow per-pixel shader lighting and normal maps (WebGPU is Chrome 113+, Firefox 141 on Windows, Safari 26 per BCD) but are out of scope under the project rules. ([MDN BCD HTMLCanvasElement.json](https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/HTMLCanvasElement.json))

### Gaps
- No 2025 or 2026 shipped browser game with a published Canvas 2D lighting or fog benchmark was found.
- No measured comparison of `lighter` vs `multiply` vs `destination-out` composite costs in current browsers was found.

## 9. Ranked: biggest wins for a 5 MB single-file Canvas 2D game

### Takeaway
Ranked by expected gain for PILLAGERS per unit of risk, using the cited browser facts and the LOCAL grep of the game file: (1) bake gradients, shadows and blurs into cached sprites; (2) move lighting and fog to low-resolution layers; (3) harden saves for the shared itch.io origin; (4) check pad input in the itch iframe and with two windows; (5) a frame loop that copes with throttling, plus long-frame telemetry; (6) a dynamic resolution controller driven by wall-clock frame time. OffscreenCanvas workers, layers and HTML-in-Canvas rank last.

### Cited Findings
- Blur and shadow costs are the clearest measured browser gaps (Firefox ctx.filter blur 28x slower than Chrome for repeated calls; 9.5 s vs 2.7 s when the value changes). ([Bugzilla 1978851](https://bugzilla.mozilla.org/show_bug.cgi?id=1978851))
- Light map resolution is a 99% pixel lever with little visible loss. ([LOVE forums, Luven](https://www.love2d.org/forums/viewtopic.php?p=226009))
- itch.io serves all HTML5 games from one domain in per-upload sub-directories, and storage is per origin and partitioned per top-level site since Chrome 115. ([itch.io forum](https://itch.io/t/1171960/how-does-itchio-store-save-data); [MDN Storage quotas](https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria); [Chrome Storage Partitioning](https://developer.chrome.com/docs/privacy-sandbox/storage-partitioning))
- Firefox requires explicit iframe permission for gamepads; Chrome defaults to allowing it; some OS input APIs require focus. ([Mozilla Hacks](https://hacks.mozilla.org/2020/07/securing-gamepad-api/); [MDN gamepad policy](https://developer.mozilla.org/docs/Web/HTTP/Headers/Feature-Policy/gamepad); [W3C public-webapps, Sept 2024](https://lists.w3.org/Archives/Public/public-webapps-github/2024Sep/0476.html))
- Cross-origin iframes off-screen are throttled; occluded windows stop rendering; LoAF exists in Chrome 123+. ([Chromium review 2333653002](https://codereview.chromium.org/2333653002); [Chromium blog occlusion](https://blog.chromium.org/2021/12/chrome-windows-performance-improvements-native-window-occlusion.html); [LoAF](https://developer.chrome.com/docs/web-platform/long-animation-frames))

### Inferences
1. **Bake and cache the expensive draws (largest frame-time win, low risk).** Replace per-frame `createRadialGradient` (59 sites), `shadowBlur` (15 sites, notably text with shadowBlur 3 to 9) and the full-screen `ctx.filter` blur and hue-rotate passes with sprites made once (per resolution step) and drawn with `drawImage`; quantize any blur radius that must vary. Expect the biggest gains at 4K and on Firefox.
2. **Low-resolution light map and incremental fog (large GPU win, medium risk, visible: he should judge the look).** Light map at 1/4 to 1/2 scale with baked light sprites and `lighter`, multiplied over the scene once; fog mask at tile resolution, updated only when it changes.
3. **Save hardening for itch.io (protects his players' progress, low risk).** Mirror the profile to IndexedDB, verify-then-swap writes with a kept backup, catch `QuotaExceededError`, call `navigator.storage.persist()`, and add a save export/import. Note in release notes that the itch save is separate from local builds.
4. **Pad checks on itch.io and with two windows (party and release risk, cheap to test).** Private itch upload tested in Firefox and Chrome with an Xbox pad; two windows side by side with one focused, checking whether the unfocused window still reads its pad. If not, the one-window two-player path is the default for the party.
5. **Frame loop robustness and telemetry (low risk).** Clamp large deltas after throttling or visibility changes; estimate refresh as the median rAF interval and re-measure on screen change; record LoAF entries and frame-time histograms into the flight recorder.
6. **Dynamic resolution controller (medium risk).** Drive it from rAF wall-clock delta vs measured JS time, fixed scale steps with hysteresis, and scale lighting and fog layers separately from sprites and HUD.
7. **Trigger rumble on Chrome/Edge 126+ (small, nice for the party).** Feature-detect `effects.includes('trigger-rumble')` with dual-rumble fallback.
8. **Audio voice caps and a master limiter (small, robustness in big fights).** Keep StereoPanner; add per-sound voice limits, a compressor on the master bus, and `playbackStats` logging where it exists.
9. **Measure the CSS SVG gamma filter on the 4K canvas (unknown cost).** If brightness away from 1 costs frames, fold gamma into the light pass.
10. **Not now:** OffscreenCanvas in a worker (big refactor of a single-file renderer and its input path, gain uncertain since raster is already off the main thread in Chromium), `desynchronized` (Chrome/Windows only, can tear), Canvas layers and HTML-in-Canvas (not shipped as stable). WebGL/WebGPU lighting would be the largest possible visual upgrade but is out of scope by project rule.

### Gaps
- None of the rankings above was measured on PILLAGERS itself; the order is an inference from browser data plus the grep counts, and the first two items should be confirmed with frame-time captures at 1080p and 4K on his PC before and after.
