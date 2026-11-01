# 134 picture store total and soak (lane b, 11-01)

## Shipped: v37.02 (cw-picstoretotal), ON HIS PC v37.02
- `picStoreTotal(fresh)` adds up every off screen picture store: wall, tree (veg), shadow, icon, every registered gfxStore (gun, lightspr, muz, gfxE, pixmachines), the two byte capped pixel stores and the big baked canvases (ground, fog of war, hub floor, fog and light sheets). It returns `{n, b, pn, pb, t, by:{store:[count, bytes]}}`; b is width x height x 4. pn/pb are the biggest n and b seen this raid. Cached for 1 s.
- Frame telemetry: `G.tel.gfx.pic` (filled by gfxTel, so only live raids, not bot raids). Run record: `gfx.pic`. Flight recorder run line ends with `pics:N/XMB peak:N/XMB by:wall 12,veg 9,...`.
- Check 37.02 FAILS on v37.01 (no picStoreTotal), passes on v37.02; it also adds a 10x10 picture to a store and needs the total to rise by exactly 1 and 400 bytes, and reads the run record and the run line. Seed 4242 fingerprint held (ents 85/374, containers 165/593).
- Nothing on screen changes. Reads only; no seeded draw.

## What he should watch for in a playtest
Nothing should look or play differently. In the flight recorder export, each run line now ends with `pics:N/MB peak:N/MB by:...`; if `pics` climbs from raid to raid in a long session, tell the coordinator. (DESIGN.md v37.02 has the ship text only: this lane may not edit DESIGN.md, so the watch line lives here.)

## The 3 hour two-window soak: NOT RUN by this lane
- Why: this lane may only run the ship scripts, preflight, the camera and the test-script forms on its list; tools/fuzz.ps1, the robot runner and tools/handoff/soakloop.ps1 are not on it, and it cannot read free RAM. The brief says to leave it for the coordinator's night run in that case.
- The idle runner's soak (tools/spare/soak-run.ps1, 6 runs x 120 s) is too short to show a store growing; it does not read the new total.
- Static reading of the stores (no data yet, so no fix shipped):
  - Capped: wall 320 (oldest quarter out), shadow 300 and icon 400 (all dropped when over), tree (veg) by radius and reset on a new map or palette, pixel actors 24 MB and scene 16 MB (LRU by bytes).
  - NOT capped, keyed by something that can vary: `gun` (id|forge|element|reticle colour|scale S), `lightspr` (kind|colour), `muz` (family|tint). Colours come from lights and entities, so this is where a slow growth would show. If the soak shows one of these rising, cap it like ICONSPR (drop all above ~400), which is the fix the brief asks for.
  - The big canvases (ground, fog of war) are replaced once per raid; a leak there shows as `by.big` count above 5 after a raid ends and a new one starts.

## How the coordinator can run it (about 3 hours, both windows)
1. Free RAM at least 4 GB first. Start the two-window demo raids on a scratch port (not 8802), 1080p, smooth look (the default).
2. Every 5 minutes read the total from each window: `JSON.stringify(picStoreTotal(true))` through tools/cdp.ps1 -Expr (add `-Match` for the window). Append `t, n, b, by` to the table below.
3. The flight recorder also carries it: each finished raid prints `pics:... peak:... by:...` on its run line, so a long run gives one row per raid with no polling.
4. Growth test: the same raid kind repeated, `n` and `b` should level off after the first few raids. A store whose count in `by` keeps climbing across raids is the leak.

| clock | window | n | MB | by (wall veg shad icon g.gun g.lightspr g.muz g.gfxE pix.actors pix.scene big) |
|---|---|---|---|---|
| (not run yet) | | | | |
