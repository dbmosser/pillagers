# 00c-249 seal faster and defended (lane c)

- Key cw-sealwave. mk script in scratchpad mk-cw-sealwave.ps1. PREFLIGHT PASS as v36.96.
- Faster: sealNeed = round((34+21*tier)*2/3) (23, 37, 51...). Every reader uses sealNeed, so bars, map ring and end-card words follow.
- Wave: first frame of progress (if the cut is not already finished) calls sealWaveCall: 3+min(tier,3) machines at once (crawlers 7 in 10, sentries 3 in 10),
  then 2+min(tier,2) more, one every 7 s; scaled by CFG.siegeVol. Spawn 700-1000 from the seal, 700+ from every player, out of the seal's line of sight for the
  first 40 tries. Draws on fxBorrow (effects side stream). Once per seal per raid (G.seal.waved). Callout: SEAL BREACH: INCOMING (warn lane) plus the alarm blip.
- Party: a linked window sends {t:'swv'}; the host (netSealWaveTake) calls the wave once. Machines come to both windows through the normal host entity mirror.
- Not done: hostile pillager bots in the wave (machines only, like the siege). Not seen in two real windows yet: the swv path has no automated check.
- Watch line for DESIGN: the seal opens faster but calls a wave.
