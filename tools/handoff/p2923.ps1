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

# Support MG loosens on a long burst (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BLM_UNITS=1.3;
'@ @'
var BLM_UNITS=1.3;
// v28.xx (cw-lmgbloom), HIS ORDER (2026-10-18): "lmg should get marginally less accurate the longer player fires it continuously". THE SUPPORT MG HEATS UP. lmgHeat counts the seconds
// of unbroken fire (a round inside the gun's own dly counts as unbroken) up to LMG_HEAT_T (4.5 s) and falls LMG_HEAT_REC (5) times as fast once the trigger is let go (about 0.9 s from
// the cap to nothing). At the cap a round's spread is LMG_HEAT_MUL (0.3) wider on top of the bloom, in a straight line, and the cursor ring opens LMG_HEAT_RING (0.5) bloom units
// wider so it shows. The spin-up is untouched. Live play only: G.sim never ticks the bloom, and nothing here draws from the seeded stream.
var LMG_HEAT_T=4.5, LMG_HEAT_MUL=0.3, LMG_HEAT_REC=5, LMG_HEAT_RING=0.5;
function lmgHeatF(p){ return (G&&!G.sim&&p)?Math.max(0,Math.min(1,(p.lmgHeat||0)/LMG_HEAT_T)):0; }
function lmgHeatMul(p,w){ return (w&&w.id&&gunBase(w.id)==='lmg')?1+LMG_HEAT_MUL*lmgHeatF(p):1; }
'@

SubRx @'
p.bloomQ=((p.bloomQ===undefined)?9:p.bloomQ)+dt;
'@ @'
p.bloomQ=((p.bloomQ===undefined)?9:p.bloomQ)+dt;
  if(p.wep&&p.wep.id&&gunBase(p.wep.id)==='lmg'&&p.bloomQ<=t.dly) p.lmgHeat=Math.min(LMG_HEAT_T,(p.lmgHeat||0)+dt);   // v28.xx (cw-lmgbloom): unbroken fire heats the Support MG
  else if(p.lmgHeat>0) p.lmgHeat=Math.max(0,p.lmgHeat-dt*LMG_HEAT_REC);   // and it cools fast the moment the trigger is let go
'@

SubRx @'
tgt=base+BLM_UNITS*(p.bloomK||0); b0=p.bloom||0;
'@ @'
tgt=base+BLM_UNITS*(p.bloomK||0)+LMG_HEAT_RING*lmgHeatF(p); b0=p.bloom||0;   // v28.xx (cw-lmgbloom): the ring shows the heat
'@

SubRx @'
if(fromPlayer&&gunBase(wep.id)==='smg'&&G.player.fireHold) spx*=Math.min(1.9,1+G.player.fireHold*0.45);
'@ @'
if(fromPlayer&&gunBase(wep.id)==='smg'&&G.player.fireHold) spx*=Math.min(1.9,1+G.player.fireHold*0.45);
  if(fromPlayer) spx*=lmgHeatMul(G.player,wep);   // v28.xx (cw-lmgbloom), HIS ORDER (2026-10-18): "lmg should get marginally less accurate the longer player fires it continuously"
'@

SubRx @'
var VER='29.22';
'@ @'
var VER='29.23';
'@

$pat = "(?m)^  now:'v29\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.23: The Support MG gets a little less accurate the longer you hold the trigger, and tightens again a second after you let go. Check 29.23 fails on v29.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
