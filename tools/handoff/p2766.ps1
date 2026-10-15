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

# KID ROWS PICKED UP AT LAUNCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  PLOADED=true;
'@ @'
  PLOADED=true;
  try{ kidSync(); }catch(_kb){}   // v27.66 (cloud-menus-kid-sync-launch), CLOUD HUNT 2026-10-15: the kid rows the other window set were pulled only on its storage event and when Settings opened, so a window launched later played stale Kid damage, Kid firing and comes back after death; pulled once here at launch (not in loadProfile, which Restore backup also runs)
'@

SubRx @'
var VER='27.65';
'@ @'
var VER='27.66';
'@

$pat = "(?m)^  now:'v27\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.66: A window opened later now starts with the kid rows the other window set. Check 27.66 fails on v27.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
