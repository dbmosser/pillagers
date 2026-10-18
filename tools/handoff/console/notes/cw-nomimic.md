# cw-nomimic (shipped v30.94, 2026-10-18 16:27)

His note (2026-10-18 15:44, build 30.73, in a raid at 2:12): "get rid of the mimics, its just too confusing".
Files consumed: exports/consumed-feedback-20261018-154439-876.txt and .png (the picture shows the feed line "you > mimic v-86 +50 sp").

## What a mimic was
About 2 percent of crates and lockers (MIMIC_PM 20 per thousand, a hash of the box position and the raid seed, no random draw) hid a dormant
crawler. A faint pinClick tick sounded inside 130 of one. Starting to search it woke the crawler 0.8 s later: it came out 34 away on the far
side of the box, named MIMIC x-NN, held its first bite for a second, the box was spent and spun away in a violet void swirl (drawMimicVoid),
the raid said MIMIC with a shake and the crawler alarm, and in a party a mimic mark told player 2. v26.77 (his yes 10-14), v28.93, v29.00.

## What was removed (game, v30.94, one ship)
- the whole block MIMIC_PM / isMimic / mimicWake / mimicTick (replaced by one comment saying why)
- the mimicTick call in the entity update
- drawMimicVoid and its call at the top of drawContS
- the party mark kind 'mimic' in the mark receiver
- the word "a mimic" in the alarm-cue comment
No What's New card, help page or settings row ever mentioned mimics (grep -i mimic found only code). CFG.mimic was only read (CFG.mimic===0),
never in DEF, never a GAMEOPTS row; applyCfg keeps only keys that DEF has, so an old profile with mimic on loads back as off by itself.
Nothing to turn off, so no settings change. tools/handoff/uic/mk-exp3.ps1 (an old unshipped EXPERIMENTAL settings idea, xfMimic) still names it; it was never shipped.

## Fingerprint
Unchanged: verifySafe ents {"0":85,"1":374} containers {"0":165,"1":593}. isMimic never drew from the raid stream, and the crawler was made on the cosmetic
stream (fxBorrow, fxn), so nothing seeded moved and no roll had to be kept.

## Checks
- New check 30.94 (tools/mkfixture.ps1): deals 5 raids (career map 0 seeds 6 and 4242, arcade map 0 seeds 12 and 7, career map 1 seed 19 one box in five), with
  P.cfg.mimic=1 put through applyCfg and CFG.mimic=1 forced on, then for EVERY closed box stands 60 away for 1.4 s (a mimic ticks), stands on it and holds E
  through the real search path until it opens. It fails on any crawler or MIMIC-named entity, any MIMIC line, any tick, any mimic mark on a box, any
  settings row or DEF key for mimic. On v30.93 it fails on all four map 0 raids (5, 1, 5, 4 mimics); on v30.94 it passes twice (about 10 s a run).
- Old checks 26.77, 28.93, 29.00 return 'SKIP: mimics removed since cw-nomimic (his note 2026-10-18)' once the functions are gone, and still run on the old build
  (fixture commits ecdb822c and 8aaee2b9). 26.77 had been failing on the old build since v28.xx (cw-mimicaway: the spent box stays opened, so the
  tick part never ticked); its tick part now reopens the box first (mim.opened=false), so it passes on the old build and skips on the new one.
- Stale card STOP at v30.92 was cleared by another worker's cw-cardP25 before this shipped; preflight lane e passed, then shipq.sh shipped it.

## Left
Nothing for this task. The ship commit 451fc7bb also carried other workers' uncommitted tool files (art-survey pictures), the usual pipeline behaviour.
