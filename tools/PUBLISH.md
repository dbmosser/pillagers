# Publishing PILLAGERS on itch.io

Rewritten 2026-10-21 (coordinator job coord-04) to his release answers 71 to 79 (tools/handoff/q-process/answers.md).

## The plan (his answers)

- Where: itch.io now, Steam later (71 b).
- Price: pay what you want (72 b). On itch that is Pricing "$0 or donate".
- Between the party (Fri 10/30) and Thanksgiving: friends and family on a private link (73 a).
- Release: Thanksgiving, Thu 11/26, the page goes public that day.
- Modes: both, couch mode up front; his note: couch mode IS career mode (76).
- Page text: keep it bare (75 c). No trailer or moving picture (77). No devlog (78 b).
- Later, not for 11/26: the feedback collector that sends friends' run reports by itself (74 b), and moving saves between computers (79 b).

## How the build gets to itch (automatic)

The game is one self-contained HTML file. tools/itch-zip.ps1 builds tools/publish/pillagers-web.zip:
index.html (the game), the title's attract clip when there is one, and the licence texts (below).
Every ship (tools/handoff/ship.sh) and the once-a-day catch-up (tools/itch-daily.sh) push that zip with butler to ITCH_TARGET.
The butler key lives in his Windows user environment; it is never printed. He never uploads by hand.

## The itch page settings (set once on the page)

- Kind of project: HTML. The zip is played in the browser.
- Viewport 1920 x 1080 (he plays at 1080p and on 4K TVs), with the fullscreen button on.
- Visibility: Restricted with a password (or the draft's secret link) until 11/26, then Public.
- Pricing: "$0 or donate" (pay what you want).

## His three steps, with dates

The coordinator tells him each one in chat on the day, one or two plain lines with the reason (his answer 99: give context):
1. After the party, from Sat 10/31: share the private link or the page password with friends and family.
2. Well before 11/26, because payouts take days to clear: in his itch account settings, set up payments and payouts (PayPal or
   Stripe) and fill in the tax form, then set the page's Pricing to "$0 or donate".
3. On Thu 11/26: set the page's Visibility to Public.

## Page text (bare, lower case, as the game's own text rule)

    pillagers
    ascend. pillage. extract.
    1 or 2 players on one pc. pad or keyboard and mouse.
    play in fullscreen.

## What friends should know

- Saves live in their own browser. Clearing browser data erases them. Settings has "back up your progress", which saves a file.
- Run reports are not sent by themselves yet (74 b). The game saves pillagers_runN.txt to their Downloads; if they send those
  files, put them in exports/ and they are read like his own.
- His own save on http://localhost:8802 is not touched by any of this.

## Open risk

- The 2-player same-machine mode links its two windows over a BroadcastChannel. Inside itch's frame Chrome may keep the frame and
  the player 2 window apart, so couch mode may not link on itch at all. Not tested yet: coordinator job coord-06
  (tools/handoff/console/staging-1020/coord-06-itch-iframe-2p-test.md). It must be settled before 11/26.

## Fonts (2026-10-12)
The game embeds Barlow Condensed, Barlow, IBM Plex Mono, Titan One and Rubik (SIL Open Font License 1.1). The itch zip must carry tools/fonts/OFL-*.txt (all five) beside the game; since 10-20 tools/itch-zip.ps1 packs them, and the sound licences, for every ship and the daily push. The Titan One and Rubik copyright lines were read from the fonts embedded in the game.

## Sounds (2026-10-12)
The game embeds 23 CC0 sound recordings (SFXBANK: Kenney, and zer0_sol, SpringySpringo, BMacZero, OwlishMedia and AntumDeluge on OpenGameArt). The itch zip must carry tools/sounds/LICENCES.txt and the four kenney_*_License.txt files beside the game, the way it carries the font licences.
