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

# THE ABANDON CONFIRM IS TWO BUTTONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI CLEANUP uic1 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shot of the
     abandon confirm): THE ABANDON CONFIRM IS A TWO BUTTON QUESTION. Arming it left five buttons in one row, YES, ABANDON THIS RUN, RESUME
     RUN, SETTINGS, FEEDBACK, WHAT IS NEW and NO, KEEP PLAYING, 1050 px of buttons in an 825 px box, hanging out of both frame edges, with RESUME RUN
     and NO, KEEP PLAYING doing one job. While it is armed the box shows only the YES he arms on the far side (v4.24) and the NO on the
     button he just pressed; ESC still closes the box. Nothing is reworded. */
  #root #pausebox.asking #resumebtn, #root #pausebox.asking #pausesetbtn, #root #pausebox.asking #fbbtn, #root #pausebox.asking #wnbtn, #root #pausebox.asking #charselbtn{ display:none !important; }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
    cb.style.display='inline-block';
    this.textContent='NO, keep playing';
'@ @'
    cb.style.display='inline-block';
    this.textContent='NO, keep playing';
    try{ var _pbx=document.getElementById('pausebox'); if(_pbx) _pbx.classList.add('asking'); }catch(_as){}   // v27.xx (uic1): only YES and NO while it is armed
'@

SubRx @'
  // second press on the same button is the NO: disarm and go back.
  cb.style.display='none';
'@ @'
  // second press on the same button is the NO: disarm and go back.
  cb.style.display='none';
  try{ var _pbx2=document.getElementById('pausebox'); if(_pbx2) _pbx2.classList.remove('asking'); }catch(_as2){}   // v27.xx (uic1)
'@

SubRx @'
  if(_ca) _ca.style.display='none';
'@ @'
  if(_ca) _ca.style.display='none';
  try{ var _pbx3=document.getElementById('pausebox'); if(_pbx3) _pbx3.classList.remove('asking'); }catch(_as3){}   // v27.xx (uic1): every disarm gives the box its buttons back
'@

SubRx @'
var VER='28.05';
'@ @'
var VER='28.06';
'@

$pat = "(?m)^  now:'v28\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.06: Abandon run now asks with just two buttons, YES and NO, inside the box. Check 28.06 fails on v28.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
