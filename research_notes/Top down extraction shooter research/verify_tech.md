# Fact check: browser_canvas_tech.md

Checked 2026-10-25 by web search and web fetch only (no browser pane). Ten claims the conclusions and the section 9 ranking lean on most. Verdicts: confirmed (a fetched source supports it), corrected (right fact and source given), unverified (no support found).

Bottom line: 7 confirmed, 3 corrected. The biggest correction is the gamepad one: Firefox no longer needs `allow="gamepad"` on a cross-origin iframe (its default allowlist was changed to `*` after the `self` default broke sites), so ranking item 4's "Firefox players may get no pad input on itch" risk is much smaller than the notes say. The storage trial dates and the itch domain detail are minor fixes that do not change the ranking.

## 1. Skia Graphite launch (sections 1 and 3)
Claim: Graphite launched in Chrome on Apple Silicon Macs only, announced July 8, 2025, with almost 15% higher MotionMark 1.3 on a MacBook Pro M3 (the jump between M133 and M134); Windows Chrome still runs Ganesh over ANGLE/D3D.

Verdict: **confirmed.** The Google blog post is dated Jul 08, 2025, says Graphite launched "in Chrome on Apple Silicon Macs", gives "almost 15%" MotionMark 1.3 on a MacBook Pro M3 with the chart placing the gain between M133 and M134, and describes the older path as GPU rasterization on GL "via ANGLE on Windows D3D9/11". Adversarial check: on Dec 11, 2025 Skia maintainer Michael Ludwig wrote Graphite "is enabled by default on Chrome for Mac" and "is making progress for Windows (primarily tested with Dawn's D3D11 backend)". No 2026 source found saying Windows is on by default.
Sources: https://blog.google/chromium/introducing-skia-graphite-chromes/ ; https://groups.google.com/g/skia-discuss/c/Pd92csb5o4o/m/QlPj80PqAQAJ

## 2. Firefox ctx.filter blur cost (sections 1 and 9, ranking item 1)
Claim: Bugzilla 1978851 reports applying a ctx.filter blur N times is 28x slower in Firefox than Chrome; with the blur value changing each iteration, 9.5 s in Firefox vs 2.7 s in Chrome; Chrome has a fast path for re-setting the same filter.

Verdict: **confirmed.** Title: "Testcase applying a ctx.filter blur N times on canvas is 28x slower in Firefox compared to Chrome". Comment 0 (N=5,000,000): Chrome 330 ms, Firefox 9 s (about 27x). Comment 1 (Emilio Cobos Alvarez): Chrome has "a fast path for setting the same filter over and over". Comment 2, blur radius `i * 0.0001` px per iteration: Firefox 9.5 s, Chrome 2.7 s (about 3.5x). Status NEW. Note: the 28x figure is the same-filter no-op case; the realistic changing-radius case is 3.5x, which the notes' inference ("3.5x to 28x") already reflects. The notes' "updated about two months ago" is stale (updated within the last day).
Source: https://bugzilla.mozilla.org/show_bug.cgi?id=1978851

## 3. itch.io hosts all HTML5 games on one shared origin (section 6, ranking item 3)
Claim: all itch.io HTML5 games are served from one shared CDN origin (html-classic.itch.zone), each upload in its own sub-directory; leafo: "All HTML5 games are hosted on the same domain, but new uploads are placed new new sub-directories".

Verdict: **corrected (minor).** The leafo quote is exact (thread created Jan 26, 2021), and itch's HTML5 docs say "Your project is hosted on a subdirectory on our HTML CDN". But the 2021 quote predates itch's 2023 CDN move: leafo's Aug 29, 2023 notice says the default domain became `html-classic.itch.zone` (fully migrated "as of November 22nd"), the old `v6p9d9t4.ssl.hwcdn.net` was retired, and `html.itch.zone` exists as an opt-in second domain. So "one shared origin" is true for projects on the default domain, not for every itch game. The same notice confirms localStorage is "tied to the domain of the executing JavaScript code". Other itch threads confirm games on the shared domain see each other's localStorage keys.
Sources: https://itch.io/t/1171960/how-does-itchio-store-save-data ; https://itch.io/post/8952630/view-in-topic ; https://itch.io/docs/creators/html5 ; https://itch.io/t/1158456/html5-local-storage-seems-to-be-shared-between-multiple-games

## 4. Chrome storage partitioning (section 6)
Claim: storage partitioning is on for all users in Chrome 115+, keyed by top-level site plus origin (with an ancestor bit); the unpartitioning deprecation trial expired September 3, 2024; Storage Access API extended to non-cookie storage in an origin trial from Chrome 120.

Verdict: **corrected.** Confirmed: "The feature has been enabled for all users on Chrome 115 and later", Local Storage and Session Storage are partitioned, key is origin plus top-level site with an ancestor bit for cross-site chains. Wrong: September 3, 2024 was only when the first trial (Chrome 113 to 126) ended for users on Chrome 111 to 126. It was renewed as DisableThirdPartyStoragePartitioning2 for Chrome 127 to 132, then as DisableThirdPartyStoragePartitioning3 for Chrome 133 to 138 (renewal only for sites already in trial 2). Also, Storage Access API non-cookie storage was not just an origin trial: the trial started in Chrome 120 and the feature shipped in Chrome 125. Neither change affects itch.io saves, since itch would have to opt in.
Sources: https://privacysandbox.google.com/3pcd/storage-partitioning ; https://privacysandbox.google.com/blog/storage-partitioning-deprecation-trial-renewal (June 25, 2024) ; https://privacysandbox.google.com/blog/storage-partitioning-deprecation-trial-second-renewal (updated 2025-01-06)

## 5. MDN quotas and eviction (section 6)
Claim: quotas and eviction apply per origin even across sub-paths; localStorage is 5 MiB per origin (page also says 10 MiB total, "not reconciled"); eviction deletes all of an origin's data together; Safari deletes script-created data after seven days without a click or tap when tracking prevention is on; page modified Jan 5, 2026.

Verdict: **confirmed.** All quoted as stated. The 10 MiB is reconciled on the page itself: "Browsers can store up to 5 MiB of local storage, and 5 MiB of session storage per origin", and Web Storage as a whole "is limited to 10 MiB of data maximum". Eviction: "all of its data, not parts of it, is deleted at the same time". Last modified Jan 5, 2026.
Source: https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria

## 6. Chrome native window occlusion on Windows (section 2)
Claim: shipped Chrome 86 (October 2020); occluded windows stop rendering and get background-tab JS throttling; recalculated at most every 16 ms; about 20% of windows fully covered; 20.4% fewer renderer frames and 3.1% less GPU memory.

Verdict: **confirmed.** Chromium blog (Dec 9, 2021): "rolled out to 100% of Chrome Windows users in October 2020 as part of the M86 release", "nearly 20% of Chrome windows are completely covered", "3.1% reduction in GPU memory usage", "20.4% fewer renderer frames drawn overall". Chromium docs: when occluded "rendering stops, and js is throttled", with a 16 ms recalculation timer.
Sources: https://blog.chromium.org/2021/12/chrome-windows-performance-improvements-native-window-occlusion.html ; https://chromium.googlesource.com/chromium/src/+/master/docs/windows_native_window_occlusion_tracking.md

## 7. Long Animation Frames API (sections 2, 7 and ranking item 5)
Claim: LoAF shipped Chrome 123 after an origin trial in 116 to 122; a long frame is a rendering update delayed beyond 50 ms; `duration` excludes presentation time; script attribution for scripts over 5 ms, none for cross-origin iframes or workers.

Verdict: **confirmed.** All five points are stated on the Chrome for Developers LoAF page.
Source: https://developer.chrome.com/docs/web-platform/long-animation-frames

## 8. Gamepad permissions policy in iframes (sections 4 and 9, ranking item 4)
Claim: Firefox 82 requires third-party iframes to be explicitly granted gamepad access by the host page; Chrome supports the policy from 86, only via the iframe `allow` attribute, with a default allowlist of `*` instead of the spec's `self`; the API requires a secure context. Inference: Firefox players on itch may get no pad input if itch's iframe lacks `allow="gamepad"`.

Verdict: **corrected.** Mozilla Hacks (July 1, 2020) did announce the Firefox 82 rule. But the Chromium "Intent to Ship: Restrict Gamepad usage" (Apr 19, 2022) says "Firefox initially rolled out this change with the default allowlist set to 'self' which broke some sites" and "the default allowlist was changed to '*' (all)". The W3C spec now says "Its default allowlist is *" (PR #156, Feb 2022, changed it from `self`), and the WPT test run in Firefox's tree checks that gamepad is allowed cross-origin by default. So the `*` default is now the spec, not a Chrome deviation, and a cross-origin iframe with no `allow` attribute gets pads in Firefox too. Current BCD lists the `gamepad` Permissions-Policy header as Chrome 103 (not 86), Firefox and Safari not supported (Firefox handles only the iframe `allow` side). The secure-context rule is also outdated: BCD PR #29617 (merged May 6, 2026) records Firefox 125 and Chrome dropping the requirement (itch is HTTPS, so this does not matter there).
Sources: https://groups.google.com/a/chromium.org/g/blink-dev/c/B1QUuICApvc/m/RRxZLqG4HQAJ ; https://w3c.github.io/gamepad/ ; https://lists.w3.org/Archives/Public/public-webapps-github/2022Feb/0412.html ; https://raw.githubusercontent.com/mdn/browser-compat-data/main/http/headers/Permissions-Policy.json ; https://github.com/mdn/browser-compat-data/pull/29617 ; https://hacks.mozilla.org/2020/07/securing-gamepad-api/

## 9. Matt Reynolds on gamepad focus vs visibility (section 4, ranking item 4)
Claim: Matt Reynolds (Chromium, Sept 2024): "Allowing gamepad access from non-foreground windows is intentional"; "The Chromium implementation requires visibility before events are dispatched"; "On some platforms the system APIs we use to access gamepad inputs have focus requirements that prevent background access"; behaviour "can differ between different gamepads on the same system".

Verdict: **confirmed.** All four quotes are verbatim in his Sept 27, 2024 reply on w3c/gamepad issue 215. Full context of the first: "...is intentional, but perhaps we should check that the page is visible?" The last is from "Chromium uses a variety of APIs to access gamepads so sometimes this behavior can differ between different gamepads on the same system."
Source: https://lists.w3.org/Archives/Public/public-webapps-github/2024Sep/0476.html

## 10. Rumble support (sections 4 and 9, ranking item 7)
Claim: `vibrationActuator` / `playEffect()` Chrome 68, Safari 16.4, not Firefox; `trigger-rumble` and `leftTrigger`/`rightTrigger` Chrome 126 (Edge mirrors), experimental, not Firefox or Safari; `pulse()` Firefox 55 only.

Verdict: **confirmed.** Current BCD matches: vibrationActuator Chrome 68, Safari 16.4, Firefox false; playEffect Chrome 68, Edge 15, Safari 16.4, Firefox false; effects, trigger-rumble and trigger params Chrome 126, experimental, Edge mirror, Firefox and Safari false. Small fix: `pulse()` and `hapticActuators` were also in old Edge 15 to 79, not Firefox only. Adversarial check: Firefox bug 680289 ("Rumble Effect support for Gamepad API", with a Windows XInput dual-rumble patch) is ASSIGNED, not fixed, flagged behind-pref; Linux follow-up bug 2048366 is NEW. So Firefox still has no default rumble as of today, but it may arrive.
Sources: https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/Gamepad.json ; https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/GamepadHapticActuator.json ; https://bugzilla.mozilla.org/show_bug.cgi?id=680289 ; https://bugzilla.mozilla.org/show_bug.cgi?id=2048366

## What this changes in the ranking
- Item 4 (pad checks on itch): the Firefox iframe-permission risk is mostly gone. The real remaining risk is two windows on one PC (Matt Reynolds' focus point), which still needs the hands-on test.
- Item 3 (save hardening): unchanged. Shared-domain localStorage is confirmed for the default itch domain.
- Item 1 (bake blurs): unchanged, but the realistic Firefox gap for a changing blur radius is about 3.5x, not 28x.
