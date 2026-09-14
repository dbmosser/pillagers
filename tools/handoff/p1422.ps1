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
  if(!PAD.focus||list.indexOf(PAD.focus)<0||!md.contains(PAD.focus)) padSetFocus(list[0]);
'@ @'
  // v14.22, controller audit finding 4: A REBUILT PANEL KEEPS THE PAD'S PLACE. A click that rebuilds the panel (a belt plan
  // cell, Arm, standard or a kit cell on the ascent check; any change in Settings) replaces the focused control, and this
  // line put the focus back on the first control in the panel. On the ascent check that is TAKE THE FREEBIE KIT, so a second
  // A emptied the backpack and the belt plan and ASCEND sent him up with the freebie instead of his own gear; in Settings
  // every change jumped back to the first tab. The focus now returns to the same place in the rebuilt panel, and only a
  // different panel starts at its first control.
  if(!PAD.focus||list.indexOf(PAD.focus)<0||!md.contains(PAD.focus)){
    var _pfi=(PAD.focusMd===md&&typeof PAD.focusIx==='number'&&PAD.focusIx>=0)?Math.min(PAD.focusIx,list.length-1):0;
    padSetFocus(list[_pfi]);
  }
'@
SubRx @'
  if(mv){ var nx=padStep(list,PAD.focus,mv[0],mv[1]); if(nx) padSetFocus(nx); }
'@ @'
  if(mv){ var nx=padStep(list,PAD.focus,mv[0],mv[1]); if(nx) padSetFocus(nx); }
  PAD.focusIx=list.indexOf(PAD.focus); PAD.focusMd=md;
'@
SubRx @'
var VER='14.21';
'@ @'
var VER='14.22';
'@

$pat = "(?m)^  now:'v14\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.22: A REBUILT PANEL KEEPS THE PAD S PLACE. A pad click that rebuilds a panel replaced the focused control, and the focus went back to the first control: on the ascent check that is TAKE THE FREEBIE KIT, so a second A swapped his own gear for the freebie, and in Settings every change jumped back to the first tab. The focus now returns to the same place in the rebuilt panel. Check 14.22 moves the pad two controls down a probe window, clicks one that rebuilds the window, and polls again; it fails on v14.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
