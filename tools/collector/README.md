# GETTING PILLAGERS ONLINE, START TO FINISH

This is the only file with these instructions in it. Two other copies existed and
have been deleted, because one thing written three ways is how they end up
disagreeing: two of them already did, on the itch viewport size.

Three jobs. Do them in this order. The reason the order matters is at the bottom.

---

# JOB ONE: THE COLLECTOR (about ten minutes)

This is where your friends' run reports arrive. The game already builds them and
already tries to send them. It has nowhere to send them yet.

1. Sign up at https://dash.cloudflare.com (free plan, no card).
2. Left menu: **Workers and Pages** (newer accounts say **Compute**) ->
   **Create** -> **Create Worker**. Name it `pillagers-runs`. **Deploy**
   (the hello-world is fine for now).
3. On the worker page click **Edit code**, select all, delete, and paste the whole
   of `worker.js` from this folder. **Deploy**.
4. Left menu: **Storage and Databases** -> **KV** -> create a namespace named
   `pillagers-runs`.
5. Back on the worker: **Settings** -> **Bindings** -> **Add** -> **KV namespace**.
   Variable name `RUNS`, namespace `pillagers-runs`. Save.
6. **Settings** -> **Variables and Secrets** -> **Add**. Type **Secret**, name
   `READ_KEY`, value: a long word you make up, about twenty characters, not one you
   use anywhere else. Save and deploy.
7. Open `https://pillagers-runs.<your-subdomain>.workers.dev/` in a browser.
   It should say `ok`. If it does, it works.

**Then paste two things into the chat: the worker URL and the READ_KEY.**

I then set `PUBLIC_DROP` in the game as a normal build with the usual checks, prove
a report actually reaches it, prove a player who has not agreed sends nothing, and
read `/list?key=...` every tick.

---

# JOB TWO: THE ITCH PAGE (about five minutes)

1. Free account at https://itch.io -> top-right arrow -> **Upload new project**.
2. **Title**: Pillagers. **Kind of project**: **HTML**. That one matters.
3. Uploads -> **Upload files** -> `tools\publish\pillagers-web.zip`
   (that is the only zip in that folder; there used to be three).
   Tick **This file will be played in the browser**.
4. Embed options: tick **Fullscreen button**. Viewport **1920 x 1080**.
   Not 1280 x 720. The game is laid out and tested at 1080p and anything smaller
   ships your friends a squashed build.
5. Visibility & access: **Restricted** -> **Anyone with the secret URL**.
6. Description: paste the block at the bottom of `tools/PUBLISH.md`. It is written
   for the alpha already.
7. **Save & view page**, and send that URL to your friends.

**Upload only after a build has been committed.** `tools/publish/index.html` is
refreshed by `ship.sh commit`, so between commits it is one build behind the working
file. If you upload mid-build you ship the previous version and it will look like
nothing changed. Ask me and I will rebuild the zip on the spot.

---

# JOB THREE, OPTIONAL: LET ME UPDATE THE PAGE (about five minutes)

Without this, updating means you re-uploading the zip by hand. With it, every build
uploads itself and friends just refresh.

1. Download butler, itch's own uploader:
   https://itch.io/docs/butler/installing.html
   Windows: unzip it into `C:\Users\User1\bin` (make the folder if needed).
2. In PowerShell, `butler -V`. If it is not recognised, run this, then open a NEW
   PowerShell window and try again:

       setx PATH "$env:PATH;C:\Users\User1\bin"

3. Make an API key: https://itch.io/user/settings/api-keys -> **Generate new key**.
4. In PowerShell, with your own values:

       setx BUTLER_API_KEY "paste-your-key-here"
       setx ITCH_TARGET "yourname/pillagers:html"

   `yourname/pillagers` is the part from your itch project URL. The `:html` must be
   there; it is the channel name.

Nothing else. The push is already in `tools/handoff/ship.sh`. Today every build
prints `itch: not pushed`. After this it prints `itch: pushing yourname/pillagers:html`.

---

# TELL YOUR FRIENDS THIS

**They have to say yes, or you will think it is broken.** The first time they reach
the Undercroft the game asks, once, whether their run reports may be sent to you.
Yes means every raid reports itself and they never think about it again. No is
respected: the report saves into their Downloads instead and they can send you the
file. Settings has a **Share runs with the developer** row they can change at any
time.

**The game never tells them how to reach you.** It says "paste it to Daniel" and
gives no address anywhere. Put your contact in the itch page description.

**Their saves are their own.** Each browser keeps its own profile. Nothing they do
touches your save.

**Tell them to play fullscreen.** The title screen has a button and itch has one in
the corner.

---

# THE ORDER, AND WHY

The game only asks the consent question when there is an address to send to. Until
Job One is done, nobody is asked and nothing is sent. Anyone who plays before then is
never asked, and gets asked the first time they load a later build.

So: collector, then page, then butler whenever you like.

---

# CHECKING IT BY HAND

- `<worker URL>/list?key=<READ_KEY>` lists the stored reports, newest first.
- `<worker URL>/get/<id>?key=<READ_KEY>` shows one.
- `<worker URL>/` says `ok`.

Reading needs the key. Posting does not, and cannot: the game posts from a stranger's
browser, so a posting key would be printed in the page source for anyone to read and
would protect nothing. The worker refuses anything that is not a run report.
