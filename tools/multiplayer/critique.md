# Adversarial review: corrections and open risks for the PILLAGERS multiplayer plan

Checked against `C:\claudecode\dark raiders\dark_raiders.html` (36,713 lines). The file now says **v15.73**, not v15.72: `now:'v15.73: CHECK 9.63 ...'` at L30787. Nothing was edited.

## A. Wrong or missing claims about the code

1. **"None of the AI has distance culling" (code map) is wrong.** In `navSeek`, L17310: `if(CFG.lodR>0&&G.player&&!e.merc&&dist(e,G.player)>CFG.lodR){ ... e.pathT=10+rr()*4;`. A body more than 1100 from *the* player skips its sight ray and re-routes only every 10â€“14 s. In multiplayer, enemies near a client but far from the host would get this reduced AI. The test has to become "nearest seat".

2. **The list of AI touch points (seam F) is incomplete.** These world-side functions also use the one player:
   - `feudEngage`: `var p=G.player;` (L13871)
   - `howlerImpact`: `var p=G.player,R=...` (L12675)
   - `tickNuke`: `var p=G.player;` (L26796)
   - `tickRaiderWaves`: `_cd=dist(_c,G.player)` (L15140)
   - `listenersHearInner`: `dist(G.player,e)<900`
   - also `explodeFrag`, `moveToward`, `tickExtractPoints`, `tickEnemyAudio`, `tickMachineVoices`, `inCombatNow`, `strayReveal`

3. **The AI and the world step also read and write the profile `P`, not just `p`.** Under a host-run world, all of these land on the host's profile:
   - **Pillager hostility comes from the host's rivalry record at build time.** In `mkRaider`: `var rec=...idRec(ident.id);` then `hostile:(rec.kills>0)?true:((rec.standing>0&&(rec.met||0)>0)?false:(_hostRoll<0.55))`.
   - **`updateEnts` writes the profile during the raid:**
     - `P.notoriety=(P.notoriety||0)+1; saveProfile();` (L17600, L17622)
     - `T.kills[e.kind]++; contractKill(e.kind);`
     - `rr2=idRec(e.ident); ... saveProfile();`
   - **Gun wear:** `fireWeapon` calls `addWear(owned,1)`, and so does `updateThrowables`.

   So a client's kills, notoriety, grudges, contract progress and gun wear would all be credited to the host. The netcode's `end` message (`{player,bag,pouch,tel,carriedIn,carriedKit,pedCarry}`) carries none of them. Each seat needs a shadow profile on the host, and the owner needs to rule on whose record counts.

4. **"No friendly fire by construction" (netcode) is false for area damage.**
   - Frags, L12601: `var _fMine=!f.by; ... if(dp<R&&losClear(f.x,f.y,p.x,p.y,G.map.segs)) damagePlayer(80*(1-dp/R)+18,...)`.
   - A client's frag stepped by the host damages whoever is `G.player`, which is the host, and labels it "YOUR OWN CHARGE". It never damages the thrower or the other clients.
   - Lightning (`strikeTick`, `if(d<STRIKE_R&&!p.downed)`), the Howler shell and the nuke are also single-target.
   - Area damage has to loop over seats, and whether teammates hurt each other is a decision for the owner.

5. **The netcode's 20-key CFG subset would not rebuild the same map.**
   - `buildFixedMap` and the `mk*` builders read more than 40 other keys, including `bldgRuin`, `bushRoadR`, `gridJitter`, `lmCut`, `navBody`, `partDoor`, `windows`, `winWalk`, `raiderWear`, `raiderCrews`, `crewMax`, `eliteRate`, `crateMin` and `packMax`.
   - Swapping the whole CFG is also wrong, because it mixes world dials with personal settings: `musicVol`, `bright`, `textEdit`, `cursorLoud`, `dmgNumbers`, `ringsOnTop`, `condHud`, `superhot`.
   - The Settings rows (`GAMEOPTS`: Other pillagers, Machines, How hard they hit, Raid length, How much is out there, Heat) and the console overrides in `P.tuned` write world CFG separately for each profile.
   - Someone has to sort about 200 CFG keys into world and personal. The client's movement prediction must also use the host's values (for example `pSpeed` and `wadeSpd`), or it will snap constantly.

6. **The netcode's client build step would crash, or wipe the client's profile.** It swaps `P` for `{equipped,equippedSec,weapons,merc,terms,rig,hotAssign}` and then calls `buildRaid`. But `buildRaid` needs more than that:
   - It runs `P.dropKit=standardKit(); ... var _sx=P.stash.indexOf(...)`. `P.stash` is undefined on the partial object, so this throws a TypeError.
   - It ends with `saveProfile();` (about L10791), which would write the swapped object plus the host's CFG into the client's own save key.
   - If `saveProfile` throws instead, as the netcode proposes, `buildRaid` stops before its last section.

   The fix:
   - Clone the client's full `P` and override only the world fields.
   - Turn `saveProfile` into a no-op during the build.
   - Apply the kit changes (`dropKit`, `stash`, `kitChosen`, `freeKit`) to the real `P` explicitly.
   - Replace `G.player` and `G.bag`, because the build hands the client the host's gun.

7. **Blocking saves during a seat swap breaks the swap.**
   - `saveProfile` runs inside `updatePlayer` (`var rrv=idRec(downRdr.ident); ... saveProfile();`, about L16284).
   - It also runs 5 times in `updateEnts`, and in the `mouseup` handler (`if(HUDDRAG){ HUDDRAG=null; try{ saveProfile(); }`), `hudSizeStep` and `tickZoom`.
   - The code map's fix, "restore the host CFG without saving", is not enough: any save during the raid persists `P.cfg=CFG`. `saveProfile` has to write the stashed personal CFG instead.

8. **The netcode's seat-swap set contains `active` and `beaconT`.** But `G.active` is the world's own ring pointer: `tickExtractPoints` uses it 18 times and `updateEnts` twice. With it swapped per seat, a client's beacon never drives the shared siege. This contradicts the netcode's own "one beacon call serves the world".

9. **The snapshot format overflows on the big map.** Positions are `x, y (u16 Ã—8)` and aim is `aimX/aimY u16 (world Ã— 8)`, which tops out at 8,191 px. THE COLD MILE is `w:9000, h:7600` (L6011), so positions wrap. Aim is unsigned, so it also fails off the left or top edge. Use a factor of 4 or 7, or signed values.

10. **The visibility handler mutes voice.** L30113: `if(document.hidden){ releaseAllKeys(); try{ if(AC&&AC.suspend) AC.suspend(); }...}`. The netcode sends voice through `AC` to `AC.destination`, so all incoming voice goes silent whenever that tab is hidden or minimised. Voice needs its own AudioContext or `<audio>` elements.

11. **The fallback for a hidden host tab does not work as described.**
    - Chrome runs main-thread timers in hidden pages at most once a second, so a timer-driven step runs at 1 Hz.
    - On Windows, a Chrome window fully covered by another window stops rendering, and `visibilitychange` may not fire. A host who puts Discord or another full-screen app over the game freezes the world for everyone.
    - "Keep the host tab audible" does not bring back requestAnimationFrame.
    - Also, `if(ctxLost){ lastTs=ts; return; }` skips the world step when the canvas context is lost.
    - The world step needs to be separated from rendering and clocked from a Web Worker. Whether a Worker clock escapes throttling is untested.

12. **The netcode puts the test harness on :8803.** That port is already the dry-run chain (`dryrun.ps1`), so pick another one. The fixture also overrides `say`, `sfx` and `blip`, which bypasses any network hooks placed inside those functions.

13. **Minor: `keys`, `mouse`, `PAD` and `pauseOpen` are not closure variables.** They are top-level globals in one `<script>` (`var keys={},mouse=...` at L10890, `var PAD=` at L11715), so "the net section must live in the same closure" does not apply.

## B. Scope and design conflicts

- **The two designs disagree on who owns the player's body.** The code map has each client run its own body unchanged. The netcode has the host run every seat through a seat swap covering about 50 `G` fields plus globals plus a per-seat `P`, with prediction and reconciliation, and any missed field leaks silently between seats. Pick one before estimating. For a friends-only game, clients owning their own bodies is much smaller.
- **"About 13 guarded hooks" (netcode) is too low.** Items 1â€“8 add these seams: routing profile writes per seat, the CFG split, area damage per seat, the distance-culling rule, lightning, Howler and nuke per seat, a party modal with CLOSE and ESC, controller push-to-talk, Settings rows, and a vocabulary check on every new string. The code map's 450â€“800 touched lines is closer, and probably still low.
- **The two designs also disagree on the offer size.** The netcode adds the audio transceiver when the connection is created. The research says to paste a data-channel-only offer to keep the code short. One of them has to change.

## C. itch, WebRTC, NAT and pricing

1. **The itch microphone allow list is confirmed today** on ncase.itch.io/wbwwb: `allow="autoplay; fullscreen *; geolocation; microphone; camera; ..."`. This supersedes the netcode's "did not show an allow list". It is undocumented. The owner's password-protected page is still unchecked.
2. **Opening the game outside itch starts a blank save.** This applies to the direct html-classic.itch.zone URL and to another host such as Cloudflare Pages. Chrome partitions third-party iframe storage by top-level site (rollout began in Chrome 115; the opt-out trials ended with Chrome 127). A profile built inside the itch embed is invisible there, so stash, credits and fog appear empty unless exported and imported.
3. **Cloudflare TURN probably needs a card.** The 1,000 GB free tier is shared with their SFU service.
   - A Cloudflare Community feature request titled "No-CC TURN free tier" (Oct 2025) suggests a payment method is required. I could not read it (403), so this is unconfirmed.
   - I found no spending cap. A public Worker that hands out TURN logins to any caller would let strangers relay on his card after 1 TB. The route needs rate limiting and room gating.
4. **ExpressTURN's free tier is weaker than reported.**
   - It is port 3478 only. Ports 80 and 443 are not in the free tier, so it does not help behind firewalls.
   - The free plan has no secret-key authentication ("Purchase Premium to unlock ... Secret Key authentication"). Its fixed logins would sit in the public HTML for anyone to use.
   - **Metered:** 20 GB a month with a signup and API key is confirmed; the page does not say whether a card is needed. The same exposure applies if the key is used from the page.
5. **Durable Objects: no dashboard path.** The docs describe only Wrangler configuration (`exports` or migrations), so the research claim holds. The REST API would avoid Node but needs an API token.
6. **Chrome remote voice into Web Audio is silent without a playing, muted `<audio>` element.** Still true in a 2026 source, so the workaround stays.
7. **Echo covers more than voice.** Chrome's `echoCancellation:true` means `"remote-only"`. Per the Chrome 141 notes, only `"all"` cancels the page's own playout. A player on speakers will transmit the game's gunfire and music to the others. Test `"all"` on Windows, or default to headset plus push-to-talk.
8. **Copy-paste invite codes are awkward in Discord.** Messages cap at 2,000 characters (4,000 with Nitro). A 3â€“5 KB offer, or roughly 1.5â€“2.5 KB compressed, will likely turn into a file attachment. Slow pasting may also let router mappings expire (my knowledge, not verified), so the flow needs a retry path.

## D. Steps only the owner can do

These involve accounts or credentials, so the assistant cannot do them:

- Any Cloudflare route needs the owner to log in, create D1 or a Durable Object, bind it, and paste in the Worker code. The collector is not deployed yet (`var PUBLIC_DROP=null;` at L34567).
- Cloudflare TURN needs him to create a TURN key and API token, store them as Worker secrets, and probably add a card.
- Metered or ExpressTURN need a signup and pasting the API key or login into the game himself.
- Friends need the itch page password.

**Consequence: v1 has to be copy-paste codes on public STUN only, and roughly 1 pair in 10 may fail to connect.** That figure is the research's own guess, from old 2015â€“16 data.

## E. Rulings the owner needs to make

- Pillager hostility is decided by one player's rivalry record: the host's.
- Whose notoriety, contract progress, gun wear and seal credit counts.
- Friendly fire from frags, lightning and the nuke.
- Superhot is forced off in multiplayer.
- The host's Settings difficulty rows override each client's.
- Two to four players against unscaled enemy counts, while numbers are frozen.

**Sources:**
- [Chrome timer throttling](https://developer.chrome.com/blog/timer-throttling-in-chrome-88)
- [Chromium native window occlusion](https://chromium.googlesource.com/chromium/src/+/master/docs/windows_native_window_occlusion_tracking.md)
- [Storage partitioning](https://developer.chrome.com/docs/privacy-sandbox/storage-partitioning/)
- [Storage partitioning deprecation trial](https://privacysandbox.google.com/blog/storage-partitioning-deprecation-trial)
- [Cloudflare TURN FAQ](https://developers.cloudflare.com/realtime/turn/faq/)
- [Cloudflare Community: No-CC TURN free tier](https://community.cloudflare.com/t/no-cc-turn-free-tier/846152)
- [Durable Object class exports](https://developers.cloudflare.com/durable-objects/reference/durable-objects-migrations/)
- [ExpressTURN](https://www.expressturn.com/)
- [Metered Open Relay](https://www.metered.ca/tools/openrelay/)
- [Chrome 141 beta](https://developer.chrome.com/blog/chrome-141-beta)
- [Chromium issue 41012832](https://issues.chromium.org/issues/41012832)
- [DEV: browser voice pitfalls 2026](https://dev.to/orca_forge/browser-voice-interaction-ai-pitfall-guide-2026-16-common-traps-with-aec-getusermedia-and-40hd)
- [Observed itch page: wbwwb](https://ncase.itch.io/wbwwb)