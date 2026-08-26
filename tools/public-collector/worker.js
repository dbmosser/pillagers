// Dark Raiders public run collector.
//
// Deploy target: Cloudflare Workers (free tier is far beyond what this needs).
// It accepts the exact text body the game's buildExport() already produces, and
// appends it to a KV store keyed by timestamp. Nothing here is Dark Raiders
// specific except the size cap and the header sniff, so any equivalent host
// (Netlify Functions, Deno Deploy, Val Town) can run the same twenty lines.
//
// SETUP, once:
//   1. Create a Worker, paste this in.
//   2. Bind a KV namespace to it under the name RUNS.
//   3. Deploy, note the URL, e.g. https://dr-runs.<you>.workers.dev/run
//   4. In dark_raiders.html set:  var PUBLIC_DROP='https://.../run';
//   5. Rebuild tools/publish and upload. Nothing else in the game changes.
//
// The game only posts here when the player has switched Share runs ON in
// Settings, which is OFF by default. This endpoint is therefore never the thing
// that decides consent; it just has to not be a liability if someone finds it.

const MAX_BYTES = 256 * 1024;      // a full 60-run export is ~40KB; this is slack
const KEEP_DAYS = 30;

export default {
  async fetch(request, env) {
    const cors = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });

    // GET with the admin key returns everything, newest first. That is how the
    // pull script on his machine drains it into exports/.
    if (request.method === 'GET') {
      const key = new URL(request.url).searchParams.get('key');
      if (!env.ADMIN_KEY || key !== env.ADMIN_KEY) {
        return new Response('nope', { status: 403, headers: cors });
      }
      const list = await env.RUNS.list({ limit: 1000 });
      const out = [];
      for (const k of list.keys) {
        const v = await env.RUNS.get(k.name);
        if (v) out.push({ name: k.name, body: v });
      }
      return new Response(JSON.stringify(out), {
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    if (request.method !== 'POST') return new Response('nope', { status: 405, headers: cors });

    const body = await request.text();
    // Cheap sanity: it has to look like one of ours, and it has to be small.
    if (body.length > MAX_BYTES) return new Response('too big', { status: 413, headers: cors });
    if (!body.includes('FLIGHT RECORDER')) {
      return new Response('not a run', { status: 400, headers: cors });
    }

    // Key by time plus a slice of the install id so two people posting in the
    // same millisecond cannot overwrite each other.
    const iid = (body.match(/Install:\s*(\w+)/) || [, 'anon'])[1].slice(0, 8);
    const key = `${Date.now()}-${iid}`;
    await env.RUNS.put(key, body, { expirationTtl: KEEP_DAYS * 86400 });

    return new Response('ok', { status: 200, headers: cors });
  },
};
