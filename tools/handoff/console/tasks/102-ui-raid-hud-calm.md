# 102-ui-raid-hud-calm : the raid HUD uses one type scale, one panel style and one accent, so the raid screens the critic holds at 2 and 3 move toward 4 (coordinator 2026-10-24)
effort: high

Queue (coordinator 10-24 11:50): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). The
newly failing checks are handled, the robots found no problems and no checker lead is confirmed, so this is the next known work:
screens the critic scored under their target. Today 99, 100 and 101 took five non-raid screens from 2 to 3.

Why the HUD and not one more card: every raid screen's verdict names the same cause, the HUD under it.
- 21-raid-hud-calm 2 (target 4), 10-22: "a pile of small, evenly weighted dark boxes with no hero element".
- 37-raid-extracting-countdown 3 (target 4), 10-20: "the rest of the HUD is crowded and uses too many type sizes, panel styles and
  accent colours".
- 61-raid-wheel-open 3 (target 4), 10-20: "still a busy raid HUD with mixed type sizes and a few small, low-contrast labels".
- 19-raid-hud-drop-first-raid 2 (target 4): "crowded with at least seven competing blocks, nothing sets the hero number apart, the
  panel and type styles disagree".
His answers: the HUD redesign is his order (answers 1 to 78, 10-18); finish line critic 4 for raid screens (3.51 a); the style guide
beats the judge's taste and his taste beats both (54, 22); restyling needs no mockups (53).

Rules:
- Read notes/ui/style-guide.md, shared-style.md and hud.md first. Calm it by unifying, not by inventing: one type scale from the
  guide, one panel style, the one lime accent, the guide's greys; health (or the one number the guide names) as the hero.
- Nothing he placed moves without a reason: the top-right column, the reticle, the noise rings, the grenade countdown and every
  HUD element his notes asked for stay, and stay where he put them (his 10-18 feedback notes). No element is removed; text may be
  shortened with a logged reason (Q8, notes/ui/changes.md). The minimap stays off by default (his 10-20 order).
- Rendering and HUD only: no change to the simulation, saves or the storage key. All player text lower case.
- Check P1 and P2 (amber and cyan stay their colours), 1080p and 4K, and the frame cost (the HUD must not add draw calls a frame:
  measure DRS.workMs before and after on a busy raid).
- Ship in small steps (type scale, then panels, then accents), each through preflight.sh and shipq.sh with a watch line in its
  DESIGN.md section: this is feel, so say plainly what he should look at in his next playtest.

Checks (each must FAIL on the old build): measured facts you fixed (for example the number of distinct HUD font sizes and panel
fills in one raid frame at 1080p, the hero number's size against the rest).
Pictures: camera-recipes.json with 21, 19, 37 and 61 at 1080p, then the critic.
TASK DONE when 21-raid-hud-calm reaches 4 from the critic (never your own grade) or the three steps shipped and the critic scores
of all four are written with the best two versions noted; TASK PARTIAL with what is left.
