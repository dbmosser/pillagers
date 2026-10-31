# 0p06-188-outline-order (lane b, 10-31)

HEAD check: no shared outline order on HEAD (v36.79). What the raid drew before:
- partner: only the seat ring on the ground (drawSeatRing / pixSeatRing) plus the name bar; no body outline. Drawn in netUpDrawOne.
- crews: a colour block on the nameplate (crewC, ~line 42667) and a team cue glyph; no body outline.
- golden enemy: gold filter body (goldBodyBegin/End), no outline.
- elite affix: rimOpen/rimClose two-layer coloured outline (v26 aip1). Left as is (not in the order list).
- containers: no outline (his 10-15 order removed the shining circle); pixel look: ink ring baked into sprites.

Plan (cw-outlineorder): one table OUTLN (partner > golden > crew > use: alpha and width), reuse the rim stamp (rimOpen with a spec,
single thin crisp pass). Partner in netUpDrawOne (not pvp), golden and crew in the entity loop (not pixel machines, not plain machines),
use = a thin rect on the container in reach (G.nearContainer) only.
Before picture: shots/0p06-188-before (screen 33 at 4k). A 2 player picture has no camera stage: asked in alarms.md.
