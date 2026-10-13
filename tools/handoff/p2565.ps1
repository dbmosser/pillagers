$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE SIREN MEANS REAL DANGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var MSIREN_R=760, MSIREN_F0=290, MSIREN_DEP=75, MSIREN_PER=[1.4,1.2], MSIREN_LVL=0.045;
'@ @'
// v25.xx (sirentune), HIS ORDERS 2026-10-13: "siren seems to go off too often, maybe look at the parameters for that", "just taking damage
// shouldn't throw the siren", "alarm for crawlers should be quieter". v24.xx counted ANY machine within 760 whose state was chase, and a
// machine goes to chase without seeing him: a shot or a hit heard near it, a pack call, the last place it knew, so the siren rang for
// machines round a corner and every time he took damage. Now a machine counts only while it SEES him right now (the sight flag the AI
// stamps each frame, with a quarter second of grace for a one frame blink), inside 500 (a sentry on alert sees about 460, so only the
// long flash-of-lightning sightings are cut), after 0.6 s of that (a glance round a corner is not a lock-on), and once it stops it
// cannot start the siren again for 5 s (the same five seconds as the SEEN stinger). Crawlers weigh half: a crawler-only lock-on is half as
// loud. Taking damage alone never starts it. Cosmetic only: no seeded draw, no game state beyond the machine own timers.
var MSIREN_R=500, MSIREN_F0=290, MSIREN_DEP=75, MSIREN_PER=[1.4,1.2], MSIREN_LVL=0.045, MSIREN_SEE=0.25, MSIREN_HOLD=0.6, MSIREN_COOL=5, MSIREN_KIND={crawler:0.5};
'@

SubRx @'
  if(dist(e,p)>=MSIREN_R) return false;
'@ @'
  if(dist(e,p)>=MSIREN_R) return false;
  if(!((G.t||0)-(e.sirenSeeT===undefined?-99:e.sirenSeeT)<=MSIREN_SEE)) return false;   // v25.xx (sirentune): it must see him now, not chase the last place it knew
'@

SubRx @'
function machSirenVoice(a,out){
'@ @'
// v25.xx (sirentune): the machine counts once it has held the lock for MSIREN_HOLD, and not within MSIREN_COOL of the moment it stopped
function machSirenCounts(e,p,dt){
  var t=G.t||0;
  if(!machSirenLocked(e,p)){ if(e.sirenOn){ e.sirenOn=0; e.sirenCool=t+MSIREN_COOL; } e.sirenHold=0; return false; }
  if(t<(e.sirenCool||0)){ e.sirenHold=0; return false; }
  e.sirenHold=(e.sirenHold||0)+dt;
  if(e.sirenHold<MSIREN_HOLD) return false;
  e.sirenOn=1;
  return true;
}
function machSirenVoice(a,out){
'@

SubRx @'
  var p=G&&G.player, i, e, d, n=0, near=null, nd=1e9, a, out, v, t, k, per, lv, pl;
'@ @'
  var p=G&&G.player, i, e, d, n=0, near=null, nd=1e9, a, out, v, t, k, per, lv, pl, kw=0;
'@

SubRx @'
if(!machSirenLocked(e,p)) continue; n++; d=dist(e,p); if(d<nd){ nd=d; near=e; } }
'@ @'
if(!machSirenCounts(e,p,dt)) continue; n++; kw=Math.max(kw,MSIREN_KIND[e.kind]||1); d=dist(e,p); if(d<nd){ nd=d; near=e; } }   // v25.xx (sirentune): held and cooled; the loudest kind counts
'@

SubRx @'
  lv=MSIREN_LVL*(1+0.08*(k-1))*(0.7+0.3*clamp(1-nd/MSIREN_R,0,1));
'@ @'
  lv=MSIREN_LVL*(1+0.08*(k-1))*(0.7+0.3*clamp(1-nd/MSIREN_R,0,1))*kw;   // v25.xx (sirentune): a crawler-only lock-on is half as loud
'@

SubRx @'
    if(!sees&&G.lightning>0&&!p.downed&&!roofAt(p.x,p.y)&&!roofAt(e.x,e.y)) sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee*FLASH_SEE,e.cone,_aSee*FLASH_SEE);
'@ @'
    if(!sees&&G.lightning>0&&!p.downed&&!roofAt(p.x,p.y)&&!roofAt(e.x,e.y)) sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee*FLASH_SEE,e.cone,_aSee*FLASH_SEE);
    if(sees) e.sirenSeeT=G.t||0;   // v25.xx (sirentune): the moment it last saw him, for the lock-on siren (a chase without sight does not count)
'@

SubRx @'
g5.gain.setValueAtTime(.06*vol,t); g5.gain.exponentialRampToValueAtTime(.001,t+.3);
'@ @'
g5.gain.setValueAtTime(.06*vol*(arguments[3]==='crawler'?0.5:1),t); g5.gain.exponentialRampToValueAtTime(.001,t+.3);   // v25.xx (sirentune): a crawler shout is half level
'@

SubRx @'
if(!G.sim&&dist(e,p)<700) sfx('alarm',e.x,e.y);
'@ @'
if(!G.sim&&dist(e,p)<700) sfx('alarm',e.x,e.y,(e.kind==='crawler')?'crawler':undefined);   // v25.xx (sirentune): the crawler shout at half level
'@

SubRx @'
var VER='25.64';
'@ @'
var VER='25.65';
'@

$pat = "(?m)^  now:'v25\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.65: The lock-on siren now only sounds when a machine really sees you, and crawlers are half as loud. Check 25.65 fails on v25.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
