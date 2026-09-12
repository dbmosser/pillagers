// PILLAGERS RUN COLLECTOR
//
// Paste the whole of this into a Cloudflare Worker. Step-by-step in tools/HOSTING.md.
//
// It does three things and nothing else:
//   POST /            a player's run report arrives and is stored
//   GET  /list?key=   the keys of everything stored, newest first  (needs PULL_KEY)
//   GET  /get?key=&id= one report, as plain text                   (needs PULL_KEY)
//
// WHY POSTING NEEDS NO KEY AND READING DOES. The game posts from a stranger's
// browser, so a posting key would be printed in the page source for anyone to read
// and would protect nothing. Reading is the half worth protecting, because that is
// where the reports are. The worst an abuser can do without the key is fill the
// store with junk, and the size cap and the shape test below make that tedious.
//
// TWO BINDINGS ARE NEEDED, both set in the worker's own Settings:
//   RUNS      a KV namespace, where reports are stored
//   PULL_KEY  a secret, any long random word

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

function text(body, status) {
  return new Response(body, { status: status || 200, headers: { ...CORS, 'Content-Type': 'text/plain' } });
}
function json(obj, status) {
  return new Response(JSON.stringify(obj, null, 2), {
    status: status || 200,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: CORS });

    // ---------------------------------------------------------------- READING
    if (request.method === 'GET' && (url.pathname === '/list' || url.pathname === '/get')) {
      const key = url.searchParams.get('key') || '';
      // Compared at full length rather than with an early return, so the time this
      // takes says nothing about how much of the key was right.
      if (!env.PULL_KEY || key.length !== env.PULL_KEY.length) return text('no', 403);
      let diff = 0;
      for (let i = 0; i < key.length; i++) diff |= key.charCodeAt(i) ^ env.PULL_KEY.charCodeAt(i);
      if (diff !== 0) return text('no', 403);

      if (url.pathname === '/list') {
        const out = [];
        let cursor;
        do {
          const page = await env.RUNS.list({ cursor, limit: 1000 });
          for (const k of page.keys) out.push({ id: k.name, bytes: (k.metadata && k.metadata.bytes) || 0 });
          cursor = page.list_complete ? null : page.cursor;
        } while (cursor);
        out.sort((a, b) => (a.id < b.id ? 1 : -1));   // newest first: the ids start with the time
        return json({ count: out.length, runs: out });
      }

      const id = url.searchParams.get('id') || '';
      if (!id) return text('which one', 400);
      const body = await env.RUNS.get(id);
      return body === null ? text('not here', 404) : text(body);
    }

    // ---------------------------------------------------------------- POSTING
    if (request.method !== 'POST') {
      // A friend who pastes the address into their browser should not meet an error.
      return text('This is where Pillagers run reports arrive. Nothing to see.');
    }

    const body = await request.text();

    // A report is a flight recorder. Anything that is not one is not stored, which
    // keeps the store readable and makes it dull to abuse.
    if (!body || body.length < 40) return text('empty', 400);
    if (body.length > 2000000) return text('too big', 413);
    if (body.indexOf('FLIGHT RECORDER') < 0) return text('not a run report', 400);

    // The id carries the time so a plain sort is newest-first, plus enough randomness
    // that two reports landing in the same second cannot overwrite each other.
    const when = new Date().toISOString().replace(/[:.]/g, '-');
    const rand = Math.random().toString(36).slice(2, 8);

    // The install id, if the report carries one, so reports from one browser can be
    // grouped later. It is random and local to that browser and says nothing about
    // the person.
    let who = 'anon';
    const m = /\biid[:= ]+([a-z0-9]{6,20})/i.exec(body);
    if (m) who = m[1];

    await env.RUNS.put(`${when}-${who}-${rand}`, body, { metadata: { bytes: body.length, who } });
    return text('thanks');
  },
};
