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

# CLOSE PLACE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal #closesettings, #root #keysmodal #closekeys{ top:var(--py); }
'@ @'
/* v28.xx (cw-closeplace) job 55 audit of check 24.21: the Settings X sat 24px under its frame and the stash X 8px, the shop, Mainframe and fashion X 12px. v31.02 says one close place: the corner. Now every full window puts the X 12px under its frame top. */
#root #settingsmodal #closesettings, #root #keysmodal #closekeys{ top:calc(var(--py) - var(--sp-3) + 12px); }
'@

SubRx @'
#root #hub #stashclose{ top:8px; }
'@ @'
#root #hub #stashclose{ top:12px; }
'@

SubRx @'
var VER='32.89';
'@ @'
var VER='32.90';
'@

$pat = "(?m)^  now:'v32\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.90: Settings and the stash put the close X 12px under their frame top, like the shop. Check 32.90 fails on v32.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
