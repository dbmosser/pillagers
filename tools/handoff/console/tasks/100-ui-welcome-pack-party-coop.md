# 100-ui-welcome-pack-party-coop : two Undercroft cards the critic still scores 2 reach 3 (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 10:50): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). The
newly failing checks are all handled (87r, 97, 98), the robots found no problems and no checker lead is confirmed, so this is the
next known work: screens the critic scored under their target. 99 took the two mainframe screens to 3 the same way.

His answers: career screens get polished too, not only party screens (56); restyling an existing screen needs no mockups (53);
the style guide beats the judge's taste and his taste beats both (54, 22); a card is centred with an X (Q43). Finish line (3.51 a):
critic 3 for these (not raid screens). No queued, failed or cut job lists these two screens.

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json):
- 02-welcome-pack (target 3). Judged 10-18 13:00 at 2: "still has an explaining paragraph, rarity-coloured names, a heavy 'Take the
  pack' button and a bare close button with no X". That verdict is six days old (cards got the X since): start from a fresh picture.
- 07-party-coop (target 3). Judged 10-20 04:13 at 2: "a small column of text floating in a nearly empty 90 percent card, with no
  clear main action and no focus state".
Start with fresh pictures and a fresh critic score on HEAD; if a screen already meets its target, record it and stop on that screen.

Rules:
- Read notes/ui/style-guide.md and shared-style.md first. All player text lower case, short, no explaining sentence, $ for money
  and SP for score. Log any reworded or removed line with its reason in notes/ui/changes.md (Q8).
- Layout and look only: do not change what the pack gives or how two players join. No new controls (one control per job), no
  party extras (his 10-19 ruling: the party is the demo, no launcher, no party mode).
- Rendering and HUD only: no change to the simulation, saves or the storage key.
- Work it through pad focus too (a visible focus ring on the main action), since couch play is career (his note on 76).

Checks (each must FAIL on the old build): measured layout facts you fixed (for example no explaining sentence on the welcome card,
one primary action drawn in lime with a focus ring, the party card's content filling its card).
Pictures: camera-recipes.json with both screens at 1080p, then the critic.
TASK DONE when each screen reaches 3 from the critic (never your own grade) or is stopped at 6 tries with its best two versions
noted; TASK PARTIAL with what is left.
