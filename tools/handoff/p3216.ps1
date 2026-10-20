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

# Stash first-raid strip is gone (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #codexmodal .cxt .cxnew{ font-size:16px; }
'@ @'
#root #codexmodal .cxt .cxnew{ font-size:16px; }
/* v28.xx (cw-uc-nofirstkit) b-31 step 7, critic on 04 (P0 "bottom stack", delete the lime first-raid strip, an explaining sentence; Q8). The strip stays in the page but never shows. */
#root #hub #firstkit{ display:none !important; }
'@

SubRx @'
var VER='32.15';
'@ @'
var VER='32.16';
'@

$pat = "(?m)^  now:'v32\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.16: The stash no longer shows the first-raid tip strip. Check 32.16 fails on v32.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
