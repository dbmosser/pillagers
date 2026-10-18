# 08-vocab-pillager-bots : players are pillagers, the AI ones are pillager bots, "raider" never shows

His order, 2026-10-18 evening, verbatim: "get rid of the conept of praiders -- there are players, who are pillagers, then there are pillager bots"

## The words (binding from now on, every player-facing string)
- **pillager / pillagers**: a player. You, your mate, anyone in the party. ("name your pillager", "up to four pillagers" are already right.)
- **pillager bot / pillager bots**: the AI humans out on the surface: hostile ones, ones heading for extraction, downed ones, elite ones, a hire's body when it is meant as "an AI one".
- **raider / raiders**: never on screen, anywhere. (Leave "ARC Raiders" in code comments alone; it is a game name.)
- The machines (crawler, sentry, listener, warden, bulwark, choir, howler), the crier, the peddler and wirt keep their names.

## Scope: words on screen only
- Change ONLY strings a player can read: HUD callouts, the board of who is still out there, noise-ring labels, settings rows and their hints, tooltips, how-to-play and help text, end cards, the scoreboard, the run report, the arcade screens, the store text inside the game file.
- NEVER rename code: `kind:'raider'`, `CFG.nRaider`, `raiderDownHp()`, `RAIDER_DOWN_T`, settings keys like `'raiders'`, `census.by.raider`, save fields. The vocabulary rule says renaming a field that every save and spawn path reads, just to change a word on screen, is a trade he already refused.
- Display-label maps that turn a kind into a word (for example a `raider:'pillager'` entry in a kill-feed or census label map) DO change: their value becomes `'pillager bot'`.
- The dated what's-new history entries (the long upper-case patch notes near the top of the file) stay as written: they are history, and none of them says "raider".
- New and changed text is ALL LOWER CASE (his order 10-18) unless the string sits in an element whose CSS already sets the case.
- Lines HE edited in text-edit mode are keys (memory: an edited line is a key). Never reword one. If one of his edited lines contains "raider" or means a bot by "pillager", leave it and list it in your notes for the coordinator.
- The armour set named "raider" (`setraid`) is a gear name, not the people: leave it. The coordinator asks him about it.

## Places found on 10-18 (line numbers drift; search the text)
- 'Bushes you can hide in, and raiders who hide in them too' -> pillager bots
- settings: 'AI pillagers', 'Min pillagers alive', 'Pillager crews feud (0 truce)', 'Seconds a pillager must hold the ring', 'Plain-language raid settings: pillagers, machines, ...' -> pillager bots
- '  |  AI pillagers extracted: ' -> pillager bots extracted
- '40% more machines, pillagers and criers.' and 'Every pillager is hostile and already searching for you.'
- callouts 'PILLAGER TURNED HOSTILE', 'PILLAGER CALLED EXTRACTION', 'PILLAGER REINFORCEMENTS'
- noise rings 'pillager moving', 'pillager firing'; 'search in a ring; hold to finish a pillager'
- the board 'CURRENT PILLAGERS  ' (two places)
- 'Word has spread. Hires cost more and pillagers trust you less.' (both copies)
- 'No Data Core in your stash. Find them in rare containers or on elite pillagers.'
- how to play: 'Beware of hostile robots and fellow pillagers.' (both copies; also robots -> machines if it is your text, not his)
- 'Pillagers play like people: they roll, aim, crouch over crates, and bolt for the extraction'
- 'A PILLAGER' (about line 20149: read what it labels first)
- any single-word label string 'pillager' / 'pillagers' that names the AI ones, and any `raider` in a label map value
Search with: `grep -n -o "[\"'\`>][^\"'\`<>]*[Pp][Ii][Ll][Ll][Aa][Gg][Ee][Rr][^\"'\`<>]*[\"'\`<]"` and the same for raider, then read each hit in context.

## Check (must FAIL on the current build)
One check that walks the game's own player-facing text you changed: none of it matches /\braiders?\b/i, and the settings rows, the board title and the bush hint read "pillager bot(s)". On the current build it fails on 'raiders who hide in them too' and 'AI pillagers'.

## Done when
Shipped through the queue (one ship), the check green, the newest-80 checks green, the fingerprint unchanged (text only, so it must be). Note in your notes file every string you changed (before -> after) and any of his edited lines you left alone.
