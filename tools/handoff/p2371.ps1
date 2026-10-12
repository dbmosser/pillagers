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

# THE VERSION RESTARTS AT V0.0001 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function buildExport(){
  var L=[],i;
  L.push('=== PILLAGERS v'+VER+' FLIGHT RECORDER ===');
'@ @'
// v23.6x (feat0c), HIS ANSWER (2026-10-12): the version players see restarts at v0.0001. VER stays the internal ship number the tools,
// the party handshake and the crash records use; verShown turns it into the player number, counting one per build from PVER_RESET
// (the build that made the change shows v0.0001, the next v0.0002). A number from before the reset (an old copy trying to join) is
// shown as it was; floor:1 shows it as v0.0001 instead (the NEW IN card, whose list may predate the reset).
var PVER_RESET='23.71';
function verShown(v,floor){
  var a=String(v===undefined||v===null?'':v).split('.'), b=PVER_RESET.split('.'), n, s;
  n=(parseInt(a[0],10)*100+parseInt(a[1],10))-(parseInt(b[0],10)*100+parseInt(b[1],10))+1;
  if(!(n>=1)){ if(!floor) return 'v'+v; n=1; }
  s=String(n); while(s.length<4) s='0'+s;
  return 'v0.'+s;
}
function buildExport(){
  var L=[],i;
  L.push('=== PILLAGERS '+verShown(VER)+' (build '+VER+') FLIGHT RECORDER ===');
'@

SubRx @'
('A copy on v'+netClean(m.ver,12)+' tried to join. Both copies need to be on the same version, v'+VER+'.')
'@ @'
('A copy on '+verShown(netClean(m.ver,12))+' tried to join. Both copies need to be on the same version, '+verShown(VER)+'.')
'@

SubRx @'
('The host is on v'+netClean(m.ver,12)+' and you are on v'+VER+'. Both
'@ @'
('The host is on '+verShown(netClean(m.ver,12))+' and you are on '+verShown(VER)+'. Both
'@

SubRx @'
ctx.fillText('NEW IN v'+WHATSNEW_VER,
'@ @'
ctx.fillText('NEW IN '+verShown(WHATSNEW_VER,1),
'@

SubRx @'
document.getElementById('titlever').textContent='v'+VER;
'@ @'
document.getElementById('titlever').textContent=verShown(VER);   // v23.6x (feat0c): the player number
'@

SubRx @'
if(_vl) _vl.textContent='v'+VER;
'@ @'
if(_vl) _vl.textContent=verShown(VER);   // v23.6x (feat0c): the player number
'@

SubRx @'
var VER='23.70';
'@ @'
var VER='23.71';
'@

$pat = "(?m)^  now:'v23\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.71: The version shown to players restarts at v0.0001. Check 23.71 fails on v23.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
