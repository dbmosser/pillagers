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

# PRE-RAID: WIDER KIT COLUMN SO PACK NAMES SHOW WHOLE, A CALM BUY BUTTON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#srkitcol{ flex:1 1 0; min-width:0; max-width:400px;
'@ @'
#srkitcol{ flex:1 1 0; min-width:0; max-width:480px;
'@

SubRx @'
border:1px solid var(--acc); border-radius:0; color:var(--acc); font:700 16px var(--f-cond);
'@ @'
border:1px solid var(--ui-line-hi); border-radius:0; color:var(--tx-1); font:700 16px var(--f-cond);
'@

SubRx @'
var VER='33.47';
'@ @'
var VER='33.48';
'@

$pat = "(?m)^  now:'v33\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.48: The pre-raid pack names show in full and the price buttons are calmer. Check 33.48 fails on v33.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
