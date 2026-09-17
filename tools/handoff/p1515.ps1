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
    if(!e.repeat){
      cycleGameOpt('superhot');
'@ @'
    if(!e.repeat){
      cycleGameOpt('superhot');
      // v15.15, dials audit finding 7: THE SUPERHOT KEY REDRAWS AN OPEN SETTINGS ROW. The Settings rows are drawn only by
      // renderSettings, and this key moved the dial, saved and said so without calling it, so with Settings open the Superhot
      // row kept its old word. Closed on Off, the next raid ran in Superhot. Clicked to turn it on, the row steps from the live
      // dial, so the click turned Superhot off and the row redrew as Off, as if the click did nothing. Redrawn only while the
      // window is open, the same guard toggleTune uses when the console closes over Settings.
      try{ var _smB=document.getElementById('settingsmodal'); if(_smB&&_smB.classList.contains('on')) renderSettings(); }catch(_rsB){}
'@
SubRx @'
var VER='15.14';
'@ @'
var VER='15.15';
'@

$pat = "(?m)^  now:'v15\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.15: THE SUPERHOT KEY REDRAWS AN OPEN SETTINGS ROW. With Settings open, the backquote key turned Superhot on or off but the Superhot row kept its old word, so you could close it trusting Off and ascend in Superhot, or click Off to turn it on and watch the click turn it off and still read Off. The key now redraws an open Settings window. Check 15.15 opens Settings, presses the key both ways and reads the row; it fails on v15.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
