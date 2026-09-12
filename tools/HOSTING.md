# GETTING PILLAGERS ONLINE, STEP BY STEP

Two jobs, about fifteen minutes total. Do them in this order: the collector first,
then the page. That order matters, and the reason is at the bottom.

Everything after these two is automatic and mine to run.

---

# JOB ONE: THE COLLECTOR (ten minutes)

This is the address your friends' run reports get sent to. The game already builds
those reports and already tries to send them; it has nowhere to send them yet.

### 1. Make a Cloudflare account

Go to https://dash.cloudflare.com/sign-up. Email and a password. No card.

### 2. Make the worker

- Left sidebar: **Compute (Workers)**, or **Workers & Pages** on older accounts.
- **Create** -> **Start with Hello World!** -> **Get started**.
- Name it: `pillager-runs`
- Press **Deploy**. Wait for it to finish.

### 3. Paste in the real code

- Press **Edit code** (top right of the worker page).
- Select everything in the editor and delete it.
- Open `C:\claudecode\dark raiders\tools\worker.js`, copy the whole file, paste it in.
- Press **Deploy**, top right.

### 4. Give it somewhere to put the reports

- Go back to the worker's page, then **Settings** -> **Bindings** -> **Add**.
- Choose **KV namespace**.
- Variable name: type exactly `RUNS`
- KV namespace: **Create new**, name it `pillager-runs`, select it.
- **Deploy** / **Save**. It redeploys itself.

If you do not see KV as an option, open **Storage & Databases** -> **KV** ->
**Create instance**, call it `pillager-runs`, then come back and add the binding.

### 5. Give it a password for reading

This is what lets me pull the reports down. Without it, anyone who found the address
could read your friends' reports.

- Same **Settings** page -> **Variables and Secrets** -> **Add**.
- Type: **Secret**
- Name: type exactly `PULL_KEY`
- Value: a long random word. Make one up, twenty characters or so, letters and
  numbers. Do not reuse a password you use anywhere else.
- **Deploy** / **Save**.

### 6. Check it is alive

Copy the worker's address from the top of its page. It looks like:

    https://pillager-runs.yourname.workers.dev

Paste it into a browser tab. You should see:

    This is where Pillagers run reports arrive. Nothing to see.

If you see that, it works.

### 7. Send me two things

    the worker address
    the PULL_KEY you chose

Paste them to me in chat. I will then, as a normal build with the usual checks:

- set the address in the game,
- prove a report actually reaches it,
- prove a player who has NOT agreed sends nothing,
- and start pulling the reports down every tick and mining them the way I already
  mine yours.

---

# JOB TWO: THE ITCH PAGE (five minutes)

### 1. Make the project

- Free account at https://itch.io.
- Top right arrow -> **Upload new project**.
- **Title**: Pillagers
- **Kind of project**: **HTML**  (this is the important one)

### 2. Upload the game

- Under Uploads press **Upload files** and choose:

      C:\claudecode\dark raiders\tools\publish\pillagers-web.zip

- Tick **This file will be played in the browser**.

### 3. Embed settings

- **Embed options**: tick **Fullscreen button**.
- **Viewport dimensions**: 1280 wide by 720 high.
- Tick **Mobile friendly**: no. Leave it off.

### 4. Keep it private

- **Visibility & access**: choose **Restricted**, then **Anyone with the secret
  URL**. Only people you send the link to can reach it.

### 5. Describe it

Paste the block at the bottom of `tools/PUBLISH.md` into the description. It is
already written for the alpha and tells your friends what to expect.

### 6. Save and send

Press **Save & view page**. Send that URL to your friends.

---

# JOB THREE, OPTIONAL: LET ME UPDATE THE PAGE MYSELF (five minutes)

Without this, updating means you re-uploading the zip by hand. With it, every build
I ship uploads itself and your friends just refresh.

### 1. Get butler

butler is itch's own uploader.

- Download: https://itch.io/docs/butler/installing.html
- Windows: download the zip, and unzip it to `C:\Users\User1\bin`
  (make that folder if it is not there).

### 2. Make sure Windows can find it

Open PowerShell and run:

    butler -V

If it prints a version, good. If it says it is not recognised, run this, then open a
NEW PowerShell window and try again:

    setx PATH "$env:PATH;C:\Users\User1\bin"

### 3. Get an API key

- https://itch.io/user/settings/api-keys -> **Generate new API key**.
- Copy it.

### 4. Tell Windows about it, once

In PowerShell, replacing the two values:

    setx BUTLER_API_KEY "paste-your-key-here"
    setx ITCH_TARGET "yourname/pillagers:html"

`yourname/pillagers` is the bit from your itch project URL. The `:html` on the end
is the channel name and must be there.

### 5. Nothing else

The push is already wired into the ship chain. It prints

    itch: not pushed (butler, BUTLER_API_KEY or ITCH_TARGET missing; see tools/HOSTING.md)

today, and starts uploading on the next build after you do the above. You will see
`itch: pushing yourname/pillagers:html` in the build instead.

---

# TELL YOUR FRIENDS THIS

**They have to say yes, or you will think it is broken.** The first time they reach
the Undercroft, the game asks once whether their run reports may be sent to you.
Saying yes means every raid reports itself and they never do anything again. Saying
no is fine and respected: the report saves into their Downloads instead and they can
send you the file. There is a **Share runs with the developer** row in Settings they
can change at any time.

That question only appears once there is an address to send to, which is why JOB ONE
comes first. Anyone who plays before then is simply never asked, and will be asked
the first time they load a build that has it.

**Their saves are their own.** Each browser keeps its own profile. Nothing they do
touches your save.

**Tell them to play in fullscreen.** The title screen has a button, and itch has one
in the corner.

---

# THE ORDER, AND WHY

1. Collector first, so the consent question exists when the first person arrives.
2. Then the itch page, and send the link.
3. butler whenever you like; until then I hand you a rebuilt zip on every commit and
   you replace the file on the itch page yourself.

---

# WHAT I ALREADY DID

- `tools/worker.js` — the collector, written and ready to paste.
- `tools/handoff/ship.sh` — the itch push, spliced in and inert until you finish
  JOB THREE.
- `tools/publish/pillagers-web.zip` — rebuilt on every commit, already the right
  shape for itch, with `index.html` at the top of the zip.

# WHAT I COULD NOT DO

I tried to publish the game as a Claude link, which needs no accounts at all and
would have taken a minute. This machine's permission rules blocked it. It was the
wrong home anyway: that sandbox blocks both the report sending and the download
fallback, so the feedback you asked for would have been dead there. Itch keeps all
of it.
