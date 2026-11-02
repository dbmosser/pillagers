# 00p-m2a-death-ends (lane a, 11-01)

SHIPPED v37.29 (cw-m2death), commit 7a0b8d798, ON HIS PC v37.29.

- Game: pilRaidEnd(how, sec, lost) at file scope beside pilEnd/pilBirth (before szNoteShow). Called once from endRaid right after `forgeSweep(how)`, so never on the free walk-back (it returns earlier) or G.sim (guarded). Also returns at once for ARCADE.on and the NETP2 window (player 2 keeps today's rules until m3f).
  - every settled raid: P.pil raids+1, ext+1 on extract, kills + sum of T.kills, best = max(best, _secV).
  - dead / abandon: pilEnd(P, {how 'dead'|'quit', map FIXED_MAPS[P.mapIx].id, zone (landmark, else zoneAt, lower case), by (KIA card kn, lower case; '' on quit), lost ($ the card says gone; haul on a quit), items (lost bag keys + lost gun keys, value order, max 7), worn copy, look {hat,cut,skin,scheme,fit,outfit}}), then pilBirth(P), then P.pilNote {t:"<name> is gone  pillager <gen>", shown:0}.
  - pilNoteShow() runs first at every hub arrival (showScreen('hub')): `if(!pilNoteShow()&&!szNoteShow()) rankNoteShow();`
  - death ledger keeps lost gun keys in _pilGK.
  - P.worn is NOT cleared (m3c owns that).
- Two player: only his own death reaches endRaid on his PC; revive never calls it; a host who dies and spectates still goes through endRaid('dead').
- Fixture: __cleanProfile now resets P.hall=[], P.pil=null, P.pilGen=0, P.pilNote=null and acctEnsure (commit afeed448d). Needed because check 37.19 expects gen 1 and earlier checks' deaths now end pillagers.
- Check 37.29 (S\mk-cw-m2death.check.js): extract counts, death hall record and every end field, A/B with pilRaidEnd stubbed (credits, stash, guns, lifetime, rank equal), floor line once via showScreen('hub'), quit with shots, free walk-back, sim, demo, old save loaded twice.
- Pictures: notes/shots/00p-m2a-after (35 KIA card unchanged, 39 hub after extract), lint 0. No stage for the floor after a death: asked in questions.md.
