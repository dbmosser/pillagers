$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# START-HERE: the current queue after the two renumbers of 2026-09-06 midday.
# Inserted right after the queue header (which fixstate.ps1 anchors on, so
# the header itself is untouched). Idempotent.
$f = 'C:\claudecode\dark raiders\tools\handoff\START-HERE.md'
$s = [IO.File]::ReadAllText($f)
$marker = '**CURRENT QUEUE (2026-09-06 midday, after two renumbers; this list outranks every older list below):**'
if ($s.IndexOf($marker) -ge 0) { Write-Output 'START-HERE: already current'; exit 0 }
$hdr = '**THE QUEUE, ALL DRAFTED (p/f/d/a/cm in this folder), SHIP IN THIS ORDER:**'
$i = $s.IndexOf($hdr)
if ($i -lt 0) { throw 'queue header not found' }
$block = @(
  $marker,
  '- **1188 HIS ORDER: "left to be gone" and "nothing killed yet" out of the CONDITIONS panel** (his message with a screenshot, about 11:40). They were the verdicts of the kill-nothing and three-minute conduct contracts, printed without their names; the panel skips those two.',
  '- **1189 FULGURITE ONLY FROM A STRIKE CACHE** (his note; was 1188).',
  '- **1190 GUNS BACK INTO THE BACKPACK** (his order; was 1189).',
  '- **1191 THE BELT: SUPPORT MG FIRING LIKE A PISTOL, DRAG CELLS TO OTHER KEYS** (his note; was 1190).',
  '- **1192 to 1198 FIRST TEN MINUTES** (from the read-only audit wf_e9fb3c4f-c46, 8 agents, 35 findings; the ten highs verified by reading the code): 1192 the NEW IN card fits and a first launch never sees it; 1193 ENTER and the start button commit the typed name; 1194 a pause note survives ESC; 1195 the first session runs the Settings pass and the 1.3 menu zoom; 1196 dying with the freebie kit keeps the pistol you own; 1197 the heal verb tells the truth (both reviews); 1198 the notes-logged line sits below the corner readout.',
  '- **1199 to 1206 POLISH** (the former 1191 to 1198: character screen keys, safe pocket refuses throwables, freebie kit restore, controller craft, four guns on the bench pill, modal headers drop the balance, pillager throw band, map says EXTRACT NOW!). Their labels were shifted by renum1199.ps1 and renum1189b.ps1; every 11.9x mention in them was an anchor or a control reference.',
  '- **NOT DRAFTED, from the same audits, in value order:** the DOWN toast says F gets you up on the second down when it cannot; the lift FREEBIE KIT button does not clear the belt plan (the stash one does); ESC with the floor backpack open raises the pause box instead of closing the bag; P cannot close the pause box while its textarea has focus; GEARRULES still teaches X swaps; hub belt may cover the [E] STATION prompt (UNVERIFIED, take a screenshot of the floor with the operator at the lift); the outcome card prints a dose XP bonus the profile is not credited on death or abandon; the second review of v11.84 says only the player''s Lance rounds pass through crawlers (stamp `thru` on fromPlayer or copy the two lines into the enemy branch); check 11.80 should also count __ambOff calls rising by 2; check 11.85 should pin __forceSize(1920,1080); check 11.81''s control arm should restore P.seals.',
  '- **DRY RUN BEFORE SHIPPING 1189:** `powershell -NoProfile -ExecutionPolicy Bypass -File tools/handoff/dry.ps1 1189 1206` from the tree at v11.88, then `dry/mk.ps1`, then run checks 11.89 to 12.06 on :8801 between corpora (tools/serve.ps1 -Root tools/handoff/dry -Port 8801 if the server is down).',
  '',
  ''
) -join "`n"
$s = $s.Substring(0, $i + $hdr.Length) + "`n`n" + $block + $s.Substring($i + $hdr.Length)
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'START-HERE: current queue inserted'
