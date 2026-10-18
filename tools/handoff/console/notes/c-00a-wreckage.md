# c-00a-wreckage notes

Run 1:
- Death code: dark_raiders.html ~27431-27506 (search "WARDEN WRECK"). Warden/choir(Pillbox)/listener/peddler leave
  'cache' (generic purple box); sentry/crawler/bulwark/howler/snitch(Crier) leave 'botwreck' (ONE generic brown wreck for all, c.bot=e.kind);
  raider -> 'body' (human, fine); stray -> 'body' (human, fine); deer -> carcass already (cw-deercarcass, drawDeerCarcass).
- Draw: function drawContS(ct); machine art: drawWardenS, drawChoirS, drawSentryS, drawCrawlerS, drawListenerS, drawBulwarkS, drawHowlerS, drawSnitchS, drawPeddlerS (grep names).
- PLAN: dispatch table WRECKDRAW[ct.bot]. Keys in order: cw-wreckwarden, cw-wreckpillbox, cw-wrecklistener, cw-wrecksentry, cw-wreckcrawler,
  cw-wreckbulwark, cw-wreckhowler, cw-wreckcrier, cw-wreckpeddler (a human: body with his pack).

Run 2 (lane c):
- SHIPPED v29.12 cw-wreckwarden (preflight PASS then shipq). It added: `var WRECKDRAW={}`, `wreckSmoke(ct,h)`, `drawWreckWarden`, hook in drawContS
  (`if(ct.bot&&WRECKDRAW[ct.bot]){...} else if(ct.type==='botwreck')`), and cw.bot='warden', cw.ov (overseer).
- Pattern for the next keys (copy S\mk-cw-wreckwarden.ps1): anchor 1 = set `X.bot='kind'` on the container at death (cache ones: choir, listener, peddler);
  botwreck ones already have c.bot=e.kind so need no death edit. Anchor 2 = `function drawContS(ct){` (prepend function drawWreckX + `WRECKDRAW.kind=drawWreckX;`).
  Draw fn: wc.translate(ct.x,ct.y-1) once (the check stubs translate, needs x==ct.x and stack with drawContS+drawWreckX), grit(ct.x,ct.y) for facing,
  rrF(x,y,w,h,r) fills with current fillStyle, mbPoly(arr) fills a polygon, MBPAL palette (ink,gm[0-3],ox[0-2],och,brass,rub,tooth,steel), o=ct.opened -> cavity open, no smoke.
  Check: e=mkX(p.x+60,p.y); e.hp=0; e.byPlayer=1; g.ents=[e]; __ents(0.016); find container near e.x,e.y; stub PR.translate.
  Keep the existing death say() text unchanged (old checks test 'It dropped a cache.').
- Status: warden DONE. Remaining: pillbox(choir), listener, sentry, crawler, bulwark, howler, crier(snitch), peddler.
