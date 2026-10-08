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

# THE NEW IN CARD SPEAKS CONTROLLER ON A CONTROLLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillText('press ENTER or walk to dismiss',_wnWW/2,wnY+wnH-LH(12));
'@ @'
    // v19.72, seen on the controller pass (2026-10-08): on a controller (player 2 in co-op) no pad button closes this card, walking
    // does (below), and the line named ENTER, a key the pad player does not have. On a pad it names only the walk.
    ctx.fillText((PAD&&PAD.on)?'walk to dismiss':'press ENTER or walk to dismiss',_wnWW/2,wnY+wnH-LH(12));
'@

SubRx @'
var VER='19.71';
'@ @'
var VER='19.72';
'@

$pat = "(?m)^  now:'v19\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.72: On a controller the what is new card says walk to dismiss. Check 19.72 fails on v19.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
