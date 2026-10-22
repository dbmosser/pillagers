92-hub-backpack-card : the hub backpack window to the centred card with an X (job 69 rescore, 2026-10-20)
Queue (coordinator 10-20 23:58): from job 69 (notes/69-critic-rescore-sweep.md); his 23:00 order: nothing waits for the party.
effort: medium

Source: notes/ui/accept.json 41-hub-backpack = 2 (10-20 23:5x, picture notes/shots/69-camera/41-hub-backpack-1080.jpg, HEAD v33.22), and
41-hub-backpack-pad-p1 and -p2-held = 2 (48-after pictures). The critic's verdict: "The backpack is a small, dim, mostly empty box that stops halfway across the hub. It is nothing like the near-full-screen centred card with an X that the owner ordered, and it sits on top of busy world labels and a hotbar."
Top findings:
   P0 backpack window, whole panel: Make it a centred card at 90% of the screen (about 1730x970), 4px radius, --ui-panel at 90% with a 1px --ui-line-hi border, and an x button in the top-right corner (40x40, focusable). Put a rgba(6,7,8,.80) scrim behind it that 
   P0 panel interior, empty area (y 690-830): Draw a fixed grid of empty slots (for example 8x5 cells at 64px with a 8px gap, --ui-raised fill, 1px --ui-line border). Add a '0 / 40' capacity label in --fs-label. Remove the 'backpack is empty.' sentence.
   P1 hierarchy: 'backpack' title and the equipped block: Set the title at 32px f-cond 700. Show the equipped gun in a --ui-raised detail pane with a 96px icon, the name at 20px, and the ammo at --fs-hero 56px f-cond 800. Use --acc only on the focused slot.
His rulings (Q43, as job 88 cites them): the centred card with an X in the corner, one grid and one right edge, the footer CLOSE.
Done before (do not redo): done/48-hub-bag-pad-overlaps.md, done/o-10-pad-floor-bag.md, done/45-ui-backpack-trophy.md.

1. Fresh before pictures on HEAD (mouse and pad: 41-hub-backpack, 41-hub-backpack-pad-p1, -p2-held) and the critic on each.
2. Restyle only: the backpack becomes the same centred card as the other Undercroft windows (scrim, X, header row, 16px type floor, lime
   primary). No new controls, and no capacity label like the critic's '0 / 40' (his rule: no bag limit, no weight, ever). Pad routes and B back keep working (fixture checks).
3. Q8 reason in notes/ui/changes.md for any line you reword. Keep his words.
4. Critic finish line 3, at most 6 tries per screen (2.83 b); keep the better version.
Check (new, must fail on the build before): with the backpack open in the hub, the window is centred, has a visible X and a scrim.
Party risk: low (career hub only).

TASK DONE when the three pictures each score 3 or stop at 6 tries; TASK PARTIAL with what is left.
