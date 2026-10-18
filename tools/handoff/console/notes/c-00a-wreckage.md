# c-00a-wreckage notes

Run 1:
- Death code: dark_raiders.html ~27431-27506 (search "if(e.kind==='warden'){ var cw=setLoot(mkContainer"). Warden/choir(Pillbox)/listener/peddler leave
  'cache' (generic purple box); sentry/crawler/bulwark/howler/snitch(Crier) leave 'botwreck' (ONE generic brown wreck for all, c.bot=e.kind);
  raider -> 'body' (human, fine); stray -> 'body' (human, fine); deer -> carcass already (cw-deercarcass, drawDeerCarcass).
- Draw: function drawContS(ct) ~34526; `if(ct.type==='botwreck'){` generic wreck, then carcass==='deer', then body, else box.
- Machine art: drawWardenAt 33723, drawChoirS 33850, drawSentryS 33997, drawCrawlerS 34082, drawListenerS 34228, drawBulwarkS 34274,
  drawHowlerS 34335, drawSnitchS 34395.
- Pattern: S\mk-cw-deercarcass.ps1 (shipped). Check = PR.translate stub + new Error().stack contains the draw function name.
- PLAN: dispatch table WRECKDRAW[ct.bot] (first key adds table + hook `if(ct.bot&&WRECKDRAW[ct.bot])` before the botwreck branch).
  Each key adds a function drawWreckX(ct) + registers it + sets ct.bot on the cache (warden, choir, listener) or uses existing c.bot.
  Keys in order: cw-wreckwarden (warden + overseer), cw-wreckpillbox, cw-wrecklistener, cw-wrecksentry, cw-wreckcrawler, cw-wreckbulwark,
  cw-wreckhowler, cw-wreckcrier, cw-wreckpeddler (a human: body with his pack).
Status: (update below)
