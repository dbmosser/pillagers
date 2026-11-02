# 00p-m2b-heirs notes (lane b)

Key cw-p2heirs, mk script S\mk-cw-p2heirs.ps1, draft tools\handoff\drafts\draft-cw-p2heirs.json.

## What it does
- PIL_TRAITS (17: 10 good, 7 bad; ids like lightstep, heavyfeet), PIL_TRAIT_BY, PIL_NAMES (40) after `var WORN_PW_MAX=100;`.
- pilMake(name,gen,traits,num): records carry num (the numeral). pilClean keeps known trait ids, once each, two at most; num >= 1.
- acctEnsure drops P.heirs when it is not a valid roll for the next generation.
- pilHeirs(p): three heirs on wornRand(pilSeed(p,g)) (FNV of acctName | first born | gen), kept in P.heirs. pilBirth(p,i) heir i; pilBirth(p) heir 0;
  pilBirth(p,'name') heir 0 renamed (keeps the old cw-p0acct check and any m2a call with a name working).
- pilName(r) lower case name + roman numeral from ii; pilOrd(n) "14th"; pilNum(p,name) counts hall + living + 1.
- wornMods(worn, add): add = trait sum; floor -base, cap on plus. raidWornMods passes pilTraitMods(P.pil); null when nothing.
- Account card = stats page card "your Nth pillager", value pilName, sub trait names in var(--ok) / var(--danger).

## Pictures
- Screen 15-mainframe-stats. The fixture profile is generation one with no traits, so the picture shows the card without trait lines; the check proves
  the trait lines in the DOM.
