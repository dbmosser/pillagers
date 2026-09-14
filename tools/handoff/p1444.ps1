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
    function renderSlots(){
      var host=document.getElementById('slotlist'); if(!host) return;
'@ @'
    function renderSlots(){
      var host=document.getElementById('slotlist'); if(!host) return;
      // v14.44, title and saves audit finding 4: THE FULL SAVES LABEL CLEARS WHEN THE LIST IS DRAWN AGAIN. CREATE A NEW SAVE
      // with all eight saves in use rewrote its own label for good, and nothing put it back after a delete freed a save.
      var _ngl=document.getElementById('newgame'); if(_ngl) _ngl.textContent='CREATE A NEW SAVE';
'@
SubRx @'
var VER='14.43';
'@ @'
var VER='14.44';
'@

$pat = "(?m)^  now:'v14\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.44: THE FULL SAVES LABEL CLEARS WHEN A SAVE IS FREED. Pressing CREATE A NEW SAVE with all eight saves in use changed the button to say they are full, and it kept saying so after a delete freed one. The save list redraw now puts the label back. Check 14.44 sets the full label and redraws the list; it fails on v14.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
