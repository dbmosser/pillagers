# Publishing Dark Raiders to itch.io (for tonight)

The game is one self-contained HTML file. The upload zip is built by:

    tools/publish/dark_raiders_web.zip   (index.html inside = dark_raiders.html)

Rebuild it any time with (PowerShell):

    Copy-Item 'C:\claudecode\dark raiders\dark_raiders.html' 'C:\claudecode\dark raiders\tools\publish\index.html' -Force
    Compress-Archive -Force -Path 'C:\claudecode\dark raiders\tools\publish\index.html' -DestinationPath 'C:\claudecode\dark raiders\tools\publish\dark_raiders_web.zip'

## Steps, once (about five minutes)

1. Free account at https://itch.io  ->  top-right arrow  ->  "Upload new project".
2. Title: whatever you like. Kind of project: **HTML**.
3. Uploads: add `dark_raiders_web.zip`, tick **"This file will be played in the browser"**.
4. Embed options: tick **Fullscreen button**; viewport about **1280 x 720**.
5. Visibility: **Restricted** (secret URL) so only people with the link can play.
6. Save. Share the page URL with friends.

## Updating later

Re-upload a fresh zip to the SAME project page (edit project -> replace the file).
Same URL; friends just refresh.

## What friends should know

- Saves are per-browser (localStorage): everyone gets their own fresh profile.
  Your local save on http://localhost:8802 is untouched by any of this.
- After a sitting the game saves a run report `dark_raiders_runN.txt` to their
  Downloads (the localhost telemetry drop is disabled off-localhost as of v2.78,
  so there are no console errors and the download fallback carries the click's
  user activation, which itch's iframe permits). If they send you those files,
  drop them in `exports/` and they get mined like your own.

## Fastest alternative (no game page)

https://app.netlify.com/drop  ->  drag the `tools/publish` folder in  ->
instant URL (free account to keep it). itch's secret link + game page fits
"share with friends" better.

## Page text for the alpha (paste into the itch page description)

PILLAGERS, alpha. Ascend, pillage, extract.

This is an alpha: things will break. When something does, the game writes
it into your run report and tells you so. On your first visit the game asks
whether your run reports may be sent to the developer; YES means each report
goes out by itself as a raid ends, and you never have to do anything. If you
say no, the report lands in your Downloads folder as dark_raiders_runN.txt
every second raid, and you can send it by hand.

Play in fullscreen (the title screen has a button). 1080p or bigger looks
best; a laptop screen works.

Controls: WASD move, mouse aim, LMB fire, RMB aim down sights, E interact,
R reload, F heal or revive, Q and G throw, TAB backpack, M map, SHIFT sprint
on and off, CTRL or C crouch on and off, SPACE dodge roll, P or ESC pause.

Your operator lives in this browser. Clearing browser data erases it.
Settings has a Back up your progress button that saves it to a file.

Known: some rooms have a sliver of floor behind furniture you cannot reach.
That is cosmetic. Tell us about anything else.
