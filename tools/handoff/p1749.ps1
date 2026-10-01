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

# THE OVERSEER IS DRAWN TO ITS SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
}function drawWardenS(e){
'@ @'
}
// v17.49, polish after his pick 21: THE OVERSEER is drawn to its size. A warden body is 30 across its feet; a bigger one (the
// boss, 44) is drawn scaled up around where it stands, in every window, since its size rides the word that announces it.
function wardenDrawScale(e){ var r=e&&+e.r; return (r>34&&r<80)?r/30:1; }
function drawWardenAt(e){
  var s=wardenDrawScale(e);
  if(s===1){ drawWardenS(e); return 1; }
  wc.save(); wc.translate(e.x,e.y); wc.scale(s,s); wc.translate(-e.x,-e.y);
  try{ drawWardenS(e); } finally { wc.restore(); }
  return s;
}function drawWardenS(e){
'@

SubRx @'
      else if(e2.kind==='warden') drawWardenS(e2);
'@ @'
      else if(e2.kind==='warden') drawWardenAt(e2);   // v17.49: the boss is drawn to its size
'@

SubRx @'
var VER='17.48';
'@ @'
var VER='17.49';
'@

$pat = "(?m)^  now:'v17\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.49: THE OVERSEER now looks the part: it is drawn about half again as big as a plain warden, in both windows of a party. Check 17.49 fails on v17.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
