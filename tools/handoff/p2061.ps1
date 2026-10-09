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

# A CHARGE IN YOUR HAND HURTS AFTER A REVIVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function cookOff(){
  var p=G.player;
  p.cooking=0; p.cookT=0; p.cookKind=null;
'@ @'
function cookOff(){
  var p=G.player;
  p.cooking=0; p.cookT=0; p.cookKind=null;
  // v20.61, from the whole-game bug hunt of 2026-10-08 (H5): A CHARGE THAT GOES OFF IN YOUR HAND HURTS YOU, EVEN JUST AFTER A REVIVE.
  // Every pick-up (your own F, your hire, a teammate) gives two seconds of cover, and damagePlayer ignores a hit while it runs, so
  // a Frag Charge cooked within 0.9 seconds of standing up went off in your hand and took nothing from you while it took up to 140
  // from everything around you. The roll already drops its cover at the cook-off (v15.08); every cook-off does now, here, so the
  // two standing paths get it too. The blast draws only what any hit on you draws.
  p.iv=0;
'@

SubRx @'
var VER='20.60';
'@ @'
var VER='20.61';
'@

$pat = "(?m)^  now:'v20\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.61: A frag charge held too long in your hand now hurts you even just after you are picked up. Check 20.61 fails on v20.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
