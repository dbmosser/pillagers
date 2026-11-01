# 220-camera-flakes (lane c, 11-01)

STATUS: diagnosed, patches written below, NOT applied. My write list does not cover tools/uishots.ps1, tools/console-sdk/critic.mjs,
tools/handoff/codex/retarget.mjs or tools/handoff/drafts/gen-draft.ps1 (the Edit on retarget.mjs was refused), so the coordinator applies them.
Nothing was run on port 9363 for the same reason (no code change to try).

## Findings (checked in the files)
1. Pairing (o-09e): the real cause is a pair code that is too long. The round-4 recipe
   (tools/handoff/codex/work/o-09e-.../recipes.json) uses `pair=cxd151r4incoming1` = 17 chars; the game's netPairOf
   (dark_raiders.html:61360, regex `[a-z0-9]{4,16}`) throws it away, the guest never pairs, the recipe's own gWait says
   "real windows did not link". Round 2 used a shorter code and linked. Hyphens, capitals and >16 chars all fail the same way.
   Recipe authors pick the code (e.g. `var pair='cxgold157p'+seat`), so the camera has to fix it, not the game (the game rule is right for real play).
2. Stale zoom (o-00c p2-x3-4k): the report said 3840x2160 because the viewport string is read BEFORE staging (uishots.ps1 StageOne,
   `viewport=[string]$vp`). Nothing re-checks the page at shot time. Fix = read it again right before Shot and reset what drifted.
3. Port (21:15 run on 9339): `-Port` defaults to 9339 and nothing claims it; two runs with the default share it, and ChromeStart then
   kills the first run's Chrome (`MyChromes | Stop-Process`). Fix = an atomic claim file per port, default picks a free one.
4. Critic: report.json beside every camera set already says `"staged":false` and the `"shot"` file name, so the critic can refuse.
5. retarget.mjs: line 69-70 `eol` / `fix()` pick one style for the whole file. Fix = try the file's style, then LF, then CRLF, then as written.
6. gen-draft.ps1 line 30/33: `$w=[string]$d.why` is the only text that reaches DESIGN.md (`d$New.txt`).

## Patch A: tools/uishots.ps1 (items 1, 2, 3)
A1. param block: `[int]$Port=9339` -> `[int]$Port=0` (0 = take a free one). Header comment: "-Port 0 (default) takes the first free port of 9339-9345; a lane port (936N) is claimed too".
A2. Replace line 35 (`if($Port -eq 8802 ...`) and put this right after it; delete nothing else. `$ChromeProfile` (line 50) must come AFTER it, as it does now:
```powershell
# 10-29 (task 220 item 3): a run claims its port with a lock file (atomic CreateNew, owner = this process id). A second run
# never takes a port a live run holds, so two runs can no longer kill each other's Chrome (the 21:15 review run on 9339).
function ClaimPort([int]$want){
  $cands=if($want -gt 0){ @($want) }else{ 9339..9345 }
  for($wait=0;$wait -lt 40;$wait++){
    foreach($pt in $cands){
      $lf=Join-Path $env:TEMP "pillagers-uishots-port-$pt.lock"
      if(Test-Path -LiteralPath $lf){
        $owner=0; try{ $owner=[int](Get-Content -LiteralPath $lf -ErrorAction Stop | Select-Object -First 1) }catch{}
        if($owner -and (Get-Process -Id $owner -ErrorAction SilentlyContinue)){ continue }   # a live run owns it
        Remove-Item -LiteralPath $lf -Force -ErrorAction SilentlyContinue }
      try{ $fs=[IO.File]::Open($lf,'CreateNew','Write','None'); $b=[Text.Encoding]::ASCII.GetBytes([string]$PID); $fs.Write($b,0,$b.Length); $fs.Dispose() }catch{ continue }
      if($want -le 0){ $answers=$false; try{ Invoke-RestMethod "http://127.0.0.1:$pt/json/version" -TimeoutSec 2 | Out-Null; $answers=$true }catch{}
        if($answers){ Remove-Item -LiteralPath $lf -Force -ErrorAction SilentlyContinue; continue } }   # something else listens there
      return $pt
    }
    Start-Sleep -Seconds 3
  }
  throw $(if($want -gt 0){ "port $want is held by another live camera run (waited 2 min)" }else{ 'no free camera port in 9339-9345 (waited 2 min)' })
}
$Port=ClaimPort $Port
```
A3. In the final `finally{` block, first line after `ChromeStop`: `Remove-Item -LiteralPath (Join-Path $env:TEMP "pillagers-uishots-port-$Port.lock") -Force -ErrorAction SilentlyContinue`
    (a crash before ChromeStop leaves a lock whose owner pid is dead; ClaimPort clears that).
A4. Pair codes (item 1). After `$pick` is built (after line 42) add; it only touches recipes whose code is invalid, so valid recipes are byte for byte unchanged:
```powershell
# 10-29 (task 220 item 1, o-09e): the game's netPairOf takes only 4-16 lower case letters or digits. A longer, capital or hyphenated
# code never paired ("real windows did not link", 17 chars in o-09e round 4). Fix every `pair=CODE` in the url and every
# `pair='CODE'` literal of a picked screen, the same way each time, so both windows still agree. A code built by adding a seat
# afterwards ('cx...'+seat) cannot be seen here: keep that prefix at 15 chars or less.
function PairCode([string]$t){
  if($t -cmatch '^[a-z0-9]{4,16}$'){ return $t }
  $c=($t.ToLower() -replace '[^a-z0-9]','')
  if($c.Length -ge 4 -and $c.Length -le 16){ return $c }
  $h=[BitConverter]::ToString([Security.Cryptography.SHA1]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($t))).Replace('-','').ToLower()
  return $c.Substring(0,[Math]::Min(10,$c.Length))+$h.Substring(0,6)
}
function PairFix([string]$s){
  if(-not $s){ return $s }
  $s=[regex]::Replace($s,'(?<=\bpair=)[A-Za-z0-9_-]+',{ param($m) PairCode $m.Value })
  [regex]::Replace($s,"(?<=\bpair\s*=\s*')[^'`"\\]+(?=')",{ param($m) PairCode $m.Value })
}
foreach($p in $pick){ if($p.query){ $p.query=PairFix ([string]$p.query) }; if($p.js){ $p.js=PairFix ([string]$p.js) } }
```
    (the second pattern lets a recipe keep `new URLSearchParams(location.search).get('pair')||'default'` as is.)
A5. Viewport guard (item 2). Add this function next to Shot(), set `$script:tw=$tw; $script:th=$th` in the res loop (after line 201), and in StageOne call it right before `if(Shot ...)` (line 183):
```powershell
# 10-29 (task 220 item 2, o-00c): the viewport in report.json was read before staging; a recipe that left a page scale, a device metrics
# override or a CSS zoom/transform on html or body gave a clipped HUD under a "3840x2160" label. Read it again at shot time; if
# anything drifted, reset it, say so in the note, and report the shot-time viewport.
function ViewGuard(){
  $probe='JSON.stringify({w:innerWidth,h:innerHeight,d:devicePixelRatio,s:(window.visualViewport?visualViewport.scale:1),z:[document.documentElement.style.zoom,document.body?document.body.style.zoom:""],t:[document.documentElement.style.transform,document.body?document.body.style.transform:""]})'
  $bad={ param($o) ($o.w -ne $script:tw) -or ($o.h -ne $script:th) -or ([math]::Abs($o.d-1) -gt 0.001) -or ([math]::Abs($o.s-1) -gt 0.001) -or (($o.z+$o.t) | Where-Object { $_ -and $_ -ne '1' -and $_ -ne 'none' }) }
  $r=Ev $probe 15; if(-not $r.ok){ return $null }; $o=$r.val | ConvertFrom-Json
  if(-not (& $bad $o)){ return @{now="$($o.w)x$($o.h)";fixed=''} }
  try{ Cdp 'Emulation.setPageScaleFactor' @{pageScaleFactor=1} 8 | Out-Null }catch{}
  try{ Cdp 'Emulation.clearDeviceMetricsOverride' @{} 8 | Out-Null }catch{}
  Ev "(function(){ var e=document.documentElement,b=document.body; e.style.zoom=''; e.style.transform=''; if(b){ b.style.zoom=''; b.style.transform=''; } window.dispatchEvent(new Event('resize')); return 1; })()" 10 | Out-Null
  Start-Sleep -Milliseconds 700
  $r2=Ev $probe 15; $o2=$r2.val | ConvertFrom-Json
  return @{now="$($o2.w)x$($o2.h)";fixed=("viewport reset before the shot: was "+$r.val)}
}
```
    In StageOne: `$vg=ViewGuard; if($vg){ $entry.viewport=$vg.now; if($vg.fixed){ $entry.note=(($entry.note+' | '+$vg.fixed).Trim(' |')) } }`.
    Game check: the game puts zoom only on elements (settingsmodal, news card, fsgate: mkfixture.ps1 lines 2565, 15367, 20245), never on html or body, so this reset cannot hit a real game scale.
    A popup window (player 2 as a second window) is another target; this guard covers the tab uishots drives. If the p2 4K clip came from the popup, the recipe's
    window.open size (`width=innerWidth+32`) is the next place to look; unconfirmed.

## Patch B: tools/console-sdk/critic.mjs (item 4)
Insert after line 14 (the USAGE check), before `const caps`:
```js
// 10-29 (task 220 item 4, o-00f): report.json beside a camera set marks each picture staged true/false. A NOT STAGED picture is the
// fallback title screen, not the scene, and was scored as if it were the raid. Refuse it: nothing is scored, nothing is cached.
for (const p of pics) { const d = p.slice(0, p.lastIndexOf('/')), f = p.slice(d.length + 1); let rep; try { rep = JSON.parse(readFileSync(R + '/' + d + '/report.json', 'utf8')); } catch { continue; }
  for (const s of rep.screens || []) for (const res of ['1080', '4k']) { const e = s[res];
    if (e && e.shot === f && e.staged === false) { console.log('CRITIC REFUSED: ' + p + ' is NOT STAGED (' + String(e.note || '').replace(/\s+/g, ' ').slice(0, 200) + '). Fix the staging and shoot again; a fallback picture is not the scene.'); process.exit(1); } } }
```
A set shot with an old uishots (no report.json) or a picture not named in the report is judged as before.

## Patch C: tools/handoff/codex/retarget.mjs (item 5)
Replace lines 77-84 (from `const anchor = fix(e.anchor), repl = ...` through `while ((p = mk.indexOf(anchor, ...` loop) with the block below; keep the lines after it (`if (c !== 1) {` ... uses `c`, `pos`, `anchor`, `repl`). `fix` and `eol` stay (eol picks which variant is tried first).
```js
    const h = sha(nl(e.anchor) + NUL + nl(e.replacement));
    if (applied.has(h)) { put('EDIT', n + ' state=applied-before'); return; }
    if (!nl(e.anchor).trim()) { errs.push('edit ' + n + ': the anchor is empty'); return; }
    // 10-29 (task 220 item 5, o-00g): the fixture has mixed LF and CRLF blocks. Match the anchor as LF, as CRLF and as written against the
    // real file; the variant that occurs exactly once wins (the file's main style first), and the replacement takes its line ends.
    const lfA = nl(e.anchor), crA = lfA.replace(/\n/g, '\r\n');
    const variants = eol === '\r\n' ? [['crlf', crA], ['lf', lfA]] : [['lf', lfA], ['crlf', crA]];
    if (e.anchor !== lfA && e.anchor !== crA) variants.push(['as-written', e.anchor]);
    const countIn = (a) => { let k = 0, q = -1; while ((q = mk.indexOf(a, q + 1)) >= 0) { k++; if (k > 5) break; } return k; };
    let anchor = variants[0][1], kind = variants[0][0], c = countIn(anchor);
    for (let vi = 1; vi < variants.length && c !== 1; vi++) { const k = countIn(variants[vi][1]); if (k === 1 || (c === 0 && k > 0)) { anchor = variants[vi][1]; kind = variants[vi][0]; c = k; } }
    const repl = kind === 'crlf' ? nl(e.replacement).replace(/\n/g, '\r\n') : kind === 'lf' ? nl(e.replacement) : e.replacement;
    if (anchor === repl) { errs.push('edit ' + n + ': the replacement equals the anchor, so it changes nothing'); return; }
    const bad = repl.match(/[^\x00-\x7f]/);
    if (bad) { errs.push('edit ' + n + ': the replacement has a non-ASCII character (code ' + bad[0].charCodeAt(0) + '); Windows PowerShell 5.1 misreads it. Write ASCII only, use \\u escapes inside the JS'); return; }
    const pos = c === 1 ? mk.indexOf(anchor) : -1;
```
and delete the old `let c = 0, pos = -1, p = -1;` + while loop. Test: a plan on a 2-line anchor inside a 36.22 (LF) block and one inside a CRLF block must both say `anchors=1`.
Also: `codex-lane.sh` writes the result with the same bytes, so the mixed endings stay as they were.

## Patch D: tools/handoff/drafts/gen-draft.ps1 (item 6)
Line 33, in the `d$New.txt` string, put the Watch line after `$w` when the why has none:
```powershell
$wt=''; if($Now -and $w -notmatch '(?i)\bwatch\b'){ $wt=" Watch: "+$Now }
... ("## v"+$V+" - "+$d.title+"`n`nCo-op hunt while he was away. "+$w+$wt+"`n`nMEASURED. ...
```
(`$Now` is already `$d.now` from line 6.) Check: a draft with why `x.` and now `watch the thing` gives a DESIGN.md v-section containing "Watch: watch the thing".

## Check still to run after the patches (item 3 of the task)
Three back-to-back two-window 4K recipes (e.g. the o-09e incoming-p1/p2 set, 17-char code) with `-Res 4k`, no -Port: all three link (report.json staged true), the 4k and 1080 `viewport` equal the label and the HUD boxes match.
