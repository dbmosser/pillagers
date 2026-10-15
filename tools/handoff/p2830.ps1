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

# RAID EVENTS END FOR PLAYER 2 WHEN THE HOST LEAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ if(m.fl) flowNetTake(m.fl); }catch(_fnt){}   // v27.04 (coop1): the host raid flow, kept as the host has it
'@ @'
  try{ if(m.fl) flowNetTake(m.fl); else if(m.fl===null&&flowPeer()) flowHostOff(); }catch(_fnt){}   // v28.30 (cloud-coop-host-out-events-end), CLOUD HUNT 2026-10-15: a spectating host (extracted or dead) sends fl null, so its live raid events end here too instead of staying on for good
'@

SubRx @'
function flowNetTake(fl){
  if(!fl||typeof fl!=='object'||!flowOn()||!flowPeer()) return 0;
'@ @'
function flowHostOff(){   // v28.30 (cloud-coop-host-out-events-end), CLOUD HUNT 2026-10-15: the host left the raid (extracted or dead and spectating): every live or warned event fades out on this window, and no later host flow word is taken this raid
  var S=G&&G.flow, L, i, e, n=0;
  if(!S||!S.hostIn||S.hostOff) return 0;
  S.hostOff=1; L=(S.ev&&S.ev.live)||[];
  for(i=0;i<L.length;i++){ e=L[i]; if(e&&(e.ph==='live'||e.ph==='warn')){ e.ph='end'; e.et=0; n++; } }
  return n;
}
function flowNetTake(fl){
  if(!fl||typeof fl!=='object'||!flowOn()||!flowPeer()||(G.flow&&G.flow.hostOff)) return 0;   // v28.30 (cloud-coop-host-out-events-end), CLOUD HUNT 2026-10-15: nothing from the host flow once it has left the raid (a late word would bring an ended event back)
  flowS().hostIn=1;   // v28.30 (cloud-coop-host-out-events-end), CLOUD HUNT 2026-10-15: this window has taken host flow, so a later fl null means the host left
'@

SubRx @'
var VER='28.29';
'@ @'
var VER='28.30';
'@

$pat = "(?m)^  now:'v28\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.30: If your host extracts or goes down while a coolant rupture or another raid event is on, it now ends for you instead of leaving the fog on you for the rest of the raid. Check 28.30 fails on v28.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
