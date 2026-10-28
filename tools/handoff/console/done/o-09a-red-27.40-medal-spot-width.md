# 209-red-27.40-medal-spot-width : the medal spot is narrower than the feed since the feed grew to 28 percent
Queue (stable triage 10-28 04:00, run corpus-1028-0157 on v35.58, rerun alone on v35.64). Fix, tiny, LOW (cosmetic, an empty reserved row in the demo).
effort: low (Sonnet is enough)

What check 27.40 expects (his answer: "a row for the style medals is reserved between the feed and the vitals, the width of the feed"): the medal spot has the same left
edge and width as the feed zone, within 2 px.
What the build does now (probed on v35.64 at 1882 wide): feed zone x13 w527, medal spot x13 w452. MEDALBOX.w is hard coded to W*0.24 in the feed layout (dark_raiders.html
about line 23380: MEDALBOX.w=Math.round(W*0.24)), while v35.53 (cw-hudsize, 20 px feed text) widened the feed zone to 28 percent. The other asserts of 27.40 hold.
Suspect ship: v35.53 (hud text at a readable size).
Fix: make the medal spot take the feed zone width (the same width variable the feed uses, not a second 0.28), so the two cannot drift again. Check that the controls list
and the pillager board still clear the wider strip (v27.35 limit L.x+L.w under 47 percent; v35.53 already moved it).
Rules: HUD layer only; seed 4242 fingerprint unchanged; looting and pickup rows are never touched.
TASK DONE when check 27.40 passes again and the gate passes.
