// node build/m2-check.mjs : syntax check of every injected block in m2-patches.mjs (they are only run inside a 12 MB page, so a typo costs a minute)
const { P } = await import('./m2-patches.mjs');
for (const [n, p] of Object.entries(P)) {
  for (const e of p.edits) {
    const rep = Array.isArray(e) ? e[1] : '';
    if (typeof rep === 'string' && rep.includes('art-survey hooks')) {
      try { new Function('var wc,INK,G,HAS_RR,SENTRY_R0,drawSentryS0,drawCrawlerS0;' + rep.replace('\nrequestAnimationFrame(function(ts){\n  lastTs=ts;', '')); console.log(n + ' syntax ok'); }
      catch (err) { console.log(n + ' SYNTAX ERROR ' + err.message); }
    }
  }
}
