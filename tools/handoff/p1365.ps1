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

# IN-RAID AUDIT OF 2026-09-14, finding 4: A MEDKIT ON ITS OWN BELT KEY SAID ALREADY HEALING.
# useMedical measures what he can reach as the lower of health plus the queue and the running
# heal's ceiling (v12.04), so two Bandages queued at 50 health still leave room for a Medkit.
# The named-slot path in useHot tested health plus queue alone against full, so the same
# Medkit on its own key was refused as Already healing. Two ways in, one rule.
SubRx @'
      if(_pp.hp+(_pp.healQ||0)>=_pp.maxhp){
'@ @'
      // v13.65, in-raid audit: the same reach as useMedical. A queue that stops at a
      // Bandage's 85 does not make a Medkit on its own key Already healing.
      if(Math.min(_pp.hp+(_pp.healQ||0),(_pp.healCap===undefined?_pp.maxhp:_pp.healCap))>=_pp.maxhp){
'@
SubRx @'
var VER='13.64';
'@ @'
var VER='13.65';
'@

$pat = "(?m)^  now:'v13\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.65: A MEDKIT ON ITS OWN BELT KEY IS NOT REFUSED AS ALREADY HEALING. In-raid audit of 2026-09-14, finding 4: useMedical has measured reach as the lower of health plus queue and the running ceiling since v12.04, but the named-slot path in useHot tested health plus queue alone, so with two Bandages queued at 50 health a Medkit bound to a key was refused while the Medical cell used it. The slot path now uses the same reach. Check 13.65 binds a Medkit to a key with Bandage heal queued past full under an 85 ceiling and requires it used, with a plain use at 50 as the control; it fails on v13.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
