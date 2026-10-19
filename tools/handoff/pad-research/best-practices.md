# Pad best practices for PILLAGERS (research report, 2026-10-19)

Scope: Xbox pad play in a Chrome canvas twin-stick extraction shooter, two players on one PC in two windows. Target: party demo Fri 2026-10-30. Feature cutoff Mon 2026-10-26, lock Thu 2026-10-29.

Sibling file: presets-and-aim-assist.md (another researcher). This report does not repeat presets or aim-assist tuning. One sentence on aim assist: every reference game that ships assist lets players turn it down to off (Enter the Gungeon, ZERO Sievert level setting, the Duckov pad mod), and we have none except the player-2 "kid firing" auto-aim.

How to read the marks:
- (C) = confirmed by the fact-check.
- (U) = unconfirmed. Could not be verified. Do not build on it.
- (N) = not fact-checked. The source report's own confidence is kept.
- Items with function names and line numbers come from reading our own code (the pad audit). Line numbers drift, search by function name.

---

## 1. In plain words

The best top-down shooters on a controller (Zero Sievert, Helldivers, The Ascent) keep it simple: left stick walks, right stick aims, triggers shoot, and nothing important needs a mouse or keyboard. Players rarely complain about the shooting. They complain about menus and backpacks a pad cannot finish, sticks that feel sticky or snap to straight lines, and pads that get mixed up in co-op. Escape from Duckov still has no real pad support a year after launch, so we start ahead.

The five changes that matter most for the party:

1. Fix the stick math, so aiming is smooth and walking diagonally is not slower.
2. Make each guest's controller clearly theirs, and make a bumped or unplugged pad come back cleanly.
3. Remove dead ends. Typing a save name and the floor backpack in the undercroft cannot be used with a pad today.
4. Give the crowbar its pad button (right stick click) and test that it does not fire by accident.
5. Draw real controller pictures on the prompts, big enough for a couch, then watch five newcomers play with only a pad.

---

## 2. What the reference games do

Reading notes: "pad" means Xbox-style pad. Most references are single-player, so the co-op column is mostly "none". Source tags in brackets are listed in section 7.

| Game | Aim model on pad | Aim reach / distance | Aim help | Inventory on pad | Menus on pad | Co-op pad handling | What players said |
|---|---|---|---|---|---|---|---|
| Escape from Duckov (Team Soda, Oct 2025) | Mouse crosshair with hip-fire spread and ADS. No native pad support: Steam lists none, no patch through 2.3.30 (2026-07-02) adds it, reviews dated 2026-10-03 to 10-10 still ask (C) [D1][D2][D3]. Mods: a Steam Input translation mod drives a cursor with the right stick (C) [D7]. DuckDuckCon is a twin-stick mod: right stick aims, LT ADS, R3 swaps two aim schemes (U) [D8] | No pad reach control found. Mods only scale stick sensitivity for hip-fire and ADS (U) | None native. DuckDuckCon has optional assist, off by default (U). Other Workshop assist mods exist, unread | Native: none. Translation mod: hold RB+A to drag and drop, D-pad moves in lists (C) [D7]. DuckDuckCon: D-pad grid, bumpers jump between my-stuff and container, A place, X item actions (U) [D8] | Translation mod works in a raid only; main and pause menus need keyboard and mouse (C) [D7]. Steam Deck rating is Playable, not Verified: glyphs do not match, no auto on-screen keyboard [D5] | Single-player. Only a community VPN co-op mod: no revive, no PvP (N) [D9]. No local co-op | Inventory is the main pad pain ("hundreds" of presses) [D11]. Headshot precision on a stick is hard [D12]. Still asking a year later [D13]. A 2026-07 reviewer called the mod mapping unplayable [D18] |
| ZERO Sievert (CABO, pad since 0.41 on 2024-02-28) | Cursor-style aim. Right stick places the cursor, LT hold = focus aim. Full damage needs the cursor on the enemy; crosshair colour shows range (C) [Z1][Z6]. A 2025 reviewer says the pad cursor is tied to a circle round the player | Reviewer: rifles need more distance than the pad cursor reaches. The dev reply (Aug 15 2025, not 2026) called cursor-on-enemy intentional (C) [Z5]. That reply predates the April 2026 assist rework, so it is not the current model | An aim assist level exists (2025). April 2026 test build added a strength slider and better assist; the shipped 2026-04-22 patch says improved assist (C) [Z3][Z4]. Default value unknown | Pointer with snapping, A grab, quick-move. Quick-move still throws the cursor into the other container (known issue, dev reply 2026-09-14) (C) [Z8]. Pad stack split was missing at launch [Z22]. One-press "collect" from a container added Aug 2026 [Z16] | B always backs out since April 2026. Wheel moved to the left stick so you can still aim. Map pans on a stick, one-button markers, Deck glyphs [Z4]. Sprint is a toggle on pad (hotfix ~2026-08-20) (C) [Z17]. Full controller support and Deck Verified badges (C) [Z12][Z14] | Single-player | Shooting, moving and the wheel are rarely criticised. The loud complaint is inventory, looting, trading and menus. Top negative pad review has 159 votes ("barebones") [Z23]. Some Deck players are happy [Z24]. My keyword pull: about 3.7% of 3,688 reviews mention pad or Deck, 70 of 136 negative (N, approximate) [Z20] |
| Helldivers 1 (Arrowhead, PC Dec 2015) | Pure twin-stick: right stick sets direction, red laser sight, no zoom, RT fire (wiki, C) [H1]. No cursor on pad [T25] | Fixed weapon range. Turn speed is a per-weapon trait (one-handed weapons turn faster) [H23] | None found, and no statement either way | None. Stratagems: hold LB, enter a 3 to 7 press D-pad code with the code shown on screen [H3] | Steam lists partial controller support (C) [H14]. PC port had a right stick stuck in aim mode. A deadzone setting came in patch 4.1.9 on 2016-01-14, 38 days after launch (C) [H6][H8]. Pads had to be plugged in before the menu [H12] | Up to 4 local players, shared screen (C) [H14]. Any input from an unassigned device spawned a clone player; fix was a "player drop out" entry [H9]. Friendly fire always on | D-pad codes are hard under fire [H15]. Xbox 360 D-pad is mushy; Reinforce is a 5-press code [H4][H10]. Reviewers praise tight stick feel and couch co-op [H16] |
| The Ascent (N) | Twin-stick. LT raises the weapon (aim high over cover). Laser sight shows if the shot will hit. With the right stick idle, aim follows the move direction [T5][T6][T7] | Fixed | Auto-aim setting with levels (Steam user reports, low confidence) [T8] | Not a focus | No remapping at launch [T7]. First pad to press A becomes player 1; mixing keyboard and pads in couch co-op was unreliable [S22] | Co-op join flows confuse players [S22] | Smooth twin-stick feel [T28]. Single reports: aim snaps to cardinal lines, sensitivity 1:1 and too big [T8] |
| Nex Machina (N) | Right stick direction fires (deflection is the trigger). Dash on L1/L2, secondary weapon on R1/R2 [T9] | Not applicable | Not documented | None | Four preset layouts, all keep the same aim model [T9] | Not documented | Reviewers praise the few, clean controls [T9][T10] |
| Alienation (N) | Twin-stick, R2 fire, L1 dash, R1 melee. Reload moved to R3 with a timed second click [T11] | Fixed | Not documented | Not a focus | Not documented | Not documented | Reviewer often mis-pressed the R3 reload and fired an ability instead; tutorial explained it badly [T11] |
| Ruiner (N) | Twin-stick; dash taps to dash, holds to slow time and queue dashes [T12] | Fixed | Not documented | Not a focus | No pad remap and no aim sensitivity at launch; dev made rebinding the top patch job [T12] | Not documented | Ranged aiming over/undershoot on pad at launch [T12] |
| Enter the Gungeon / Exit the Gungeon | Direction only. The reticle is mouse-only; a pad can show an optional crosshair at a fixed distance that only shows facing (C for the dev quote) [T1] | Fixed | Pad-only assist, adjustable to off. 2.0.0 (2018-07-19) added more assist options (C) [T2]. Exit the Gungeon 2.0.6 added Aim To Fire and a pad cursor option; the date is unconfirmed (one source says Apr 2020) (U) [T4] | Not a focus | Dodge roll defaults to LB with 360 degree roll from the move stick [T3] | Not documented | Pad works well; some say mouse is more precise [T27] |
| Hotline Miami (console) and Nuclear Throne (N) | Twin-stick. Console Hotline Miami adds a lock-on button for the nearest enemy; it ignores walls [T13]. Nuclear Throne has a gamepad-mainly auto-aim percentage (low) [T24] | Fixed | Lock-on / auto-aim | None | Not documented | Not documented | Lock-on target flicking with the stick is "a crapshoot" with several enemies in line [T13] |
| Diablo IV, Diablo II Resurrected, Path of Exile 2 (N) | No cursor. D2R scans a wide cone, ranks targets and highlights only one [T14]. D4 locks on with right stick click [T15]. PoE2 aim resets when the stick is released; players ask for persistent aim [T20] | D4 sets traversal range from stick deflection (PTR note, May 2024; still live is unconfirmed) [T16] | Auto-target; PoE2 added customisable targeting in 0.1.1c [T19] | Snap focus; PoE2 snapping can skip a 1x1 item between big ones [M9] | PoE2 pauses on pad disconnect by default since 0.1.1 (2025-01-16) [T18] | Not a focus | PoE2 lost interact to a skill bound to X (workaround: move interact to A). D4 "combine interact and basic skill" can block looting [T17][T21] |
| ARC Raiders, Delta Force, Dark and Darker, Tarkov-likes (N) | Not the focus (3D or 2D shooters) | Not applicable | Not the focus | ARC Raiders: focus navigation with a context menu (inferred). Split: pick up a stack, then put half in an empty slot; no single-item move [M3][M4]. Delta Force: virtual cursor, patched for speed, snap and batch select [M2]. Dark and Darker: pad works except loot and inventory [M8]. Tarkov and Gray Zone: no official pad support, inventory blamed | ARC Raiders added Hold/Toggle labels to hints and fixed focus resetting to a wrong slot [M3] | Not a focus | Inventory is the usual place pad support fails [M8] |

What the table says, in five lines:
- Pad-first twin-stick games aim by direction only (Gungeon, Helldivers, Nex Machina, Ascent). The games with pad pain are the cursor-style ones (Zero Sievert, Duckov). Our reticle at a stick-set angle plus D-left/D-right distance is closer to the first group and has no equal in the references.
- Almost no reference is built for two pads on one screen. Helldivers is the only one, and its lesson is bad: any stray input from an unassigned device made a clone.
- Combat is rarely the problem. Menus, backpacks, looting and text entry are.
- Melee, dash and dodge sit on shoulders or triggers in most twin-stick games (Gungeon LB, Nex Machina L1/L2, Alienation L1/R1). Ours are on face buttons (A roll, B crouch, X reload/search, Y loot), which pull the right thumb off the aim stick. The Ascent also uses A for evade. The preset researcher owns the fix (roll on a bumper or trigger preset).
- Stick clicks are risky for time-critical actions (Alienation R3 reload).

---

## 3. Best-practice checklist

Status words come from the pad audit of our code: good, partial, missing, buggy. Priority: must = affects every guest, can strand a guest, or breaks a binding rule. should = guests will notice. later = after the party.

### 3.1 Already good (keep, do not rework)

| Practice | Our status |
|---|---|
| Prompts follow the last-used device, Xbox glyphs only when a pad is active, key prompts hidden | good: INDEV and indevPadTick (~16656-16695), padOn (~17882), keyLabel (~17918). Matches the live-prompt order and the Steam Deck glyph rule [M14][P14] |
| Menus use spatial focus, not a free cursor, with a visible ring and a default focus per panel | good: padOpenModal (~17936), padFocusables (~17970), padStep (~18024), padMenu (~18056). Matches Microsoft guidance [M11] |
| Stash and pre-raid backpack: A pick up, A place, quantity prompt (slider, half, all), Y context menu | good: stashPadAct (~65169), qtyAsk (~65243). Already ahead of Zero Sievert (no pad split at launch) and ARC Raiders (no single-item move on console) |
| Looting without a container panel (a search pulls items straight into the bag) | good by design. The Zero Sievert "take all" and quick-move cursor jump problems cannot happen here |
| Item wheel: hold D-down, right stick picks, release takes, aim frozen while open | good: wheelOpen / wheelTick / wheelRelease (~22335-22389). Note: Zero Sievert moved its wheel to the left stick because its wheel is held on a bumper; ours is held on the D-pad (left thumb), so the right stick is the only free stick. The aim freeze is physical, not a flaw |
| Rumble with dedupe, strength setting, off switch and routing between the two windows | good: padRumbleOn / padRumble (~54998-55023). Matches XAG haptics advice (off switch plus intensity) [P10] |
| Pad rebind window with swap on clash, prompts follow bindings | good: padBind / padReset (~18920-18934), padLabelsApply |
| Pad assignment rule (first pad = player 2, second = player 1; each side keeps its pad while plugged in) | good logic: netPadFor (~54852-54877), NET.padWas. Identification is missing, see C4 |
| Aim keeps the last angle when the right stick is released | good: pollPad (~18299-18312). Exception by v6.85 order: with the right stick idle and the left stick moving, aim follows the walk direction. See open question 2 |
| One button (X) resolves search / interact / reload at the moment of the press | good: pollPad (~18504-18546). Keeps interact off anything an attack can swallow, which PoE2 and Diablo IV both got wrong [T17][T21]. Watch for mis-resolution when walking up to a box while meaning to reload |

### 3.2 Must

| ID | Practice | Why | Seen in | Our status | Priority |
|---|---|---|---|---|---|
| C1 | Scaled radial deadzone on both sticks (length scaled, direction kept, length clamped to 1). Add a small outer deadzone so worn pads still reach the rim | A per-axis deadzone snaps aim and walk toward N/S/E/W and shortens diagonals. XInput stock deadzones are about 0.24 left and 0.27 right (C); the browser applies none, so the page must [P7][T23] | Sutphin and Venturelli articles; Warframe sliders (N); Ascent players report snapping (N) | buggy: padAxis (~18202-18209) and padDz (~18198) are per axis, comment says radial; callers pollPad (~18269 move, ~18274 aim); wheel pick (~22372). Diagonal walk and aim reach are about 12% lower at default and about 28% lower at HUGE | must |
| C2 | Every screen finishable with a pad alone; never a focus landing on a control the pad cannot use | Duckov's best pad mod is raid-only; Dark and Darker pad play stops at the inventory; Steam Deck Verified requires full reach [D7][M8][M14] | Duckov, Dark and Darker, Zero Sievert | partial: padFocusables (~17998) lists text fields and selects, but A only calls .click(), so a pad lands on a dead control. The undercroft floor backpack opens on View but has no pad route (hub branch ~18368-18401, hubBagOpenSet ~44917, floorPadTap ~16860) | must |
| C3 | Pad-driven text entry for any typed field in a normal flow (career name) | Valve lists "text input does not invoke the keyboard" as a Duckov Deck failure; Deck Verified wants a pad-completable entry [D5][M14] | Duckov, Steam Deck rules | missing for career names (title #pnamein, ~2575 and ~67542-67576). The arcade initials card already has a pad route (arcadePadIni ~63369) | must |
| C4 | One pad per window, claimed on purpose, visibly identified, never stolen or doubled | Helldivers cloned players from any stray device; Just Shapes and Beats, Nobody Saves the World and The Ascent all had join mix-ups [H9][S20][S21][S22] | Helldivers 1, party games | partial: logic is good (netPadFor ~54852-54877, netPadSend / netPadRecv ~54913-54942), but nothing tells a guest which pad is theirs, assignment follows connection order, and the CONTROLLER row is unreachable by pad (partypadbtn excluded ~18005) | must |
| C5 | Pad loss and return: detect by polling, say it plainly, resume cleanly | PoE2 pauses on disconnect by default; Burke's rule is to pause and let the same device resume. Chrome shows pads only after a button press, so a press is needed after a reconnect anyway [T18][P14][P1] | PoE2, Golden Rules of Input | buggy: gamepaddisconnected (~18678-18689) opens a box saying "reconnect to resume", but gamepadconnected (~18674) never closes it. In a party or co-op raid the box does not stop the world | must |
| C6 | Melee on a pad button | Every pad shooter with melee gives it a button (Helldivers melee on a face button, Alienation R1, Duckov mod on D-pad left, ARC Raiders D-pad left) [H21][T11][D7][M5] | Helldivers 1, Alienation, ARC Raiders | missing: meleeStrike (V on keyboard) has no pad route; Y only holds V for the finisher; RS click is still the focus-aim toggle (~18485). Owner chose RS click for the crowbar. Stick clicks are risky, so test it (Alienation R3) | must |
| C7 | B always means back; the open button also closes its screen | Zero Sievert needed until April 2026 to make B exit menus; a refund reviewer died in a raid because he could not find close [Z4][Z25] | Zero Sievert | partial: padMenu B finds the first Leave / Close / Back / Done / Return button. Gaps: undercroft floor B does nothing, rebind window takes B as the new button (padWaitTick ~18966) | must (floor part folds into C2) |
| C8 | Know exactly which window sees which pad while it is focused, unfocused, and while another app has focus | Chromium engineers say non-foreground access is intentional and some OS APIs deliver only to the focused app (C) [P2][P3]. Microsoft: a Windows app must have focus to receive controller input (C) [P4] | Chromium issue threads | partial: the design already assumes focus-only (the front window reads every pad and forwards the other pad's state; netPadDead / netPadHud ~54970-54990 shows "controller paused: click one of the game windows"). It has never been measured on the party rig | must (a 1 hour test, job J1) |

### 3.3 Should

| ID | Practice | Why | Seen in | Our status | Priority |
|---|---|---|---|---|---|
| C9 | Trigger press and release thresholds with hysteresis (press about 0.35, release about 0.25) | A trigger hovering at the threshold chatters; a semi-auto gun can double fire. Microsoft's own 30/255 trigger threshold is only a noise floor (C) [P7] | XInput docs, web.dev guidance | partial: pollPad (~18478-18489) uses one 0.35 value for RT and LT | should |
| C10 | Menu stick reaches the next control from a modest push, and a held D-pad auto-repeats | Zero Sievert players complained of one-step D-pad grids and unresponsive menu sticks [Z27][Z22] | Zero Sievert | partial: padMenu (~18107-18121) needs raw about 0.69 at default (0.76 / 0.84 at LARGE / HUGE), and the D-pad never repeats | should |
| C11 | Real controller pictures: D-pad and stick icons as well as ABXY, large enough for couch distance | Players had no layout page or saw keyboard prompts in Zero Sievert; Deck rules want matching glyphs and readable text (9 px minimum on a 1280x800 handheld, 12 px recommended) [Z25][M14] | Zero Sievert, Deck rules | partial: HUDKEY_PAD / hudKey (~12062-12078), uiKey (~17913), LEGEND_PAD (~42893). ABXY are coloured round buttons, but D-pad and sticks are plain text ("D-DOWN", "L STICK"), and in-world prompts are drawn at 0.6 scale | should |
| C12 | Aim reach covers the equipped weapon's range, shows what it is, and is remembered | Zero Sievert players complained that rifles outrange the pad cursor (a 2025 report, so treat as a lesson, not a current fact) [Z5]. Players need to see what a control did | Zero Sievert | partial: D-left/D-right clamp at 70-520 world px (pollPad ~18466-18471), default 200, resets on reload, no readout; weapon ranges reach 900 | should |
| C13 | Lefty option that swaps the sticks | Binding owner rule. Diablo IV and Gears 5 expose stick swaps; Xbox accessibility guidance asks for remapping that includes sticks [T15][P9][M13] | Diablo IV, Gears 5 | missing (padmap says the sticks stay put) | should (binding rule, small job) |
| C14 | Check gamepad.mapping === "standard"; when no pad has been seen, give a short "press a button" hint | The Gamepad API hides pads until a button press; non-standard pads silently give wrong buttons. Helldivers only found pads that were present at the main menu [P1][H12] | W3C spec, Helldivers 1 | partial: no mapping check in pollPad (~18232-18259); the wake hint exists only in the arcade attract (attTick ~47928) | should |
| C15 | Hold-to-craft must be a hold on a pad too | A stray press crafts at once | general | buggy: craft (~53394) fires one synthetic click on A | should |
| C16 | Aim-time actions on triggers or bumpers; no more than 2 to 3 face-button actions while aiming | The right thumb is on the aim stick. Gungeon roll on LB, Nex Machina dash on L1/L2, PoE2 players complain about face buttons while aiming (N except Venturelli confirmed) [T22][T3][T9][T21] | Gungeon, Nex Machina, PoE2 | partial: roll A, crouch B, reload/search X, loot Y all need the right thumb. Fix path is a preset (see preset researcher), decide after the guest test | should |
| C17 | Separate move and aim sensitivity, an optional response curve, and aim smoothing that defaults to off | Venturelli: sensitivity down in a focus mode; Xbox guidance asks for at least plus or minus 50% of default per stick [T22][M13] | Relic Hunters Zero, XAG 107 | partial: one STICK SENSITIVITY gain before a per-axis clamp (settings ~66195-66210) | should |
| C18 | Show the aim line and the current aim distance; make P1 and P2 aim marks distinguishable | Helldivers' laser sight and colour-blind fix in patch 1.04 [H6] | Helldivers 1 | partial: reticle with trail exists (padCursorPut ~18173-18187); no distance readout | should |
| C19 | Prompt strip in one corner, same order on every screen | Xbox guidance 112: same prompt does the same job everywhere [M12] | Microsoft, Sea of Thieves | not audited | should (check) |

### 3.4 Later

| ID | Practice | Our status | Priority |
|---|---|---|---|
| C20 | B (or a visible cancel) cancels a pending rebind | buggy: padWaitTick (~18966) accepts B / Menu / A as the new button | later |
| C21 | Extra rumble events (reload done, low health, landed hit) and trigger-rumble where the pad supports it (Chrome 126+, experimental) [P5] | partial: dual-rumble covers damage, down, blasts, shots, teammate down | later |
| C22 | A hold-or-toggle option for the pad holds (zoom, focus aim, wheel, finish) | missing: LT is hold, RS click toggles focus aim (goes away with C6) | later |
| C23 | Gun switching: nine gun keys are slow to step with bumpers; steps fire on release (about a press-length late, roughly 0.1 s, so minor) | partial: beltStep (~25710-25726). All 16 buttons already have jobs, so a last-weapon button would need a home | later (open question 4) |
| C24 | Pad routes for waypoint clear, mercenary orders (O), raid status overlay (Alt), HUD size | missing; low impact | later |
| C25 | Consistent hold/toggle labels on prompts (ARC Raiders added them in Cold Snap) [M3] | partial | later |

Practices to leave out on purpose (all conflict with binding rules or caused trouble elsewhere):
- Single-stick scheme. Xbox guideline 107 says games should not require two sticks (C) [M13]. The owner rule is always twin-stick; the lefty swap and sensitivity sliders cover the accessibility gap.
- A free cursor for the backpack or menus (Delta Force needed many patches; Microsoft says turn mouse mode off by default) [M2][M11].
- Pad-to-keyboard translation layers (Duckov mod: custom keybinds break it, slots 7 and 8 unavailable) [D7].
- Fire on right stick push as a default (Nex Machina). Looting and scouting need aim without firing.
- A second control for a job an existing control does (for example a bumper-plus-D-pad layer inside menus). One control per job.
- Party-only extras (owner: the party is the demo, no extras).

---

## 4. Gaps to fix before the party

All jobs are small and general pad quality, none is a party-only feature. Suggested order: J1 first (no code), then musts J2 to J8, then shoulds J9 to J14, and the guest test J15 after the Mon 2026-10-26 cutoff. After the cutoff only fixes.

Method notes taken from the team's own habits: stub getGamepads() for pad tests because pad state is rebuilt every frame; run each new test against the previous build first to see it fail (a test that was never red proves nothing); take 1080p and 4K screenshots for anything visual. Game text in lower case; the audit quotes some strings in capitals (for example "CONTROLLER DISCONNECTED"), so check they render in lower case.

### J1. Two-window, two-pad rig test (no build, about 1 hour) - must
- Build: add a throwaway overlay (or console logging) in each Chrome window that prints, once a second, every getGamepads() slot: index, id, mapping, axes and pressed buttons, plus the document focus state.
- Test: matrix on the party PC with the two real Xbox pads and the two side-by-side windows. Pads connected before and after page load. Focus on window A, on window B, on a different app. Press each pad in turn. Unplug and replug each pad. Leave a pad idle 15 minutes (do Xbox pads sleep on PC?). Try trigger-rumble on a Series pad (wired, dongle, Bluetooth). Write the result table beside this file.
- Rules respected: Xbox only. No design change unless the result contradicts the focus-only assumption already built into netPadSend / netPadRecv.
- Answers: whether an unfocused window sees data, whether the two pads' id strings differ (Chrome often reports "Xbox 360 Controller (XInput STANDARD GAMEPAD)" with no vendor or product ids (U for current builds) [P20]), and which index each gets after a reconnect.

### J2. Scaled radial deadzone for move and aim (about 3 hours) - must
- Build: one function for the 2D stick: length m = hypot(x, y); below the inner deadzone return 0; otherwise output direction unchanged, length min(1, (m - inner) / (1 - inner - outer)), with a small outer value (about 0.05 to 0.08). Apply the sensitivity gain to the length before the clamp, not per axis. Replace padAxis in pollPad for move and aim and in the wheel pick. Keep the DEADZONE settings row and its four values. Menu stick stepping keeps working on the new output.
- Test: pure-function sweep, angles 0 to 359 in 1 degree steps at raw magnitudes 0.30, 0.60 and 0.95: output angle within 0.5 degree of input (the old code fails near every axis, run it first). Raw (0.707, 0.707) gives output length at least 0.99 of the straight-axis case (old: 0.88). Below the inner deadzone gives exactly zero. Raw length 1.0 gives 1.0. Then in the game: walking diagonally covers the same ground per second as walking straight within 1%; the 8-slot wheel picks the right slot at 8 angles and at the segment boundaries.
- Rules respected: always twin-stick, no new control, no new menu text.

### J3. Pad-only crawl test (about 3 hours) - must
- Build: a test that walks every reachable screen with a stubbed pad: title, modes, saves, settings, controller settings, rebind window, stash, sector page, ascent check, shop, pause, outcome card, map, undercroft floor, wheel, backpack.
- Test: on each screen it asserts there is a focused control; every focusable can be activated by A and does something; B (or the close button) leaves; no focusable is a text input or select without a pad route. It fails today on the career name box, #stashsearch, #delword, #resword, other text fields and the undercroft floor backpack.
- Rules respected: B always means back; nothing needs a mouse. This is the safety net that keeps J4 and J5 from regressing.

### J4. Pad text entry for the career name (about 4 hours) - must
- Build: reuse the arcade initials card behaviour (up/down changes the letter, A next, B back, Menu done) as a general letter picker for the new-save name, lower case, with a pre-filled default so pressing A through it still works. Where a text field has no pad route (stash search, feedback box, ghost friend name), make padFocusables skip it on a pad. The delete-save and reset words stay keyboard only, which is a good safety for a party.
- Test: stub pad creates a new save with a typed name, the name appears in the stash and survives a reload; J3 reports no text field reachable without a route.
- Rules respected: typed name into a new save (afternoon orders), lower case, no explaining text.

### J5. Undercroft floor backpack for pads (about 3 hours) - must
- Build: when the floor backpack is open on a pad, route D-pad arrows, A pick up and place, Y drop and B close through the same helpers the raid bag uses (bagArrow / bagPadCell / bagPadAct), or do not open it with View on a pad. Make B close it.
- Test: stub pad in the hub: View opens the bag, D-pad moves the highlight (assert the highlighted cell changes), A picks up and A places (assert the item moved), B closes; no keyboard events at all.
- Rules respected: one control per job (same buttons as the raid bag).

### J6. Crowbar melee on right stick click (about 3 hours) - must
- Build: RS click calls the same meleeStrike that V calls. Ignore it while the bag, map, wheel, stall or forge is open. Remove the RS focus-aim toggle (LT hold stays the focus control; a hold-or-toggle choice for LT can live in settings later). Update PADLABEL and the pause layout legend. Inference, not from a source: freeze the aim angle for about 80 ms around the click edge, because pressing a stick nudges it.
- Test: stub RS press calls meleeStrike once; held RS does not repeat faster than the melee cooldown; no call with the bag open; the melee one-shots crawlers and breaks walls as ordered. Then three newcomers play five minutes each aiming hard; count unintended melee swings and review.
- Rules respected: R3 crowbar (owner answer), one control per job (the toggle that shared a job with LT goes away), twin-stick unchanged.

### J7. Pad ownership made visible (about 3 hours) - must
- Build: when a window first claims or re-claims its pad, send a short dual-rumble pulse (about 250 ms at 0.6) to that pad only and show a 2 second lower-case tag near the player ("p1" in amber, "p2" in cyan). Make the pause menu entry that swaps pad order reachable by pad. The owner assignment rule stays (first pad = player 2, second = player 1).
- Test: two stub pads connected in order A, B give player 2 pad A and player 1 pad B; the pulse spy fires on the correct pad index and tag shows in the right window; unplug A and replug: the same player regains it and the other pad gets no pulse. Rig: three trials with pads connected before page load and after.
- Rules respected: P1 amber, P2 cyan, lower case, pad 1 = P2.

### J8. Disconnect and reconnect (about 3 hours) - must
- Build: detect loss by polling (slot null or connected false), since the disconnect event goes only to the focused window. Pause box text in lower case ("pad lost"), then on the same slot returning show "press a" and resume on A (the press is also what Chrome needs to expose the pad again). The other player's window shows a small "p2 pad lost" banner. Do not let the other pad take over the slot.
- Test: stub getGamepads returning null for a slot: the box shows within 2 frames; stub returns the pad: the box changes to "press a"; a stub A press closes it and play resumes; test the two-window case with one stub pad lost.
- Rules respected: one control per job (A confirms), lower case, no text wall.

### J9. Trigger hysteresis (about 1 hour) - should
- Build: RT and LT turn on above 0.35 and off below 0.25. The old RS toggle gating goes away with J6.
- Test: feed 0.30, 0.40, 0.34, 0.36, 0.30, 0.20 to RT: exactly one press edge and one release edge; a semi-auto gun fires once (old code fires twice).
- Rules respected: no new control.

### J10. Menu stick threshold and D-pad repeat (about 2 hours) - should
- Build: menu stick steps when the post-deadzone push is above about 0.35 to 0.45 (target raw about 0.5 at any deadzone setting). A held D-pad repeats after about 0.4 s at about 0.1 s per step. Applies to padMenu only, not gameplay.
- Test: stub stick at raw 0.52 steps focus at LARGE and HUGE deadzones; stub D-pad down held 1.2 s steps about 8 times; a tap steps once.
- Rules respected: no new control.

### J11. Real controller pictures (about 4 hours) - should
- Build: draw a small D-pad icon with the pressed arm lit, a stick icon (circle with a direction mark, L or R), keep the coloured ABXY buttons, and raise in-world prompts from 0.6 scale so a glyph is readable at couch distance (starting suggestion: glyph at least 32 px tall at 1080p, to be judged on a screenshot).
- Test: 1080p and 4K screenshots of the pause legend, title row and an in-raid prompt; replace every text-only "D-DOWN" / "L STICK" with icons; glyphs follow the P.padmap bindings after a rebind.
- Rules respected: Xbox only, live prompts, lower-case labels, no tutorial text wall.

### J12. Aim reach follows the weapon (about 3 hours) - should
- Build: D-left/D-right maximum becomes the equipped gun's effective range (up to 900) instead of 520; show a short tick or segment on the aim line while the control is held; save the last reach in the profile.
- Test: with a pistol, a rifle and a DMR equipped, hold D-right 3 seconds: reach equals each gun's range (the DMR passes 520); reload the page: reach restored; reticle stays inside the canvas (padCursorPut clamp) at max reach.
- Rules respected: one control per job (D-left/D-right keep their job).

### J13. Lefty stick swap (about 3 hours) - should
- Build: a settings option that swaps the axis pairs (left stick aims, right stick moves) before any other pad logic. The item wheel follows the aim stick, labels and legends say which stick; the preset researcher's lefty column expects the clicks to follow the swapped sticks.
- Test: with the swap on, a stub left-stick deflection aims and a right-stick deflection walks; wheel selection uses the aim stick; menu stepping still works from the physical left stick; a legend screenshot reads correctly.
- Rules respected: binding lefty rule, always twin-stick.

### J14. Mapping guard, wake hint, hold-to-craft (about 3 hours) - should
- Build: (a) if gamepad.mapping is not "standard", show one lower-case line ("use an xbox pad") once. (b) on the title with no pad seen, a one-line "press any button on your pad" hint that clears at the first press. (c) hold-to-craft requires the same short hold on a pad as on the mouse, with the progress ring.
- Test: stub mapping "" shows the line; stub "standard" does not; no pad seen for 5 seconds shows the hint and a stub press hides it; stub A tap does not craft, hold crafts at the expected time.
- Rules respected: no tutorial text walls (one short line each), one control per job.

### J15. Newcomer test on the rig (about 3 hours, after the cutoff) - must
- Build: nothing. Run five people who have not seen the game, each with only a pad, from the title through one raid to extract, on the real two-window rig. Two rounds (around Mon 2026-10-26 and Wed 2026-10-28). Note where each one stalls or pauses.
- Test: a short list of stall points ranked by how many people hit them; fixes only, before the Thu 2026-10-29 lock.
- Reason: Zero Sievert carries full-support and Deck Verified badges and still gets a 159-vote negative pad review, so a badge or a checklist is not a substitute [Z23].
- Rules respected: no party extras.

---

## 5. Things to avoid (what players hated)

- A pad mode that works only in a raid, or needs a mouse for the main and pause menus (Duckov translation mod) [D7].
- Pad-to-keyboard translation. Custom keybinds break it, slots are unreachable, and aiming and cursors feel fiddly (Duckov) [D7].
- Needing a touchscreen or a config menu to turn pad support on (DuckDuckCon first launch, unconfirmed) (U) [D8].
- Quick-move that drags the cursor into the other container (Zero Sievert, still an open known issue in Sept 2026) (C) [Z8].
- B that does not mean back (Zero Sievert until April 2026) [Z4].
- Keyboard prompts shown on a pad and no in-game pad layout (Zero Sievert 2025 reviews; the current state is unconfirmed) [Z25][Z10].
- Axial deadzones, aim that snaps to straight lines, a sensitivity that is 1:1 and too fast (Ascent, Zero Sievert, single reports; Sutphin on the maths) (N) [T8][T23].
- A stick click for a time-critical action without testing it (Alienation R3 reload) (N) [T11].
- Sharing interact with attack or skill buttons (PoE2, Diablo IV) (N) [T17][T21].
- Hidden mode toggles that change what A does (Destiny 2 vault mode) (N) [M15].
- Bulk destroy buttons with no safeguard (Diablo IV Salvage All) (N) [M17].
- Any stray input from an unassigned device creating a player (Helldivers 1) [H9].
- Urgent actions behind multi-press D-pad codes (Helldivers Reinforce, 5 presses on a mushy Xbox 360 D-pad) [H4][H10].
- Tap versus hold confusion on one button (Helldivers Y) [H10].
- Nearest-enemy-only lock that ignores walls (Hotline Miami console) (N) [T13].
- A virtual cursor on a grid backpack (Delta Force patch history, Grim Dawn thread) (N) [M2][M10].
- Aim reach shorter than the weapon (a Zero Sievert 2025 complaint) [Z5].
- A platform badge treated as a pad test (Zero Sievert) [Z23].
- Friendly fire as a default for new guests (Helldivers 1 reviewers called some moments cheap). Our rule is no team damage, so this stays out [H17].

---

## 6. Fact-check notes and open questions

### 6.1 Fact-check changes applied

Corrected or dropped:
- Zero Sievert dev reply about the cursor and aim assist: the review is Aug 14 2025 and the reply Aug 15 2025, not 2026. It predates the April 2026 assist rework and is not used as the current aim model. (wrong, corrected)
- Zero Sievert 2026-04-23 post: it is titled "Hotfix for the Hotfix". The earlier "death crash" claim is dropped.
- Zero Sievert Sept 2026 review: the review is Sep 10 2026, the dev reply is Sep 14 2026. The quarter-screen aim bug is "new to us" per the dev. Dates in the table use these.
- Chrome polling cadence: current Chromium main polls devices about every 4 ms (about 250 Hz), not about 60 Hz. Pages still see a fresh state only when they call getGamepads() (once per frame). (outdated, corrected) [P18]
- Chromium feature flags for Windows Gaming Input and raw-input events: the flag claims were stale and are dropped. Microsoft's sentence that a Windows app must have focus to receive controller input is confirmed. Which Windows back end Chrome uses on the party PC is unconfirmed, so the rule stays: keep a Chrome window focused and test (J1).
- Venturelli: the 12 degrees per frame figure is an example of very fast rotation, not a tuned value; the 0.3 deadzone appears only in sample code. We do not copy either number.
- XInput stock deadzones are 7849, 8689 and 30, about 0.24, 0.265 and 0.12. "0.27" in the source is a rounding.

Unconfirmed (do not build on them):
- DuckDuckCon details (stick and trigger layout, R3 aim scheme swap, assist off by default, F8 menu, 60% coverage, inventory scheme with bumper panel jumps). Only confirmed: it exists (author Mwolf, thread posted 2025-12-04) and describes pad navigation in most of the UI, twin-stick aim with optional assist, vibration and bindable buttons.
- Helldivers 1 beacon throw trigger, grenade button (LT or LB, the wiki contradicts itself), and stratagem cancel (Y or the stratagem input).
- Helldivers 1 reload discarding the rest of the magazine (the wiki confirms only the early-reload speed gain and a kept chambered round, and a slower empty reload).
- Helldivers 1 melee on Xbox B (the wiki says Q on keyboard and remappable to R1 on Steam).
- Zero Sievert Locked and Loaded update: Collect interaction, auto ammo switching and hold-to-sprint default are confirmed. "Cursor behaviour improvements" and "auto-close chest on damage" were not seen. Dates are within one day (Aug 12 or 13; hotfix Aug 19 or 20).
- Zero Sievert Deck "Playable on SteamOS", "11 reviews call the badge undeserved", and the 2026-08-16 Deck LT-stuck report were not checked.
- Zero Sievert in-game pad remapping and a pad sensitivity slider as of Oct 2026. A 2025 report said none.
- Exit the Gungeon 2.0.6 date (one source says 19 April 2020).
- Whether the raw gamepad input event ships in stable Chrome.

Not fact-checked (source confidence kept): The Ascent, Nex Machina, Alienation, Ruiner, Hotline Miami, Nuclear Throne, Diablo IV, Diablo II Resurrected, Path of Exile 2, The Division 2, Destiny 2, ARC Raiders, Delta Force, Dark and Darker, Marathon, Halo, Gears, the Bevy and radial-menu blog guidance, the Duckov co-op mod and Workshop listings, and my own Zero Sievert review keyword counts.

Confirmed by the fact-check and relied on: Duckov has no native pad support (store data, FAQ, reviews through 2026-10-11); Duckov Controller Support mod bindings (guide dated 2025-11-11, tested on DualShock, DualSense and Xbox One pads; author name and Workshop id not verified); Zero Sievert 0.41 pad launch and its 2026-04-17/22 changes; Zero Sievert Deck Verified and store data; Helldivers 1 layout basics, Reinforce code and cooldowns, patch dates 4.1.3, 4.1.4, 4.1.9 and 1.03, four local players; W3C Gamepad visibility and index rules; Chromium non-foreground access statements; haptics browser support (dual-rumble Chrome 68+, trigger-rumble Chrome 126+, experimental); Sutphin's article; Xbox guidelines 107 and 112 and Deck Verified rules; Enter the Gungeon 2.0.0 assist options and the dev reticle quote.

One conflict with a binding rule: Xbox Accessibility Guideline 107 says games should not require two sticks. The always-twin-stick rule stands. The mitigations we use are the lefty swap, sensitivity sliders, and the existing kid-firing option.

### 6.2 Open questions

Game questions for the owner:
1. Crowbar on right stick click: if newcomers fire it by accident in the J6 test, which fallback do you prefer: a short click-and-hold, or moving melee to another button in the presets?
2. When the right stick is released while the left stick moves, aim now swings to the walk direction (your v6.85 order). Should it hold its last angle for a short moment so a brief let-go mid-fight does not swing the aim? (The Ascent follows walk direction; PoE2 players ask for persistent aim; Relic Hunters warns that decaying offsets feel unpredictable.)
3. If one player's pad drops in a two-window raid, should the other window pause too, or keep running with a "pad lost" banner?
4. Gun switching with up to nine gun keys: is stepping with LB/RB enough for the demo, or do you want a held-button gun wheel? All 16 buttons already have jobs, so a new one would take over an existing job.
5. Should the aim distance be tied to the gun's range and remembered between raids (J12 assumes yes)?
6. Roll on A pulls the right thumb off the aim stick. Fine for the default preset, or should the default move roll to a bumper or trigger? The preset researcher's "top-down veterans" column already has roll on LT.

Research gaps (what we still do not know):
- Does an unfocused but visible Chrome window keep getting pad data on the party PC? Do two Xbox pads report different ids? Do pads sleep when idle? Does trigger-rumble work on a Series pad over Bluetooth? (J1 answers all four.)
- Whether the first raid already shows a one or two button at a time live prompt order (Helldivers taught the complex system last). Not audited.
- Whether the prompt strip is consistent on every screen (C19). Not audited.
- Zero Sievert's pad aim numbers (cursor tether, assist default, curve), in-game remap and sensitivity as of 2026.
- Duckov Workshop pages (DuckDuckCon, DuckovPad, GameControllerSupport, Intelligent Aim Assist) returned errors and were not read directly; Reddit was not reachable for any game.
- ARC Raiders' quick-move and multi-select pad buttons, and what its "updated default gamepad mapping" (Frozen Trail 2.0, 2026-10-08) changed.
- PoE2 default roll button; Enter the Gungeon default layout; Hades pad notes; aim assist in Helldivers 1 (no evidence either way).
- Whether Chrome applies any deadzone before exposing axes (no source says so, so the game's deadzone is the only one).
- How our own drop or sell actions in the stash protect against accidents (Diablo IV lost a rare item to a bulk button). Not audited.

---

## 7. Sources

Escape from Duckov
- [D1] https://store.steampowered.com/api/appdetails?appids=3167020&cc=us&l=english
- [D2] https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=3167020&count=40&maxlength=0&format=json
- [D3] https://store.steampowered.com/appreviews/3167020?json=1&language=english&filter=recent&review_type=all&purchase_type=all&num_per_page=100&day_range=60
- [D4] https://steamcommunity.com/app/3167020/discussions/0/600791791481045166/
- [D5] https://store.steampowered.com/saleaction/ajaxgetdeckappcompatibilityreport?nAppID=3167020
- [D6] https://steamdeckhq.com/game-reviews/escape-from-duckov/
- [D7] https://allthings.how/escape-from-duckov-controller-mod-set-up-partial-gamepad-support/
- [D8] https://steamcommunity.com/app/3167020/discussions/0/688617061539188107/
- [D9] https://www.keengamer.com/de/artikel/international-de/anleitungen-de/escape-from-duckov-wie-man-die-multiplayer-mod-koop-installiert/
- [D10] https://www.thesixthaxis.com/2025/11/06/escape-from-duckov-update-1-1-6-released-read-the-patch-notes-here/
- [D11] https://steamcommunity.com/app/3167020/discussions/0/598541076225195095/
- [D12] https://steamcommunity.com/app/3167020/discussions/0/596289845781065532/
- [D13] https://steamcommunity.com/app/3167020/discussions/0/598540711281867405/
- [D14] https://steamcommunity.com/app/3167020/discussions/0/685238092472265053/
- [D15] https://steamcommunity.com/app/3167020/discussions/0/598540711281883055/
- [D16] https://steamcommunity.com/app/3167020/discussions/0/596289460456681461/
- [D18] https://store.steampowered.com/appreviews/3167020?json=1&language=english&filter=all&review_type=all&purchase_type=all&num_per_page=100&day_range=365
- [D17] https://steamcommunity.com/workshop/browse/?appid=3167020&searchtext=controller&browsesort=trend&section=readytouseitems

ZERO Sievert
- [Z1] https://steamcommunity.com/games/1782120/announcements/detail/5688680204366919674
- [Z2] https://steamdeckhq.com/wp-content/uploads/2024/02/ControllerSupportZeroSievert.jpg
- [Z3] https://steamcommunity.com/games/1782120/announcements/detail/1830163047261078
- [Z4] https://steamcommunity.com/games/1782120/announcements/detail/1830797770231540
- [Z5] https://steamcommunity.com/profiles/76561198062622366/recommended/1782120/
- [Z6] https://steamcommunity.com/games/1782120/announcements/detail/5395937983661490726
- [Z7] https://steamcommunity.com/games/1782120/announcements/detail/5395937983678981105
- [Z8] https://steamcommunity.com/profiles/76561198057570620/recommended/1782120/
- [Z9] https://steamcommunity.com/app/1782120/discussions/0/4309453072034993555/
- [Z10] https://steamcommunity.com/app/1782120/discussions/0/594027165435057552/
- [Z11] https://steamcommunity.com/games/1782120/announcements/detail/6240387642450973741
- [Z12] https://store.steampowered.com/saleaction/ajaxgetdeckappcompatibilityreport?nAppID=1782120
- [Z13] https://steamcommunity.com/games/1782120/announcements/detail/1846018067927203
- [Z14] https://store.steampowered.com/api/appdetails?appids=1782120&cc=us&l=english
- [Z15] https://steamcommunity.com/games/1782120/announcements/detail/6212245217911792617
- [Z16] https://steamcommunity.com/games/1782120/announcements/detail/1840944183777348
- [Z17] https://steamcommunity.com/games/1782120/announcements/detail/1841579228665870
- [Z18] https://steamcommunity.com/games/1782120/announcements/detail/1785321795738416
- [Z19] https://steamcommunity.com/games/1782120/announcements/detail/1803527891515258
- [Z20] https://store.steampowered.com/appreviews/1782120?json=1&filter=recent&language=english&num_per_page=100&review_type=all
- [Z21] https://steamcommunity.com/app/1782120/discussions/0/801217828677047833/
- [Z22] https://steamcommunity.com/app/1782120/discussions/0/4291439320496193831/
- [Z23] https://steamcommunity.com/profiles/76561198139094529/recommended/1782120/
- [Z24] https://steamdeckhq.com/news/zero-sievert-gets-improved-controller-and-steam-deck-optimization-in-new-update/
- [Z25] https://steamcommunity.com/profiles/76561198031568730/recommended/1782120/
- [Z26] https://steamcommunity.com/app/1782120/discussions/0/4753074677210522438/
- [Z27] https://steamcommunity.com/profiles/76561198863918284/recommended/1782120/
- [Z28] https://www.gamingonlinux.com/2024/02/single-player-extraction-shooter-zero-sievert-adds-controller-support/page=1/
- [Z29] https://steamcommunity.com/profiles/76561199434313689/recommended/1782120/
- [Z30] https://steamdeckhq.com/news/zero-sievert-radial-menu-fixes-steam-deck-controls/

Helldivers 1
- [H1] https://helldivers.wiki.gg/wiki/Helldivers_1:Training
- [H2] https://helldivers.wiki.gg/wiki/Helldivers_1:Encyclopedia
- [H3] https://helldivers.wiki.gg/wiki/Helldivers_1:Stratagems
- [H4] https://helldivers.wiki.gg/wiki/Helldivers_1:Reinforce
- [H5] https://helldivers.wiki.gg/wiki/Helldivers_1:Weapons
- [H6] https://helldivers.wiki.gg/wiki/Helldivers_1:4.1.9
- [H7] https://helldivers.wiki.gg/wiki/Helldivers_1:1.03
- [H8] https://steamcommunity.com/app/394510/discussions/0/492379159718635900
- [H9] https://steamcommunity.com/app/394510/discussions/0/144512753469050073
- [H10] https://steamcommunity.com/app/394510/discussions/0/494632768624465879
- [H11] https://steamcommunity.com/app/394510/discussions/0/492379439676798252
- [H12] https://steamcommunity.com/app/394510/discussions/0/6792047411323890696
- [H13] https://steamcommunity.com/app/394510/discussions/0/412446250038758244
- [H14] https://store.steampowered.com/api/appdetails?appids=394510&cc=us&l=english
- [H15] https://gamingtrend.com/reviews/up-down-left-right-left-down-dead-helldivers-review/
- [H16] https://gameinformer.com/games/helldivers/b/playstation4/archive/2015/03/03/helldivers-review-game-informer.aspx
- [H17] https://www.gamerevolution.com/review/67137-helldivers-review
- [H18] https://quartertothree.com/fp/?p=31299
- [H19] https://blog.playstation.com/2024/03/12/helldivers-2-how-arrowhead-turned-the-twin-stick-shooter-original-into-a-bombastic-ps5-sequel/
- [H20] https://digitallydownloaded.net/2015/03/review-helldivers-sony-playstation-4.html
- [H21] https://helldivers.wiki.gg/wiki/Helldivers_1:Advanced_Gameplay_Techniques
- [H22] https://helldivers.wiki.gg/wiki/Helldivers_1:Loading_Screen_Tips
- [H23] https://helldivers.wiki.gg/wiki/Helldivers_1:3.02

Other twin-stick and top-down games
- [T1] https://steamcommunity.com/app/311690/discussions/0/371918937279507167
- [T2] https://steamcommunity.com/app/311690/discussions/0/1711815918578469582
- [T3] https://enterthegungeon.wiki.gg/wiki/Dodge_Roll_(Move)
- [T4] https://gonintendo.com/archives/333473-exit-the-gungeon-updated-to-version-2-0-6
- [T5] https://outsidergaming.com/the-ascent-controls-guide-for-xbox-one-series-xs-and-pc/
- [T6] https://www.gamecell.co.uk/reviews/the-ascent
- [T7] https://caniplaythat.com/?p=9903
- [T8] https://steamcommunity.com/app/979690/discussions/0/3050611379019619136
- [T9] https://eip.gg/reviews/nex-machina-ps4-review/
- [T10] https://www.theouterhaven.net/2017/06/nex-machina-pc-review
- [T11] https://thesixthaxis.com/2016/04/25/alienation-review
- [T12] https://www.theouterhaven.net/2017/09/ruiner-pc-review
- [T13] https://egmnow.com/egm-review-hotline-miami-ps3-vita-version/
- [T14] https://blog.playstation.com/2021/08/13/diablo-ii-resurrected-crafting-the-controller-experience
- [T15] https://news.blizzard.com/en-us/article/23954932/combatting-demons-with-accessibility-in-diablo-iv
- [T16] https://www.wowhead.com/diablo-4/blue-tracker/news/us/the-diablo-iv-season-4-ptr-what-you-need-to-know-24078324
- [T17] https://wp-prod.icy-veins.com/diablo-4-tips-on-how-to-fix-clunky-controller-layout/
- [T18] https://www.pathofexile.com/forum/view-thread/3696353/page/1
- [T19] https://www.pathofexile.com/forum/view-thread/3717308/page/1
- [T20] https://www.pathofexile.com/forum/view-thread/3627863
- [T21] https://www.pathofexile.com/forum/view-thread/3658581
- [T22] https://www.gamedeveloper.com/design/everything-i-learned-about-dual-stick-shooter-controls
- [T23] https://www.gamedeveloper.com/disciplines/doing-thumbstick-dead-zones-right
- [T24] https://steamcommunity.com/app/242680/discussions/0/305510202674451789
- [T25] https://steamcommunity.com/app/394510/discussions/0/2741975115063658912
- [T26] https://steamcommunity.com/app/1145350/discussions/0/4327475903877791642
- [T27] https://steamcommunity.com/app/311690/discussions/0/359547436761809657
- [T28] https://steamcommunity.com/app/979690/discussions/0/3044982312820950048
- [T29] https://us.forums.blizzard.com/en/d4/t/improving-controller-usability-in-diablo-4-for-consoles/190976

Menus, inventories and extraction games
- [M1] https://steamcommunity.com/app/1782120/discussions/0/4291439320496193831/
- [M2] https://updatecrazy.com/delta-force-update-1-037-108-patch-notes-ahsarah-update/
- [M3] https://arcraiders.com/news/cold-snap-patch-notes
- [M4] https://allthings.how/arc-raiders-pc-split-item-stacks-with-alt-drag-plus-console-buttons/
- [M5] https://arcraiders.com/news/frozen-trail-2-0-update
- [M6] https://arcraiders.wiki/wiki/Augments
- [M7] https://www.gfinityesports.com/article/arc-raiders-is-great-but-this-missing-feature-is-holding-it-back-from-being-a-1010
- [M8] https://steamcommunity.com/app/2016590/discussions/0/4344366409320487234
- [M9] https://www.pathofexile.com/forum/view-thread/3619338/page/1
- [M10] https://forums.crateentertainment.com/t/controller-ui-also-options-misc/112665
- [M11] https://learn.microsoft.com/en-us/windows/apps/design/input/gamepad-and-remote-interactions
- [M12] https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/112
- [M13] https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/107
- [M14] https://partner.steamgames.com/doc/steamdeck/compat
- [M15] https://www.destructoid.com/?p=619158
- [M16] https://devtrackers.gg/the-division/p/b056d532-dismantling-gear
- [M17] https://mein-mmo.de/en/diablo-4-alles-schreddern-season-4,1130989
- [M18] https://www.destructoid.com/?p=370418
- [M19] https://news.blizzard.com/en-us/article/23788293/diablo-ii-resurrected-patch-2-4-ladder-now-live
- [M20] https://300mind.studio/blog/radial-menus-in-game-design/
- [M21] https://hackmd.io/@bevy/BJeSeclbSkg
- [M22] https://steamcommunity.com/app/1808500/discussions/0/811335793676415254/
- [M23] https://www.bungie.net/en/Forums/Post/265077981
- [M24] https://www.gamespot.com/reviews/marathon-review-in-progress-incredible-highs-painful-lows/1900-6418472/

Platform, accessibility and engineering (tag P) and co-op join threads (tag S)
- [P1] https://www.w3.org/TR/gamepad/
- [P2] https://lists.w3.org/Archives/Public/public-webapps-github/2024Sep/0476.html
- [P3] https://github.com/w3c/gamepad/issues/215
- [P4] https://learn.microsoft.com/en-us/uwp/api/windows.gaming.input
- [P5] https://raw.githubusercontent.com/mdn/browser-compat-data/main/api/GamepadHapticActuator.json
- [P6] https://groups.google.com/a/chromium.org/g/blink-dev/c/ncvmDRl0AzM/m/z4v34arEAQAJ
- [P7] https://learn.microsoft.com/en-us/windows/win32/xinput/getting-started-with-xinput
- [P8] https://www.gamedeveloper.com/design/interpreting-analog-sticks-in-inversus
- [P9] https://www.gearsofwar.com/en-gb/games/gears-5/accessibility/
- [P10] https://learn.microsoft.com/en-us/xbox/accessibility/xag-version-history
- [P11] https://gameaccessibilityguidelines.com/full-list/
- [P12] https://partner.steamgames.com/doc/steamhardware/compat
- [P13] https://partner.steamgames.com/doc/features/steam_controller/getting_started_for_devs
- [P14] https://gamedeveloper.com/design/the-5-golden-rules-of-input
- [P15] https://docs.unity3d.com/Packages/com.unity.inputsystem@1.8/manual/PlayerInputManager.html
- [P16] https://halopedia.org/HINF:Control_schemes
- [P17] https://github.com/MicrosoftEdge/MSEdgeExplainers/blob/main/GamepadEventDrivenInputAPI/explainer.md
- [P18] https://chromium.googlesource.com/chromium/src/+/refs/heads/main/device/gamepad/gamepad_provider.cc
- [P19] https://raw.githubusercontent.com/chromium/chromium/main/device/gamepad/public/cpp/gamepad_features.cc
- [P20] https://lists.w3.org/Archives/Public/public-webapps-github/2020Jun/0361.html
- [S20] https://steamcommunity.com/app/531510/discussions/0/1698300679760563901
- [S21] https://steamcommunity.com/app/1432050/discussions/0/4029095737382723818
- [S22] https://steamcommunity.com/app/979690/discussions/0/3044982312816802069
- [S23] https://forums.larian.com/ubbthreads.php?ubb=showflat&Number=880764
- [S24] https://steamcommunity.com/groups/SteamClientBeta/discussions/3/1640919103683182916
