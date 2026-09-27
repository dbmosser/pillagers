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

# A TEAMMATE STILL ON THE RUN CARD GOES UP WITH THE PARTY (stability pass before his co-op session, 2026-09-27).

SubRx @'
function netUpBusy(){
'@ @'
// v16.55, stability (co-op review): A TEAMMATE STILL ON THE RUN CARD GOES UP WITH THE PARTY. After every raid each window shows
// its run card, and a child still reading his when the host took the lift was left below for the whole raid: the kit question
// answered busy and the host word was refused. The card is closed here the way its own button closes it (the run is logged,
// the window goes back to the Undercroft), so the kit question and the ascent reach him.
function netCardOff(){
  var w=document.getElementById('outcome'), b=document.getElementById('oc_btn');
  if(typeof G==='undefined'||!G||!G.over||!w||!b||!w.classList.contains('on')) return false;
  try{ b.click(); }catch(e){ return false; }
  return true;
}
function netUpBusy(){
'@

SubRx @'
  why=netUpBusy();
'@ @'
  why=netUpBusy();
  if(why==='still on the run card'&&netCardOff()) why=netUpBusy();   // v16.55
'@

SubRx @'
    if(netUpBusy()){ netSend(peer,{t:'kitok'}); return 'kit:busy'; }
'@ @'
    if(netUpBusy()==='still on the run card') netCardOff();   // v16.55: the run card closes so the kit question reaches him
    if(netUpBusy()){ netSend(peer,{t:'kitok'}); return 'kit:busy'; }
'@

SubRx @'
var VER='16.54';
'@ @'
var VER='16.55';
'@

$pat = "(?m)^  now:'v16\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.55: A TEAMMATE STILL ON THE RUN CARD GOES UP WITH THE PARTY. Stability pass before a co-op session. After every raid each window shows its run card, and a teammate still reading his when the host took the lift was left below for the whole raid. Now the host asking for kits closes that card the way its own button does (the run is logged) and the teammate is asked for his kit and goes up with the party. Check 16.55 fails on v16.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
