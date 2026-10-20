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

# STASH SETUP NAMES FIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #hub #kitsetup .kst{min-height:48px;}
'@ @'
/* v28.xx (cw-cx-kitnamesfit): v28.20 found clipped 20px names. Keep the nine-key grid and wheel compass; give each name its own row below the picture. */
#root #hub #kitsetup .kst{position:relative;display:grid;grid-template-columns:minmax(0,1fr);grid-template-rows:40px 24px;gap:4px;height:76px;min-height:76px;padding:3px 1px;}
#root #hub #kitsetup .kst .ic{grid-column:1;grid-row:1;justify-self:center;align-self:center;}
#root #hub #kitsetup .kst span{grid-column:1;grid-row:2;display:block;width:100%;line-height:24px;text-align:center;}
#root #hub #kitsetup .kst b{position:absolute;top:4px;left:4px;}
#root #hub #kitsetup .kstc{height:76px;}
'@

SubRx @'
var VER='32.88';
'@ @'
var VER='32.89';
'@

$pat = "(?m)^  now:'v32\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.89: Gun key and wheel names sit below their pictures and keep the same compass and key order. Check 32.89 fails on v32.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
