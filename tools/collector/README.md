# The run-report collector (Cloudflare Worker)

Why: on itch a friend's run report has nowhere to go, so the game drops it
into their Downloads folder and they have to send it by hand. With this
collector every report posts itself here the moment a raid ends, and Claude
reads the new ones every tick. Free tier is plenty (100,000 requests a day).

## Your part, once, about fifteen minutes

1. Sign up at https://dash.cloudflare.com (free plan is fine).
2. Left menu: Workers and Pages -> Create -> Create Worker. Name it
   `pillagers-runs`. Click Deploy (the hello-world is fine for now).
3. On the worker page click Edit code, select all, paste the whole of
   `worker.js` from this folder, click Deploy.
4. Left menu: Storage and Databases -> KV -> Create a namespace named
   `pillagers-runs`.
5. Back on the worker: Settings -> Bindings -> Add -> KV namespace.
   Variable name `RUNS`, namespace `pillagers-runs`. Save.
6. Settings -> Variables and Secrets -> Add. Type Secret, name `READ_KEY`,
   value: any long password you make up. Save and deploy.
7. Open `https://pillagers-runs.<your-subdomain>.workers.dev/` in a browser.
   It should say `ok`.

Then paste two things into the chat: the worker URL and the READ_KEY.
Claude sets PUBLIC_DROP in the game to `<worker URL>/run` and reads
`<worker URL>/list?key=<READ_KEY>` every tick.

## What a friend sees

Nothing new. The game asks once, in plain words, whether run reports may be
sent to the developer. If they say yes, every raid's report posts here as it
ends; if not, it stays in their Downloads as before.

## Checking it by hand

- `<worker URL>/list?key=<READ_KEY>` lists the stored reports, newest first.
- `<worker URL>/get/<id>?key=<READ_KEY>` shows one.
