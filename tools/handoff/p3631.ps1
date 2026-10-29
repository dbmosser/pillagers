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

# timelord mode (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
['SUPERHOT MODE','LEFT OF 1']
'@ @'
['timelord mode','LEFT OF 1']
'@

SubRx @'
['LEFT OF 1','superhot on/off']
'@ @'
['LEFT OF 1','timelord on/off']
'@

SubRx @'
{k:'superhot', label:'Superhot mode',
'@ @'
{k:'superhot', label:'timelord mode',
'@

SubRx @'
SUPERHOT (ON|OFF|FOLLOWS THE HOST)
'@ @'
TIMELORD (ON|OFF|FOLLOWS THE HOST)
'@

SubRx @'
function shSay(on){
  var m='SUPERHOT '+(on?'ON':'OFF'), F, i;
  try{ F=(G&&G.fd&&G.fd.lines)?G.fd.lines:null; if(F) for(i=F.length-1;i>=0;i--) if((/^SUPERHOT (ON|OFF)$/).test(F[i].txt||'')) F.splice(i,1); }catch(_sf){}
  if(G&&!G.over&&!G.sim) say(m,'info',{key:'shtoggle'}); else if(typeof say2==='function') say2(m);
}
'@ @'
// v28.xx (cw-cx-timelord), his order 2026-10-29: "rename superhot mode to timelord mode". The saved dial and party word keep their names.
function shSay(on){
  var m='TIMELORD '+(on?'ON':'OFF'), F, i;
  try{ F=(G&&G.fd&&G.fd.lines)?G.fd.lines:null; if(F) for(i=F.length-1;i>=0;i--) if((/^TIMELORD (ON|OFF)$/).test(F[i].txt||'')) F.splice(i,1); }catch(_sf){}
  if(G&&!G.over&&!G.sim) say(m,'info',{key:'shtoggle'}); else if(typeof say2==='function') say2(m);
}
'@

SubRx @'
var _shL='Superhot follows the host while you are in a party.';
'@ @'
var _shL='timelord follows the host while you are in a party.';
'@

SubRx @'
say('SUPERHOT FOLLOWS THE HOST','sys')
'@ @'
say('TIMELORD FOLLOWS THE HOST','sys')
'@

SubRx @'
var VER='36.30';
'@ @'
var VER='36.31';
'@

$pat = "(?m)^  now:'v36\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.31: timelord mode in settings, controls and callouts. Check 36.31 fails on v36.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
