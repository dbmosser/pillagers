# 99-ui-mainframe-racks-rewards : the two mainframe screens the critic still scores 2 reach 3 (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 09:55): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). The
newly failing checks are in 87r, the robots found no problems and the local AI's newest lead (drawHubBagCard with no gun) is false
(hubBagState falls back to fists), so this is the next known work: screens the critic scored under their target.

His answers: career screens get polished too, not only party screens (56); restyling an existing screen needs no mockups (53);
the style guide beats the judge's taste and his taste beats both (54, 22). Finish line (3.51 a): critic 3 for these (not raid screens).
No queued, failed or cut job lists these two screens (12-mainframe-contracts, the third mainframe tab, already passes at 3).

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json):
- 14-mainframe-racks (target 3). Judged 10-20 03:56 at 2: "a thin strip of five near-identical flat buttons and grey paragraphs in a
  mostly empty card, with no focal point, no hero and no real primary action".
- 13-mainframe-rewards (target 3). Judged 10-20 06:08 at 2: "a flat wall of identical rows with an empty xp bar, no hero element, no
  rarity or reward-type cues, and a toast sitting on the card's bottom border".
Both verdicts are four days old and cards changed since. Start with fresh pictures and a fresh critic score on HEAD; if a screen
already meets its target, record it and stop on that screen.

Rules:
- Read notes/ui/style-guide.md and shared-style.md first. All player text lower case, short, no explaining sentence, $ for money
  and SP for score. Log any reworded or removed line with its reason in notes/ui/changes.md (Q8).
- Layout and look only: do not change what a rack or reward does, costs or gives. No new controls (one control per job).
- Rendering and HUD only: no change to the simulation, saves or the storage key.
- Work it through pad focus too (a visible focus ring on the focused row), since couch play is career (his note on 76).

Checks (each must FAIL on the old build): measured layout facts you fixed (for example the toast clear of the card's border, one
primary action drawn in lime, the rewards rows carrying a type cue).
Pictures: camera-recipes.json with both screens at 1080p, then the critic.
TASK DONE when each screen reaches 3 from the critic (never your own grade) or is stopped at 6 tries with its best two versions
noted; TASK PARTIAL with what is left.
