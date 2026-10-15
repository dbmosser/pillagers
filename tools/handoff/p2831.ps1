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

# KID FIRING LEAVES HIS ITEM ALONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(hs&&hs.kind==='gun'&&!bagGunCell(hs)) e=afTarget(p);   // v22.34: a packed gun the pad walk highlighted is not in his hands
'@ @'
    if(hs&&hs.kind==='gun'&&!bagGunCell(hs)&&!p.hand) e=afTarget(p);   // v22.34: a packed gun the pad walk highlighted is not in his hands; v28.31 (cloud-coop-kid-firing-no-item), CLOUD HUNT 2026-10-15: an item he took out waits for his own trigger
'@

SubRx @'
var VER='28.30';
'@ @'
var VER='28.31';
'@

$pat = "(?m)^  now:'v28\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.31: With Kid firing on, a frag, bandage or plate player 2 takes out now stays in his hand until he uses it himself. Check 28.31 fails on v28.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
