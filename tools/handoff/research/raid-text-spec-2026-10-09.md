## PILLAGERS RAID TEXT: ONE MODULE, FIVE LANES, HIS VOICE

**Base.** Design 3 ('one message module'). It scored best on risk and on his rulings, and it is the only design that read the check harness correctly.

**Taken from design 1:**
- the alert banner in the old MARKED row
- the pickup stack
- one prompt style at his SEARCH size
- a REVIVE prompt over a downed teammate
- the location tag and the lore card
- world text drawn over the fog
- the never-say-twice list

**Taken from design 2:** the harness-first build order and the one-line measureText fix.

### Facts this design rests on (checked on v21.78, today)
- **His Crier lines set the voice.** Today he shipped 'A CRIER IS REVEALING YOUR LOCATION' (19775, 41668) and 'CRIER REVEALED YOUR LOCATION' / 'CRIER REVEALED YOUR LAST LOCATION' (19820, 41675), marked 'his words, in the voice of a shooter HUD'. The v21.78 handoff (tools/handoff/d2178.txt) says the rest of the raid text will be rewritten in that voice. All three designs reworded these lines, so those rewrites are void.
- **The fixture hides say().** tools/mkfixture.ps1:1105 replaces say() with a copy of its old body. No change to say() is visible to any check until the fixture wraps the real function (build R00).
- **Checks depend on the old shape.** 92 checks reassign say= or sayWhenFree=. The check at mkfixture 30387 maps G.msgQ with String. The check at 16692 swaps in a fake G={over,sim,msgT,msgQ}.
- **Plates are measured on the wrong words.** Only fillText goes through TX (2773). measureText and strokeText do not, so every plate is sized on the untranslated string.
- **The boss bar draws first.** drawBossBar runs at 27279, before the message line is drawn at 27834, and places itself from the plate's fixed size (27258). A taller top lane needs a layout pass at the top of drawHUD.
- **Timers freeze.** msgT and the queue tick only in the running branch (33968-33972). They freeze in the death beat (33920) and during the burn (33957).
- **No TXSHIP conflicts.** No raid line is a TXSHIP key (2683). His keys that touch a raid are DOM card lines and the Ascend panel weather rows, and this design leaves them untouched.
- **The legend names a belt cell a slot.** It reads 'select tactical belt slot' (29094) and 'change tactical belt slot' (29149).

### 1. The voice
**One shape for every line that comes and goes:**
- A **CAPS HEADLINE** of at most 34 characters (his Crier line is 34). Subject first, present tense, no end punctuation.
- When a number or an instruction is needed, add a **detail** in sentence case. At most 48 characters, ending in a period.

**How each lane draws it:**
- **Alert lane:** the headline row over the detail row.
- **Feed:** one row, 'HEADLINE  ·  Detail.', with the detail in dim.
- **Pickup rows:** item name, count, caps tag.

**Names:**
- A name inside a caps headline is uppercased when the string is built. SEARCH NAME and NAME ELIMINATED already work this way.
- A name inside a detail keeps its stored case. Item names are Title Case, as in ITEMS.
- Nothing calls toLowerCase on a name.

**His sentence lines are drawn exactly as written, in the detail style:**
- 'Knocked down. Extraction progress bar reset. Hold E to try again.' (16216)
- 'Nothing to pick up.' (15624)
- 'Search resumed, N% done.' (17934, 42087)
- 'Self-revive spent. One per raid.' (17015)
- 'CONTRACT DONE: X. Complete contract at mainframe.' (3671) is split at his colon and nowhere else. The headline is CONTRACT DONE; the detail is the rest, word for word.

**New text never uses:** caps for emphasis inside a sentence, ellipses, semicolons, parentheses, colon labels or spaced hyphens. The only separator is two spaces, a middle dot, two spaces. Patch scripts write the dot as the \\u00b7 escape, because PS 5.1 reads .ps1 files as ANSI.

### 2. Lanes
**TOP STATUS** (27509-27575)
- Clock, compass and arrow. Their words are unchanged, except that the compass always reads 'EXTRACT A 120m' or 'WAYPOINT 120m'.
- Bare text with a 2×hudRes px INK outline. Always on.

**ALERT LANE** (top at LH(96) inside hudZoomIn('msg'), so his message-size dial still works)
- The MARKED row (27576-27580) is retired; this lane takes its place.
- One slot, for crit, warn and ext lines.
- **Style:**
  - a measured plate (the danger plate for crit and warn)
  - a 4-unit accent bar in the kind colour
  - a small path glyph: triangle-! for a threat, a clock for time, a ring for extraction, two heads for the party
  - the headline in hudFS(TYPE.head) 700, in the kind colour
  - the detail in TYPE.label, in bone
- **Timing:** fades in over 0.12 s, holds steady with no flicker, fades out over 0.4 s. It lasts 3.5 s (crit 4.5 s), or for as long as its condition holds, up to 8 s. Held conditions: the Crier mark while G.marked>0, the burn while G.nuking, a teammate down until he is up.
- **Replacing:** a line of equal or higher kind replaces the current one after 0.6 s (crit replaces at once). A lower line waits in a 3-slot alert queue for up to 1.5 s, then drops into the feed as an objective row, so it is never lost. A line with the same key refreshes in place.
- Writes HUDALERTB.

**FEED** (under the alert lane at HUDALERTB+LH(4), or at LH(96) when no alert shows)
- Two rows, newest on top, the older one at 75% alpha. TYPE.label.
- **Kinds:** obj (amber pip), info (bone), ally (blue pip), chat (dim), sys (steel, caps only).
- **Timing:** lasts clamp(2.2+0.05×chars, 3, 6) s; fades in over 0.15 s and out over 0.5 s. A row is protected for 1.2 s (obj 2.0 s).
- Writes HUDFEEDB. The boss bar, the offer line and the controller word chain under it.

**PICKUP STACK** (right edge)
- Right aligned. It grows up from above the hidden chip and the gun card (HUDBOX.gear top − LH(10)×hudRes), stays under the co-op kill feed (H×0.46), and never rises above H×0.62.
- **Rows:** the existing item icon, the name in its rarity colour, 'x3', then a dim caps tag. Tags: SLOT 3, IN HAND, EQUIPPED, BACKPACK, TO THE ARMOURY, DROPPED, FROM KITE, GIVEN TO KITE.
- Money rows: '+$1,240' in gain green, '-$540' in dim. BACKPACK FULL is a red row.
- **Timing:** 4 rows, 4 s each. The same item within 4 s merges and refreshes.
- Hidden while the backpack or the map is open.

**PROMPT** (at the object)
- Drawn with hudAtIn. Its lift is in world units (lift×ZOOM()), so it stays on the object at 4K and under ADS.
- One prompt only: the top one in reach, in this order: revive teammate > extract or call > revive pillager > give > unlock > seal > search > deal. It must be the target E acts on.
- **Style:** TYPE.head (his v10.52 size) on a measured plate. The key is amber, in brackets, from keyLabel; the verb and object are bone caps.
  - Press: '[E] SEARCH CRATE'
  - Hold: 'HOLD [E] TO CUT THE SEAL'
  - Second line, TYPE.label sentence case: 'Needs the Archive Key', '2 items left', 'Kite  ·  12s'

**WORLD TEXT**
- Labels, damage numbers, nameplates and teammate tags draw after the darkness and fog sheets.
- Plates come from actualBoundingBox.
- WEAK SPOT shows at most once per target per 0.5 s. Loot labels (his 6 s) are evicted last.
- ? and ! sit above the nameplate: lift×ZOOM, hudFS head, outlined.
- A Crier winding up shows only 'CRIER 3.2s': no ALARM word and no !.
- A downed teammate shows 'DOWN  ·  12s' in red. In reach, he also gets '[E] REVIVE KITE  ·  12s'.
- Pings, Waypoints and arrows use hudFS and 'm', with kind names from the vocabulary.
- One teammate colour everywhere.

**PERSISTENT INSTRUMENTS.** The lanes never repeat what these already show:
- the extraction band: it owns every extraction countdown, with his extractNowLine and INBOUND
- the ring badges (his zoneBadge)
- the reticle: [R] RELOAD, NO AMMO
- the gun card: RELOADING, the gun in hand
- the use bar: APPLYING, SLOTTING
- the status icons on the left, with the heal ring
- the downed overlay, YOU DIED and the centre verb
- the notoriety stamp (his v8.27)
- the boss bar, once THE OVERSEER is seen
- the offer line, CONDITIONS and the Current Pillagers board
- the co-op kill feed and the teammate rows

**LOCATION TAG**
- Uses the alert slot when it is free: the authored name in caps (THE SUMP), dim, letter-spaced, outlined, no plate.
- Shows for 2.5 s, at most once per name every 20 s.
- Dropped, never queued, while an alert holds or a hostile chases within 700.

**LORE CARD**
- Left of centre, above the belt band. hudPanel .84, a caps amber title, and a wrapped body no wider than 0.30W.
- Shows for 14 s, or until he is 300 units away. Hidden under any alert or the use bar.

**COVERS**
- **Solo pause box:** sys and info lines go to #hubtoast (z 200, scaled with the menus since v12.25), not to the lanes. The co-op overlay pause keeps the lanes.
- **Map open:** the alert lane and the feed draw after drawMapOverlay.
- **Errors:** go to the run report only, plus one sys row per raid.

### 3. The module
**Entry points.** say(m,kind,o) and sayWhenFree(m,kind,o). Calls with one string work as they do today (kind defaults to info).
- o: {sub, key, hold, life, item, n, tag}
- kind: crit, warn, ext, obj, ally, info, chat, sys, pick, log
- Ranks: crit 6 > warn 5 > ext 4 > obj 3 > ally 2 = info 2 > chat 1 > sys 0

**What each kind carries:**
- **crit:** TEN SECONDS, the burn, teammate down, host out, you running the raid, a grenade going off in your hand
- **warn:** the Crier lines, the Pillbox, something huge, something woke, playing dead, more pillagers up, your rival, a pillager turning hostile, a grenade hitting cover, the Survivor returning fire, THIRTY SECONDS, THE SIEGE
- **ext:** called, in progress, closing, closed, left without you, a teammate's call, knocked down mid-pull
- **obj:** contract done, an elite or machine boss destroyed, the seal, doors, hot ground, minute marks, cache marked, a hire dead, a survivor found
- **info and ally:** results, denials, heals, slot moves, people
- **chat:** weather, deer and birds, The Peddler, nods, drinks wearing off, restocks
- **sys:** zoom, HUD size, Superhot, Waypoint, controller, auto-jog, recorder, running slowly, error saved
- **pick:** the pickup stack
- **log:** the run report only

**Queue**
- G.msgQ stays an array of strings; its metadata sits in a parallel G.msgQM.
- A line that outranks the visible rows shows at once.
- Cap 4. A line whose key or text is already showing or queued refreshes that line instead.
- Time to live while waiting: obj 10 s; info and ally 4 s; chat and sys 3 s.
- Drains highest rank first, first in first out within a rank. With 2 or more waiting, the newest row lives 1.8 s.

**Chat lines** are dropped while any alert holds or a hostile chases or alarms within 700, and repeat at most once per key every 20 s.

**What checks can read**
- G.msg and G.msgT mirror the head line: the alert while one holds, otherwise the newest feed row. Pickups never touch them.
- G.msgK, G.msgSub and G.msgLog (a ring of 16) are there for checks.

**Timers.** They tick on frame time (dt capped at 0.1) in the running branch, the death beat, the burn and the co-op pause overlay. They freeze only in a solo pause.

**Cosmetic only.** The module returns at once when G.sim is set, never calls rnd, rr or pick, takes its time from G.t and changes no game state. No seeded draw, bot benchmark or paired A/B can move.

**TX.**
- The module runs TX() once on the whole line before it splits or measures, so his whole-line edits still match.
- measureText is wrapped to measure TX(t) (R02).
- hudText strokes TX(s), then fills s; the fillText wrapper translates it.

**No sound of its own.** The event that raised a line already plays its sound.

### 4. Style guide
**Colour tokens (HUDC), one meaning each:**
- text #e8f0f6: the default
- dim #8a96a1: details, ambient lines, system lines
- danger #ff5a4a: threats, lethal timers, closed, down. The only red.
- warn #ffc04a: time pressure, objectives, key glyphs
- extract #4de3d0: extraction only
- gain #7fc4a0: healed, revived, money in
- ally #bfe0ff: every teammate mark
- special #d08ce8: elites and caches
- rarity colours: item names only
- plate rgba(6,9,13,.78); danger plate rgba(40,8,6,.84); outline INK

**Readability.** Every glyph sits on a measured plate or carries the 2×hudRes INK outline (strokeText, round join). No shadowBlur, for frame cost.

**Type sizes:**
- TYPE.head: alert headlines and prompts
- TYPE.label: feed, pickups, details, prompt second lines
- TYPE.micro: panel rows and counters only
- Nothing that can kill you is drawn smaller than TYPE.label.

**Numbers:**
- '12s' below 60 s; 'm:ss' at 60 s and over (never 'min' or 'sec')
- tenths only on fuses (the cook, the Crier windup)
- '120m', '$1,240', 'x3', '3/5', '45%'
- His lines that write '12S' stay as they are.

**Keys.** Always from keyLabel/padB in the window that draws the line, in amber brackets. One device only: never 'T or Y'. On a keyboard with the default keys, his worded lines read byte for byte as before (the v21.74 seal precedent).

**Vocabulary (one word per thing):**
- People and machines: Pillager; Crier; Sentry, Crawler, Listener, Warden, Bulwark, Pillbox, Howler; the Survivor; The Peddler; THE OVERSEER.
- Carrying: the tactical belt, whose cell is a slot. Backpack. The Stash, whose gun rack is the armoury (the Undercroft's word).
- Getting out: you call FOR extraction and hold [E] to extract. Never 'way out', 'point' on its own, 'pulled' or 'lands'.
- Marks: Waypoint (his 'Marked Waypoint'), never Marker.
- Outcomes: machines are DESTROYED, pillagers ELIMINATED or DOWNED, a hire is dead, a downed body is revived.
- Money is Credits, shown as $. The surface is 'up top', never 'the map' as a place.
- Gun, not weapon. Issued gear, not kit. GRENADE (his cookShout word) for a thrown Frag Charge in a headline.

### 5. Two players on one PC
- Each window has its own G, so the module is per window by construction.
- **Private lines stay in their own window:** your pickups and results, alerts aimed at you, and lines behind seat gates (marks, gifts, aid, kills).
- **Shared events cross over the existing net words** and are worded for each window. The caller's window shows EXTRACTION CALLED; the other shows 'Kite called for extraction at B.'
- Shared events: extraction calls, the boss destroyed, doors, weather, hot ground, restocks, host out, the raid clock and the burn.
- **Teammate down** is a crit alert on every window except the downed player's; his downed overlay owns his own screen.
- Keys resolve in the window that draws the line. One teammate colour everywhere.

### 6. 4K
- Every screen string goes through hudFS, FSz(...,hudRes), hudZoomIn or hudAtIn.
- Every world lift is multiplied by ZOOM().
- Every layout check runs at 3840x2160 and at 1920x1080, with __forceSize and __pinDPR.

### 7. His words: never reworded, only the key token through keyLabel
The list is in mustNotChange.

**Left as he wrote them; only he can unify them:**
- the ring badge's SOUND THE ALARM and '12S' (26954)
- extractNowLine's '12S' (26971)
- the lowercase 'mainframe' in CONTRACT DONE

### 8. Checks
- Each check runs against the previous build first and must fail there.
- Needles are assembled ('KNOW WHERE YOU '+'ARE'), never written whole.
- Stub a ctx method as an own property and delete it in finally.
- Drive the real path: __loop frames, a held KeyE, staged pulls, and navigator.getGamepads stubs for the pad (PAD is rebuilt every frame).
- Read what was drawn with txRecord or __textTrace, and what was said with __msgLog / __hudSaid(lane).
- Restore P.txt, keys and the profile in finally.
- Each build that moves or rewords a line greps mkfixture.ps1 for that line's old needles and moves them in the same build.

### 9. Build order
- R00-R01: the module lands first (harness wrap, then kinds).
- R02-R07: the look, two rows, the safety wrap, the rank guard, the queue.
- R08-R15: the alert lane and everything that belongs in it.
- R16-R19: the pickup stack.
- R20-R27: keys per device, one prompt style, the teammate revive prompt, one teammate colour.
- R28-R33: lines that repeat a panel, or that nobody can see, are removed.
- R34-R39: chatter, errors, the pause, the map, the lore card.
- R40-R47: 4K and world text.
- R48-R55: numbers, never-words, name case, and the voice passes.

R52 (tactical belt and gun lines) ships after the 4-gun belt build, his order, next in the queue.

A line's move into a lane and its restyle to that lane's rules count as one change.

### 10. Parked
- Player 2's killing shot never shows a kill number (20976-20986).
- Taunt sentences are drawn as a think mark.
- DOWNED and crew PICKED UP labels show through walls (19064, 20444).
- The emote strip covers the belt at 1440p and 4K.
- The ARMOUR label is taller than its bar.
- The posture chip always shows STANDING.
- There is no voice-chat talking indicator.
- A solo kill feed (design 2) is a new feature, so it waits until after the alpha.