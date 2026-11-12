
--- codex run 2026-11-11 19:41 ---
2026-11-11 o-h01b-hardcore-toggle-is-a-pill, first run, base v37.69 / c5a5b12e3.
LOCAL: no linked review.
Root cause is the later #root #title #slotpanel button rule, not missing #root ancestry. Its min-height and important radius override the existing shared pill. One selector now excludes .ui-toggle, so the existing shared 40x20, 10px radius, 16px knob and colours apply. Label already uses inline-flex align-items:center. Graveyard is untouched.
Prepared cw-cx-hardcorepill. Anchor generated successfully against the private game file. No game, fixture, version or repository files edited.
Regression check measures actual computed title dimensions/radius and knob geometry, off/on colours against the shared class inside Settings, unscaled layout boxes (offsetWidth/offsetHeight, avoiding different menu zoom), vertical centring, real onclick aria/class and 20px knob translation, second-click off, player 2 hiding and a legacy normal save through applyLoadedProfile. It disables only the test transition to measure the final knob transform synchronously. All temporary elements, storage and saved roles/profile are restored.
Task discrepancy: the current Settings page has no live .ui-toggle element. Its actual controls are wide cycle buttons. The check therefore creates a temporary shared-class reference inside that panel and removes it in finally; the comparison photograph shows actual settings unchanged. No fake setting is added to the game or photographs.
Recipes reuse hc-title-off, hc-title-on and hc-p2-save-tag from o-h01, with on now exercised by a real click. Added hc-settings-comparison. Lane shoot_recipes already runs -Res 1080,4k. Await preflight, gate, seed 4242 fingerprint, ON HIS PC and pictures/critic. No fixture retarget needed.
Read the PC/owner addendum from C:/claudecode/FNP new 11082026/RULES.md because the older C:/Codex path does not exist here. No PC settings, services, ports or FnP game files touched.


--- codex run 2026-11-12 03:34 ---
2026-11-12 o-h01b-hardcore-toggle-is-a-pill, preflight correction, base v37.69 / 905ef265a.
LOCAL: no linked review.
Remote preflight reached the patched build twice; only exact computed-style length comparisons failed. Chrome resolved the intended pill at 39.9936px by 19.9968px under fractional menu zoom, with a 10px radius. Exact knob lengths failed for the same reason.
Updated the regression to accept less than 0.05 CSS px of rounding for the 40x20 box, 10px radius, 16px knob, 2px offsets and 20px on translation. Pixel units remain required. The original 40px height and small radius still fail. Kept layout-box comparison, colours, centring, real clicks, player 2 hiding and legacy save reload checks. Knob failure now prints the observed geometry.
Updated both title camera expectations with the same 0.05 CSS px tolerance, preventing the camera from rejecting a correctly rounded pill. Picture content and recipe screens are unchanged.
Same cw-cx-hardcorepill key and one-selector game edit. No game or fixture file modified. Local draft generation, unique-anchor validation, JavaScript syntax and rounding-boundary checks pass. Await lane preflight, shipping, seed 4242 fingerprint, ON HIS PC and 1080p/4K pictures with critic.

