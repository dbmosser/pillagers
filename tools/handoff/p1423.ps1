$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  // so a window opened FROM the Stash still wins.
  var hb=document.getElementById('hub');
'@ @'
  // so a window opened FROM the Stash still wins.
  // v14.23, controller audit finding 5: THE PAUSE BOX IS A PANEL TOO. It is a .pausebox, not a .modal, so the pad found
  // nothing to focus in it: Resume run and Abandon run were out of reach, a pad player could not abandon a run, and the
  // input fell through to the raid behind it, where D-UP opened and shut the map. A window opened over it still wins.
  var pbx=document.getElementById('pausebox');
  if(pbx&&pbx.classList.contains('on')) return pbx;
  var hb=document.getElementById('hub');
'@
SubRx @'
  if(tap(1)){
    // B backs out: the panel's own Leave or Close if it has one, so any cleanup that
'@ @'
  // v14.23: on the pause box B and Menu resume the run. The search for a way out below would click the hidden RETURN TO
  // CHARACTER SELECTION first, which does nothing in a raid.
  if(md.id==='pausebox'){
    var _pbMenu=tap(9), _pbBack=tap(1);
    if(_pbMenu||_pbBack){
      try{ togglePauseBox(false); }catch(_tp){}
      padSetFocus(null); PAD.focus=null;
      return true;
    }
  }
  if(tap(1)){
    // B backs out: the panel's own Leave or Close if it has one, so any cleanup that
'@
SubRx @'
var VER='14.22';
'@ @'
var VER='14.23';
'@

$pat = "(?m)^  now:'v14\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.23: THE PAUSE BOX WORKS ON A PAD. The pause box is not a .modal, so the pad had nothing to focus in it and a pad player could neither resume nor abandon from it, while D-UP opened and shut the map behind it. The pad now treats the pause box as a panel, after any window opened over it, and B or Menu on it resumes the run. Check 14.23 pauses a raid with a faked pad, then checks the focus lands in the box, D-UP leaves the map shut and B resumes; it fails on v14.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
