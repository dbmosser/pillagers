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

# THE DEMO RAID HAS A 10 MINUTE CLOCK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// Run from startRaid right after the build, in every window that builds the arcade raid, so both builds stay identical.
'@ @'
// v23.6x (feat0e), HIS MODE DESIGN (2026-10-12): "DEMO ... 10 minute raids", and HIS ANSWER 7: when the DEMO clock reaches 0 the site
// BURNS like a normal raid. A DEMO raid now carries a 600 s clock (raidLen), so the countdown, the clock warnings and the burn at 0 are
// the normal raid ones, unchanged; the rings still never close (closeAt stays off) and the build is the same (raidSec 0 at build time).
// The clock reads under the score. A death in the burn does not drop him back into the fire: the run ends (RUN OVER, the score as it
// stood). A rebuild for a late player 2 keeps the clock the run had.
var ARCADE_RAID_SEC=600;
// Run from startRaid right after the build, in every window that builds the arcade raid, so both builds stay identical.
'@

SubRx @'
  g.arcade=1; g.raidLen=0; g.timeLeft=0;
'@ @'
  g.arcade=1; g.raidLen=g.timeLeft=ARCADE_RAID_SEC;   // v23.6x (feat0e): the 10 minute DEMO clock
'@

SubRx @'
  if(G&&G.arcade&&!G.sim){ if(how==='dead') return arcadeRespawn('dead');
'@ @'
  // v23.6x (feat0e): a death in the burn (or with the DEMO clock out) ends the run instead of respawning into the fire. The end is
  // marked (G.arcEnd) and made at the top of the next frame, because the run end lets the raid go (G is null after it) and this is
  // reached from inside the frame (the burn, the death beat), whose remaining lines still read G.
  if(G&&G.arcade&&!G.sim&&G.arcEnd) return;
  if(G&&G.arcade&&!G.sim&&how==='dead'&&raidClockOn()&&(G.nuking||G.timeLeft<=0)){ G.arcEnd='burn'; return; }
  if(G&&G.arcade&&!G.sim){ if(how==='dead') return arcadeRespawn('dead');
'@

SubRx @'
  ok=arcadeDeploy({role:'host',mapIx:P.mapIx});
'@ @'
  var tl0=(typeof G.timeLeft==='number')?G.timeLeft:0;   // v23.6x (feat0e): the run keeps its clock
  ok=arcadeDeploy({role:'host',mapIx:P.mapIx});
  if(ok&&G&&G.arcade&&tl0>0&&G.timeLeft>tl0) G.timeLeft=tl0;
'@

SubRx @'
  ctx.font=fb; ctx.fillStyle='#e8eef2'; hudText(nm,cx,y); w=ctx.measureText(nm).width;
'@ @'
  ctx.font=fb; ctx.fillStyle='#e8eef2'; hudText(nm,cx,y); w=ctx.measureText(nm).width;
  if(raidClockOn()){   // v23.6x (feat0e): the DEMO clock under the score, red under 45 s like the raid clock
    var _ct=Math.ceil(Math.max(0,+G.timeLeft||0)), _cm=Math.floor(_ct/60), _cs=_ct%60;
    ctx.font=fs; ctx.fillStyle=(_ct<45)?'#ff5a4a':'#cdd6dd'; hudText(_cm+':'+(_cs<10?'0':'')+_cs,cx,Math.round(y+h*0.62));
  }
'@

SubRx @'
  if(state!=='raid'||!G||G.sim) return;
'@ @'
  if(state!=='raid'||!G||G.sim) return;
  if(G.arcade&&G.arcEnd){ var _ae=G.arcEnd; G.arcEnd=0; try{ if(!arcadeRunEnd(_ae)) arcadeRaidStop('end'); }catch(_are){} return; }   // v23.6x (feat0e): a run end marked inside the last frame
'@

SubRx @'
var VER='23.91';
'@ @'
var VER='23.92';
'@

$pat = "(?m)^  now:'v23\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.92: A DEMO raid lasts 10 minutes; at 0 the site burns and the run ends. Check 23.92 fails on v23.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
