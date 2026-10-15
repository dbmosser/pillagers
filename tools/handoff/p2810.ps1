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

# THE AIR STRIKE NAMES YOUR KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
(padOn()?padB('LB + RB'):keyLabel('KeyG','G'))+' CANCEL',s.x,s.y-ar-U(8));
'@ @'
(padOn()?padB(pbn(4)+' + '+pbn(5)):keyLabel('KeyG','G'))+' CANCEL',s.x,s.y-ar-U(8));   // v28.xx (cloud-menus-air-strike-keys), CLOUD HUNT 2026-10-15: the cancel names the buttons as set (previous gun moved to Y says Y + RB)
'@

SubRx @'
function airHint(){ return (typeof padOn==='function'&&padOn())?padB('LB + RB'):
'@ @'
function airHint(){ return (typeof padOn==='function'&&padOn())?padB(pbn(4)+' + '+pbn(5)):
'@

SubRx @'
function airCapLabel(){ return padOn()?padB('LB+RB'):keyLabel('KeyG','G'); }
'@ @'
function airCapLabel(){ return padOn()?padB(pbn(4)+'+'+pbn(5)):keyLabel('KeyG','G'); }   // v28.xx (cloud-menus-air-strike-keys), CLOUD HUNT 2026-10-15: the chord reads the buttons after CHANGE PAD BUTTONS; the keyboard half was fixed at v27.43
'@

SubRx @'
var VER='28.09';
'@ @'
var VER='28.10';
'@

$pat = "(?m)^  now:'v28\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.10: The air strike prompts name the controller buttons you set, not always LB + RB. Check 28.10 fails on v28.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
