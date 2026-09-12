# HOSTING PILLAGERS FOR FRIENDS, AND GETTING THEIR REPORTS BACK

Two things need your hands, once. Everything after that is automatic.

The game itself needs no work: it is one file, 2.1 MB, with nothing loaded from
anywhere else, so any static host serves it as-is.

---

## PART ONE: THE ITCH PAGE (about five minutes, once)

The step-by-step is in `tools/PUBLISH.md` and it is current. The short version:

1. Free account at https://itch.io, then Upload new project. Kind: **HTML**.
2. Upload `tools/publish/pillagers-web.zip` and tick
   **"This file will be played in the browser"**.
3. Embed: tick Fullscreen button, viewport 1280 x 720.
4. Visibility: **Restricted**, so only people with the link can play.
5. Save, and send friends the URL.

`tools/PUBLISH.md` also has the page description written for the alpha. Paste it in.

### So that I can update it without you

Itch has a command-line uploader called butler. It is not installed here. Once it
is, every build I ship pushes itself to your page and your friends just refresh.

1. Download butler: https://itch.io/docs/butler/installing.html
   (Windows: unzip it somewhere on your PATH, for example `C:\Users\User1\bin`.)
2. Get an API key: https://itch.io/user/settings/api-keys, press Generate new key.
3. Tell Windows about it, once, in PowerShell:

       setx BUTLER_API_KEY "the-key-you-just-made"
       setx ITCH_TARGET "yourname/pillagers:html"

   Replace `yourname/pillagers` with what itch shows in your project URL.

That is all. `tools/handoff/ship.sh` already has the push step in it, and it does
nothing at all until those two things exist, so nothing breaks in the meantime. The
moment they do, every commit uploads.

---

## PART TWO: WHERE THE RUN REPORTS GO (about ten minutes, once)

**The game already does this.** When a raid ends it builds the whole run report and
posts it to a web address. That address is currently blank, which is why nothing is
sent. Set it and every consenting player's report arrives by itself.

Nothing else in the game changes. If the address is unreachable the game falls back
to what it does today, which is to save the report into their Downloads folder.

### Make the collector

1. Free account at https://cloudflare.com. No card.
2. **Workers & Pages** -> **Create** -> **Workers** -> **Create Worker**.
   Name it `pillager-runs`. Press **Deploy** (the default hello-world is fine).
3. Press **Edit code**, delete what is there, paste the whole of `tools/worker.js`
   from this repo, press **Deploy**.
4. Back on the worker page: **Settings** -> **Bindings** -> **Add** -> **KV
   namespace**.
   - Variable name: `RUNS`
   - KV namespace: **Create new**, call it `pillager-runs`
   Save, and it redeploys itself.
5. **Settings** -> **Variables and Secrets** -> **Add** -> **Secret**.
   - Name: `PULL_KEY`
   - Value: any long random word only you and I will know. This is what lets me
     read the reports back out. Anyone without it can only post, not read.
6. Copy the worker's URL. It looks like
   `https://pillager-runs.yourname.workers.dev`.

### Then tell me

Paste me the URL and the PULL_KEY. I will:

- set it in the game as a normal build, with a check that proves a report reaches it
  and that a player who has not consented sends nothing,
- pull the reports down every tick and mine them the same way I mine your own
  exports, which is the loop that has been running on your runs all along.

---

## WHAT YOUR FRIENDS WILL SEE

**They have to say yes.** Sending is off until they agree. The game asks once, and
Settings has a **Share runs** row they can change at any time. Someone who opens a
link to play a game has not agreed to send their play data, so the default is no.
Tell them to say yes, or nothing arrives and you will think it is broken.

**If they say no**, the report saves into their Downloads as
`dark_raiders_runN.txt` every second raid, and they can send you the file. Drop it
in `exports/` and it gets mined like your own.

**Their saves are their own.** Each browser keeps its own profile. Nothing they do
touches your save on localhost.

**The page must be https.** Itch is, so this is already satisfied. It matters
because the game refuses to post from an insecure page.

---

## WHAT I TRIED AND COULD NOT DO

I attempted to publish the game as a Claude artifact, which would have given you a
link inside a minute with no accounts at all. The action was blocked by this
machine's permission rules, so it needs your say-so.

It would not have been the right home anyway, and this is the reason: that page runs
in a sandbox which blocks both the report posting AND the file fallback. The
feedback machinery you already have would be dead there, and feedback was the point.
Itch keeps all of it.
