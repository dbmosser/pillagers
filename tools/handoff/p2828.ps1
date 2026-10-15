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

# PLAYER 2 SEES A BURNING DOWNED PILLAGER GET UP EARLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return [e.nid,(k<0)?0:k,Math.round(e.x),Math.round(e.y),+(+e.face||0).toFixed(2),(s<0)?0:s,Math.ceil(clamp(e.hp/mh,0,1)*20),netEntFlags(e)];
'@ @'
  return [e.nid,(k<0)?0:k,Math.round(e.x),Math.round(e.y),+(+e.face||0).toFixed(2),(s<0)?0:s,Math.ceil(clamp(e.hp/mh,0,1)*20),netEntFlags(e),(e.burnT>0?1:0)|((e.downed&&e.getUp>0)?2:0)];  // v28.28 (cloud-coop-getup-vs-burn), CLOUD HUNT 2026-10-15: bit 8388608 is both burning and getting up, so the row carries the two apart
'@

SubRx @'
function netEntFlagsApply(e,f){
'@ @'
function netEntFlagsApply(e,f,bx){  // v28.28 (cloud-coop-getup-vs-burn), CLOUD HUNT 2026-10-15: bx is the row's burning (1) and getting up (2), apart; undefined reads the old shared bit
'@

SubRx @'
  e.burnT=(f&8388608)?0.3:0; e.stunT=(f&16777216)?0.3:0; e.chillT=(f&33554432)?0.3:0; e.frozenT=(f&67108864)?0.3:0; e.corrT=(f&134217728)?0.3:0;   // v23.xx (forge8): drawn here, run by the host only
'@ @'
  e.burnT=((typeof bx==='number')?(bx&1):(f&8388608))?0.3:0; e.stunT=(f&16777216)?0.3:0; e.chillT=(f&33554432)?0.3:0; e.frozenT=(f&67108864)?0.3:0; e.corrT=(f&134217728)?0.3:0;   // v23.xx (forge8): drawn here, run by the host only; v28.28 (cloud-coop-getup-vs-burn), CLOUD HUNT 2026-10-15: burning from the row, apart from the get-up
'@

SubRx @'
  if((f&8388608)&&e.downed){ if(!(e.getUp>0)){ e.getUp=1e-3; if(!G.sim){ try{ var _guN=earsOf(e.x,e.y); blip('pick',_guN.d,_guN.pan); }catch(_gun){} } } } else e.getUp=0;   // pillrevive: the host says he is getting up; the bar fills here
'@ @'
  if(((typeof bx==='number')?(bx&2):(f&8388608))&&e.downed){ if(!(e.getUp>0)){ e.getUp=1e-3; if(!G.sim){ try{ var _guN=earsOf(e.x,e.y); blip('pick',_guN.d,_guN.pan); }catch(_gun){} } } } else e.getUp=0;   // pillrevive: the host says he is getting up; the bar fills here; v28.28 (cloud-coop-getup-vs-burn), CLOUD HUNT 2026-10-15: the get-up from the row, apart from the burn
'@

SubRx @'
    netEntFlagsApply(e,fl);
'@ @'
    netEntFlagsApply(e,fl,(typeof r[8]==='number'&&isFinite(r[8]))?(r[8]|0):undefined);  // v28.28 (cloud-coop-getup-vs-burn), CLOUD HUNT 2026-10-15: the burn and get-up apart
'@

SubRx @'
var VER='28.27';
'@ @'
var VER='28.28';
'@

$pat = "(?m)^  now:'v28\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.28: In co-op, player 2 no longer sees a burning downed pillager start to get up early, and hears the get-up when it really happens. Check 28.28 fails on v28.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
