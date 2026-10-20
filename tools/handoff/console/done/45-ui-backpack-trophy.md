# 45-ui-backpack-trophy : polish two career screens no job owns (coordinator 2026-10-20)
effort: medium

His answers: career screens get polished too, not only party screens (56); restyling an existing screen needs no mockups (53);
the style guide beats the judge's taste and his taste beats both (54, 22). Finish line (3.51 a): critic 4 for raid screens, 3 for
the rest. No queued, failed or cut job lists these two screens.

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json):
- 23-raid-backpack-open (a raid screen: target 4). Last judged 10-18 at 2: "a wide, mostly empty dark slab with tiny, low
  contrast text and three lonely item slots ... looks like a debug panel".
- 66-trophy-case (target 3). Last judged 10-18 at 2: "two thirds empty, the grid orphans a single card on row two, nothing shows
  focus, and the header stats and toast are crude".
Both verdicts are two days old and many cards changed since (v31.02 windows with an x, v31.41, v32.50). Start with fresh pictures
and a fresh critic score on HEAD; if a screen already meets its target, record it and stop on that screen.

Rules:
- Read notes/ui/style-guide.md and shared-style.md first. All player text lower case, short, no explaining sentence, $ for money
  and SP for score. Log any reworded or removed line with its reason in notes/ui/changes.md (Q8).
- Vetoes (RULES.md): no bag limit and no weight, ever; no HEAVY / LOADED / LIGHT BACKPACK line; equipping a gun says nothing
  about the rest of the backpack. Do not change what the backpack holds or how items move: layout and look only.
- Rendering and HUD only: no change to the simulation, saves or the storage key.
- Work it through pad focus too (a visible focus ring on the trophy cards), since couch play is career (his note on 76).

Checks (each must FAIL on the old build): measured layout facts you fixed (for example no orphan card on the trophy grid at
1080p, a focus ring box on the focused trophy, backpack text at or above the style guide's minimum size).
Pictures: camera-recipes.json with both screens at 1080p, then the critic.
TASK DONE when each screen reaches its target from the critic (never your own grade); TASK PARTIAL with what is left.

## RE-QUEUED 10-20 07:10 (coordinator): backpack only, with his answer
HIS ANSWER (10-20 07:10) to the scrim question: "Small to medium". The raid backpack stays a panel over the live world: no scrim, no
full-screen card, no x card. It may grow from small to a medium size (about a third to half of the screen width at 1080p) if
that makes the items easier to read. His taste beats the critic (54): ignore the critic's ask for the 90 percent card.
The trophy case is done (v32.77, critic 3). Do not touch it.
Start from the better of v32.79 (critic 3) and v32.81 (critic 2), per his rule 28, and say which you kept.
Vetoes stand: no empty slot outlines that read as a bag limit, no weight, no HEAVY / LOADED / LIGHT line.
Finish line for this round: the backpack is small to medium as he said, critic 3 or better. At most 2 runs, then keep the best.

## CLOSED 10-20 07:30 (coordinator)
Done by his answer "small to medium": v32.81 kept, the raid backpack is a live panel about 43 percent of the screen width at 1080p,
no scrim, no card. The critic swings 2 to 3 and its remaining asks are vetoed or ruled out by him (54: his taste beats the critic).
Trophy case done in v32.77 (critic 3).
