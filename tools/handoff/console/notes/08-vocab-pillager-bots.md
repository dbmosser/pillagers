# 08-vocab-pillager-bots (lane a) — SHIPPED v31.64 (fa4c356e), cw-vocab-bots

Fixture retargets committed first (6fd7de35): board-title regex, nB in 23.35, extraction callout line, sound-key need list, board header skip. All tolerant of old and new wording.

## Strings changed (before -> after)
- UNITPLURAL.raider 'pillagers' -> 'pillager bots'; UNITNAME.raider 'pillager' -> 'pillager bot'; KINDWORD.raider 'PILLAGER' -> 'PILLAGER BOT'
- 'Word has spread. Hires cost more and pillagers trust you less.' (+ the shorter one) -> pillager bots
- keys legend 'search in a ring; hold to finish a pillager' (kbd + pad) -> '... pillager bot'
- 'A PILLAGER' (thrown charge kill-feed name) -> 'A PILLAGER BOT'
- callouts: PILLAGER REINFORCEMENTS / TURNED HOSTILE / CALLED EXTRACTION -> PILLAGER BOT ...
- label ' DOWNED' fallback and revive prompt fallback: 'PILLAGER' -> 'PILLAGER BOT' (bot name fallback only; the teammate prompt at netSeatName is a real player and stays 'PILLAGER')
- heat terms: '40% more machines, pillagers and criers.' / 'Every pillager is hostile...' -> pillager bots
- run report: '|  AI pillagers extracted: ' -> '|  Pillager bots extracted: '
- sound key: 'pillager moving/firing' -> 'pillager bot moving/firing'
- board: 'CURRENT PILLAGERS  ' (two draws) -> 'CURRENT PILLAGER BOTS  '
- settings: 'AI pillagers' -> 'Pillager bots'; 'Seconds a pillager must hold the ring' -> '... pillager bot ...'; 'Pillager crews feud (0 truce)' -> 'Pillager bot crews feud (0 truce)'; 'Min pillagers alive' -> 'Min pillager bots alive'
- game option label 'Other pillagers' -> 'Pillager bots'
- 'No Data Core...elite pillagers.' -> elite pillager bots
- roadmap: bush hint ('raiders who hide' -> 'pillager bots who hide'), 'Pillagers play like people', 'Plain-language raid settings: pillagers', 'Pillagers that equip', 'every pillager on the board', 'a pillager walking out tries a revive', 'His ruling on the pillagers' -> pillager bot(s)
- 'Half the pillagers down here walk past scrap' -> pillager bots
- viewer chip <span class=vpill>PILLAGER</span> -> PILLAGER BOT
- achievement 'Kill 25 pillagers in all.' -> pillager bots; contract '3 PILLAGERS' -> '3 PILLAGER BOTS'
- heat tip 'a pillager who had not fought you' -> pillager bot; 'Pillagers need ...' -> 'Pillager bots need ...'
- bounty event 'BOUNTY PILLAGER' (name and claim chip) -> 'BOUNTY PILLAGER BOT'

## Left alone (his edited lines = keys in TXSHIP; changing the key text would drop his wording) — for the coordinator
- TXSHIP key 'Beware of hostile robots and fellow pillagers.' (his value: 'Loot all the things. Beware of hostile robots and fellow pillagers.') — means AI ones; his line, untouched.
- TXSHIP key 'A friend sends you their exported run report... a pillager wearing their name...' (his value keeps 'a pillager wearing their name') — means a bot hire; untouched.
- TXSHIP key 'Nobody out there has a problem with you... a pillager who had not raised a hand to you.' — untouched.
- map line at ~5157 'A pillager walking out will step past a downed crewmate...' (his edited override) — untouched.
- feedback tag chips 'Pillagers felt human' / 'Pillagers felt dumb' — his tags, the pillager camera is named for the second; untouched. They mean the AI ones; ask him if he wants 'pillager bots felt ...'.
- armour set 'raider' (setraid) — gear name, untouched as ordered.
- dev sound lab labels 'BOUNTY PILLAGER: announce / bounty paid' (SPK_INFO) — dev screen, not changed.
- dated history patch notes — unchanged as ordered.
- Not seen: any other 'raider' on screen; the grep of quoted strings found only the bush hint.
