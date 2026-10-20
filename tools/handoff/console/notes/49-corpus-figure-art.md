# 49-corpus-figure-art (lane a, 2026-10-20)

Run on the current fixture with runchk.sh. Fixture commits: 721986b2, 910109a3, 214b9d8e, 07d9302d.

- v28.85 STALE: his v32.64 art pick (bigger darker shadow) pushed the left edge to -11.2. Bound is now -12.0, plus a new check that the right reach beats the left by 0.6, so the cast still leans right. PASS.
- v28.16 FIXED SINCE: passes on HEAD (hero draws the headgear same as the body).
- v28.13 FIXED SINCE: passes on HEAD.
- v28.12 FIXED SINCE: passes on HEAD.
- v24.37 STALE: the Curved shoulder cap code is unchanged (6.7 / 3.6). v32.64 draws the vest 1.12 times bigger, so ink reaches about 10.5 at the shoulder row (it was under 9.6). Now compares the outer edge of Curved with Lean (Curved must be 0.6 narrower). PASS.
- v24.32 STALE: the head is drawn 1.2 times bigger about its centre (v32.64), so the brow row moved up and the old -36.6 probe hit the crown. Now takes the widest row in the hat band, same 22 minimum. PASS.
- v18.48 STALE: cw-shadowstore removed SHADSPR.ss and put the scale into the store key ('3:rx,ry,a'). Check now looks for the key with prefix 3. PASS.
- v10.00 HARNESS: the fixed screen window missed the 1.25 figure and the zoom, and the earn values no longer unlock every hat. Now paints the hero figure (hero:1, hat from the rack) on its own canvas with the wardrobe unlock-all switch, like 28.16, and a noise baseline. PASS on the rebuilt fixture (fixture commit 9206a9b2): every hat incl. band and mask draws, so it is NOT a real loss.

No game change was needed, nothing shipped.
