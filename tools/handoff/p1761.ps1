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

# JOIN THE RAID IN PROGRESS IS BIGGER AND NAMES THE LIFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    b.textContent='JOIN THE RAID IN PROGRESS';
'@ @'
    b.innerHTML='JOIN THE RAID IN PROGRESS<div style="font-size:12px;letter-spacing:.06em;opacity:.85;margin-top:3px">or go up at ENTER RAID!</div>';   // v17.61: and the lift, which joins too
'@

SubRx @'
    b.style.cssText='position:fixed;left:50%;top:14px;transform:translateX(-50%);z-index:30;padding:6px 18px';
'@ @'
    b.style.cssText='position:fixed;left:50%;top:14px;transform:translateX(-50%);z-index:30;padding:10px 28px;font-size:20px;letter-spacing:.08em';   // v17.61: big enough to see from the couch
'@

SubRx @'
var VER='17.60';
'@ @'
var VER='17.61';
'@

$pat = "(?m)^  now:'v17\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.61: JOIN THE RAID IN PROGRESS is bigger on the Undercroft floor and says you can also go up at ENTER RAID! Check 17.61 fails on v17.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
