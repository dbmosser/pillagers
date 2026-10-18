# b-30-ui-hud notes (latest run, 2026-10-18 evening)
- Guide READY. Shots: notes/shots/b-30j-before (all 15, v31.4x). Critic (before): 24 = 2, 36 = 2 (new). 20, 34, 78 critic runs done earlier in the run (scores not kept; all around 2).
- SHIPPED v31.44 cw-lowhp (pulsing red outline on hp bar under 25 percent), v31.47 cw-lowhp2 (3px, alpha floor 0.56, stamina bar dims at low hp). Critic on 36 after: still 2, "same"; it says the hp bar has no red fill (it does, 54px, but the label sits on it) and wants hp text above the bar, a screen-edge vignette, and the stamina is now faint (P2: raise back to ~0.6 alpha if it matters).
- Repeated critic findings, NOT done (belong to 02 or cw-trcol or need a ruling): 
  * "the long dock cache" landmark label drawn under the stash row, clipped (top-right block: waits on cw-trcol).
  * key legend card at bottom centre is clutter: wants auto-hide after ~30s or collapse to "f1 keys". Not done: needs a check of the legend auto-fade code (legend fade exists in 02 notes?) and old checks.
  * 'run info' / 'run goals' two titles (check 27.42 needs RUN GOALS).
  * capital I in "run Info": the font draws a lowercase i as a tall I-like glyph in this face; ncFix lowercases everything, not a code bug.
  * toast duplicates (codex entry shown top centre and bottom left); "contract item nearby" explaining sentence on toast. NEXT candidate: one codex toast only.
  * hotbar: dim empty slots to 40 percent, no silhouettes; prompt 'scav pistol fire use' 12px -> 16px. NEXT candidate.
  * ammo card: 'b / i backpack' 24px -> 16px tx-2. 02 owns (cw-cardhint).
- RUN (latest): no ship. The uishots camera and critic.mjs are REFUSED for this run's command list, so no new pictures or scores were possible. Re-read the code: hotbar empty slots draw a class ghost (cw gunghost, his order v27.xx), so "no silhouettes" would reverse his order: skipped. Feed detail over 4 words is already dropped (cw-feedcalm). Stamina 0.45 alpha under 25 percent hp is deliberate (cw-lowhp2).
- Remaining for a run that has the camera: re-shoot the 15 screens, critic each, fix P0/P1 not on 02's or cw-trcol's list.
- RUN (k, v31.5x): uishots and critic REFUSED again (preflight.sh and shipq work). SHIPPED v31.51 cw-codexfeed (codex note goes to feed only via feedSay, no top-lane duplicate) and v31.53 cw-beltcap (belt caption 13 -> 15.6px). Hotbar empty-slot ghosts are his order (gunghost), left alone. 'contract item nearby' sub is 5 words so the feed already drops it; the top lane shows it, his career9 wording, left. Still needs a run WITH the camera: re-shoot 15 screens + critic.
- (older) Next run: do the toast dedupe and the hotbar empty-slot dim, then shoot 15 screens and critic each.
