# 08-vocab-pillager-bots (lane a)

Plan: one ship, key cw-vocab-bots, script S/mk-cw-vocab-bots.ps1. Text-only edits (anchors are literal strings).
Fixture retargets (under lock, then fixq): checks that read old text: line ~5724 (/^CURRENT PILLAGERS/), ~30214, ~40207 (nB), ~42071 (PILLAGER CALLED), ~84569 (sound key words), ~92465, ~47918 (death card PILLAGER).

## Strings to change (game file) before -> after
- UNITPLURAL raider 'pillagers' -> 'pillager bots'; UNITNAME raider 'pillager' -> 'pillager bot'; KINDWORD raider 'PILLAGER' -> 'PILLAGER BOT'
- hire note 'Word has spread. Hires cost more and pillagers trust you less.' (both copies) -> pillager bots
- legend rows (two copies) 'hold to finish a pillager' -> 'pillager bot'
- callouts PILLAGER REINFORCEMENTS / TURNED HOSTILE / CALLED EXTRACTION -> PILLAGER BOT ...
- fallback label (e.name||'PILLAGER')+' DOWNED' and REVIVE fallback -> 'PILLAGER BOT'; 'A PILLAGER' charge fallback -> 'A PILLAGER BOT'
- TERMS descs '40% more machines, pillagers and criers.' / 'Every pillager is hostile ...' -> pillager bots
- run report '|  AI pillagers extracted: ' -> '|  Pillager bots extracted: '
- sound key 'pillager moving' / 'pillager firing' -> 'pillager bot ...'
- board titles CURRENT PILLAGERS (2 places) -> CURRENT PILLAGER BOTS
- SLIDERS: 'AI pillagers' -> 'Pillager bots'; 'Seconds a pillager must hold the ring' -> 'pillager bot'; 'Pillager crews feud (0 truce)' -> 'Pillager bot crews feud (0 truce)'; 'Min pillagers alive' -> 'Min pillager bots alive'
- GAMEOPTS label 'Other pillagers' -> 'Pillager bots'
- 'No Data Core ... elite pillagers.' -> elite pillager bots; imported friend text 'a pillager wearing their name' -> 'a pillager bot wearing'
- ROADMAP lines (DONE ones hidden, NEXT one shown), bush hint 'raiders who hide in them too' -> 'pillager bots'
- peddler line 'Half the pillagers down here...' -> pillager bots
- hire card tag 'PILLAGER' -> 'PILLAGER BOT'; ach desc 'Kill 25 pillagers' -> 'pillager bots'; notoriety hints (52177, 52183); contract '3 PILLAGERS' -> '3 PILLAGER BOTS'; EVENTS.bounty name 'BOUNTY PILLAGER' -> 'BOUNTY PILLAGER BOT'

## Left alone (list for coordinator)
- ach name 'PILLAGER HUNTER' (kept; reads fine either way)
- 'a pillager walking out will step past ...' dev poll text map (line ~5157, dev-only)
- SPK_INFO 'BOUNTY PILLAGER: ...' sound-editor labels (dev tool)
- 'how to play: Beware of hostile robots and fellow pillagers' and 'hostile robots' not in the build any more (grep finds none)
- setraid armour name; history WHATSNEW entries; comments
- player names / seat fallback 'PILLAGER' (those are real players: right)
