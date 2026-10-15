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

# ENTER SKIPS THE HAUL REVEAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if((code==='Escape'||code==='Tab')&&!repeat&&G&&G.over){
'@ @'
  // v27.59 (cloud-menus-enter-skips-haul), CLOUD HUNT 2026-10-15: ENTER SKIPS THE HAUL REVEAL, as v27.08 says. Only ESC, TAB, pad A and B and a real click did;
  // with the focus on the page an ENTER did nothing. It skips and leaves the card up; once the haul is all shown ENTER does what it did before.
  // A key typed in the note box never reaches here (the TEXTAREA bail in the keydown listener).
  if((code==='Enter'||code==='NumpadEnter')&&!repeat&&G&&G.over){
    var _oce=document.getElementById('outcome');
    if(_oce&&_oce.classList.contains('on')&&haulRevealSkip()){ if(ev) ev.preventDefault(); return; }
  }
  if((code==='Escape'||code==='Tab')&&!repeat&&G&&G.over){
'@

SubRx @'
var VER='27.58';
'@ @'
var VER='27.59';
'@

$pat = "(?m)^  now:'v27\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.59: ENTER skips the haul reveal on the EXTRACTED card. Check 27.59 fails on v27.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
