# Controller presets and aim assist (research, sonnet agent, 2026-10-19)

Saved by the coordinator from the agent's report. Pages that were blocked or timed out, so these facts are not directly confirmed:
- Epic's Fortnite controller help (403)
- Prima's ARC Raiders controls (403)
- EA's Apex controls (timeout)
- callofduty.com controls guide (reset)

Unverified items to check before shipping:
- Fortnite's current default preset
- Enter the Gungeon's default pad layout
- Apex's bumper bindings

Owner rule (10-19): every preset is twin-stick. Presets only move buttons; lefty swaps the sticks.

## Source facts
- **Call of Duty (Black Ops 7), Default.** Sources: [Game8](https://game8.co/games/Call-of-Duty-Black-Ops-7/archives/555060), cross-checked by [Shortcut Posters](https://shortcutposters.com/games/call-of-duty-black-ops-7/).

  | Button | Action |
  |---|---|
  | A | jump |
  | B | crouch, slide, dive |
  | X | reload, interact |
  | Y | switch weapon |
  | LB | tactical |
  | RB | lethal |
  | LT | aim down sights |
  | RT | fire |
  | LS click | sprint |
  | RS click | melee |
  | D-up | ping wheel |
  | D-left | fire mode |
  | D-right | scorestreak |
  | View | scoreboard |

  - **Tactical** moves crouch to RS click and melee to a face button (B per GamesRadar, unconfirmed).
- **Minecraft Bedrock.** Source: [minecraft.wiki/w/Controls](https://minecraft.wiki/w/Controls).

  | Button | Action |
  |---|---|
  | A | jump |
  | B | sneak |
  | X | crafting |
  | Y | inventory |
  | LB / RB | hotbar left / right |
  | LT | use / place |
  | RT | attack |
  | LS click | sprint |
  | D-up | perspective |
  | D-down | drop item |

- **Fortnite.** Builder Pro is most likely the default ([Keymap](https://keymap.io/controls/fortnite/), [setup.gg](https://www.setup.gg/game/fortnite/best-controller-settings/)). Its combat buttons are the same as Combat Pro.

  | Button | Action |
  |---|---|
  | A | jump |
  | X | reload, interact |
  | Y | pickaxe |
  | B | build |
  | RB / LB | next / previous weapon |
  | RT | fire |
  | LT | aim |
  | LS click | sprint |
  | RS click | crouch |
  | View | map |
  | D-up | inventory |
  | D-down | emote |
  | D-left | ping |

- **Top-down shooters.**
  - **Enter the Gungeon:** no confirmed official default. Community rebinds converge on LT dodge, RT fire, LB blank, RB active item, and A interact.
  - **Hades:** X attack, A dash, B cast, Y special, RB interact.
  - **Helldivers 1:** RT shoots and the right stick aims. LB throws a grenade; hold LB to enter a stratagem. LS click sprints.
- **ARC Raiders (Xbox).** Sources: [arcraiders.wiki](https://arcraiders.wiki/wiki/Settings) and [magicgameworld](https://www.magicgameworld.com/arc-raiders-controls-guide-all-pc-xbox-ps5-keybinds/).

  | Button | Action |
  |---|---|
  | A | jump |
  | B | crouch; double-tap = roll |
  | X | interact, reload |
  | Y | swap weapon |
  | LB | items |
  | RB | ping |
  | LT | aim |
  | RT | fire |
  | LS click | sprint |
  | RS click | shoulder swap |
  | D-left | melee |
  | D-right | flashlight |
  | D-up | emote |
  | D-down | voice |
  | View | inventory (hold: map) |

- **Halo Infinite and Apex** can share the CoD preset. Their face buttons, triggers and stick clicks match CoD; only the bumpers differ, and those are moot while we have no quick-throw.

## Preset tables (each column uses all 16 buttons exactly once)

Abbreviations:
- **L3 / R3** are the stick clicks.
- **Du, Dd, Dl, Dr** are the D-pad directions.
- **MELEE** is the crowbar (task 18). Until it exists, the MELEE slot stays unbound.
- Bumper actions carry their holds: previous slot = zoom out, next slot = zoom in.

| Our action | pillagers default | call of duty (halo, apex) | fortnite | arc raiders | top-down veterans | lefty |
|---|---|---|---|---|---|---|
| roll | A | A | A | A | LT | RB |
| crouch | B | B | R3 | B | B | B |
| reload / search / open / extract | X | X | X | X | X | X |
| ring search, finish downed | Y | Dd | B | R3 | A | Y |
| previous slot / zoom out | LB | LB | LB | Dr | Y | A |
| next slot / zoom in | RB | Y | RB | Y | RB | LB |
| focus aim (hold) | LT | LT | LT | LT | LB | RT |
| fire / use | RT | RT | RT | RT | RT | LT |
| backpack | View | View | Du | View | View | View |
| pause | Menu | Menu | Menu | Menu | Menu | Menu |
| sprint | L3 | L3 | L3 | L3 | L3 | R3 |
| MELEE | R3 | R3 | Y | Dl | R3 | L3 |
| ping / map | Du | Du | View | RB | Du | Du |
| item wheel / revive | Dd | RB | Dd | LB | Dd | Dd |
| aim distance shorter | Dl | Dl | Dl | Dd | Dl | Dl |
| aim distance longer | Dr | Dr | Dr | Du | Dr | Dr |

**Notes on each preset**
- **Call of Duty:** Y cycles the belt, not two guns. A grenade takes two steps: pick it on the wheel, then fire.
- **CoD Tactical:** a two-swap variant (B = MELEE, R3 = crouch).
- **Minecraft:** differs from the default only by swapping Y and View, so it is not shipped separately.
- **Fortnite:** View taps to ping and holds for the map.
- **ARC Raiders:** we do not copy its double-tap roll.
- **Top-down veterans:** follows community Gungeon binds (roll on a trigger, thumbs on the sticks). The evidence is community rebinds, not an official default.
- **Lefty:** swaps the sticks, and the clicks follow the swapped sticks.

## New actions that would make presets exact
- **Stick swap.** The only truly new one; the lefty preset needs it.
- **Quick-throw** of the selected throwable, on a bumper. Would make CoD, Halo, Apex and Helldivers exact.
- **A separate map button.** Would free ping from the map hold.
- **Quick-heal.** Optional.

## Recommended set
1. pillagers default
2. call of duty
3. fortnite
4. arc raiders
5. top-down veterans
6. lefty

Minecraft would be an optional seventh. It is close to the default.

## Aim assist in top-down twin-stick games

What the games and write-ups do:
- **Enter the Gungeon:**
  - Aim assist is controller-only and can be turned down to off.
  - [Patch 2.0.0](https://www.gonintendo.com/stories/313975-enter-the-gungeon-version-2-0-0-full-patch-notes) added more aim assist options and fixed which objects count as targets. Patch 2.0.6 added Aim To Fire.
  - Aim is direction only. The crosshair sits at a fixed distance and is visual only.
- **Nuclear Throne:** an autoaim percentage setting. It is gamepad only and does nothing with a mouse.
- **Helldivers 1:** no documented aim assist. It uses a laser sight, and players complained about the deadzone.
- **Hades:** on by default. It picks the nearest enemy in the facing direction, and seems to apply on mouse too. A secondary source claims it can snap up to 90 degrees (unverified).
- **Apex:** slowdown plus rotation. One on/off setting, controller only. Season 22 cut it about 25% on PC.
- **[Game Developer twin-stick write-up](https://www.gamedeveloper.com/design/everything-i-learned-about-dual-stick-shooter-controls):**
  - A hidden nudge failed, because a gap built up between the stick and the aim.
  - It shipped a narrow cone of about 30 degrees with a visible snap; the laser changes colour on lock.
  - Project the stick input onto the target first, or the assist gets more accurate at range.
  - Players can toggle auto-aim and sticky slowdown separately.
- **[Rogue Star Rescue devlog](https://chuteapps.itch.io/rogue-star-rescue/devlog/68507/effective-aim-assist-in-2d-shooters):** a cone of 5 raycasts, a 0-100% slider and a minimum target distance. Mouse players usually turn it off.

**Recommended for PILLAGERS.** Only the ~30 degree cone and the stateless, visible-lock principles come from sources. The other numbers are starting values to playtest.

Settings row (lower case): **aim assist: off / light / strong.**
- **Defaults:** light on the pad. Easy mode (if there is one) defaults to strong.
- **Mouse:** always off when the last input was the mouse.
- **Idle stick:** no assist when the stick is idle or below 0.35 deflection.

| Setting | light | strong | easy |
|---|---|---|---|
| cone half-angle around the stick | 15 deg | 25 deg | 32 deg |
| bend: fraction of angle error removed (fades to 0 at the cone edge) | 0.35 (max ~3 deg) | 0.60 (max ~9 deg) | 0.75 (max ~14 deg) |
| friction: aim turn-rate multiplier while on a target | 0.80 | 0.60 | 0.50 |
| aim distance | unchanged | throwables only: ease to the target if within 25% | as strong |

- **Target choice:**
  - Score = 0.65 x (angle / cone) + 0.35 x (distance / range). The lowest score wins.
  - Needs line of sight; walls block.
  - Skip downed, dead and allied pillagers and loot.
  - Barrels count only when no enemy is in the cone.
  - Ignore targets closer than about 1 tile.
  - Keep the lock until a challenger scores 20% better, or line of sight is lost for 0.2 s.
- **Stateless:** recompute the bend from the live stick angle every frame, with no stored offset. Ease it out over 120 ms when the target is lost.
- **Flicks:** no friction when the stick turns faster than about 300 deg/s.
- **Focus aim held:** multiply friction by 0.85.
- **Feedback:** tint the reticle or laser and outline the locked target.
- **Crowbar:** optional lunge toward the nearest enemy within 45 deg.
