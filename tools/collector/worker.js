// Pillagers run-report collector. A Cloudflare Worker, about forty lines.
//
//   POST /run            text/plain body      -> stored in KV under a timestamped key
//   GET  /list?key=K     K = READ_KEY secret  -> the stored keys, newest first, one per line
//   GET  /get/<id>?key=K                      -> one report
//   GET  /                                    -> "ok", so the URL can be checked in a browser
//
// The game posts with Content-Type text/plain and mode cors, which is a simple
// request: no preflight, only the Access-Control-Allow-Origin header below.
// Reports expire after 90 days. Nothing here identifies a person: the report
// carries a random per-install id and whatever the player typed in the note.
export default {
  async fetch(req, env) {
    const url = new URL(req.url);
    const cors = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    };
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
    if (req.method === 'POST' && url.pathname === '/run') {
      const body = await req.text();
      if (!body || body.length > 2000000) return new Response('bad', { status: 400, headers: cors });
      const id = new Date().toISOString().replace(/[:.]/g, '-') + '-' + Math.random().toString(36).slice(2, 8);
      await env.RUNS.put(id, body, { expirationTtl: 60 * 60 * 24 * 90 });
      return new Response('saved ' + id, { status: 200, headers: cors });
    }
    const key = url.searchParams.get('key');
    const text = { 'Content-Type': 'text/plain; charset=utf-8' };
    if (url.pathname === '/list') {
      if (!env.READ_KEY || key !== env.READ_KEY) return new Response('no', { status: 403, headers: text });
      const l = await env.RUNS.list({ limit: 1000 });
      const names = l.keys.map(k => k.name).sort().reverse();
      return new Response(names.join('\n'), { headers: text });
    }
    if (url.pathname.startsWith('/get/')) {
      if (!env.READ_KEY || key !== env.READ_KEY) return new Response('no', { status: 403, headers: text });
      const v = await env.RUNS.get(url.pathname.slice(5));
      return new Response(v === null ? 'not found' : v, { status: v === null ? 404 : 200, headers: text });
    }
    return new Response('ok', { headers: Object.assign({}, cors, text) });
  }
};
