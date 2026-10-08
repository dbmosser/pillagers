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

# THE EXTRACTION CARD SHOWS THE HAUL BIGGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
s+='<span title="'+escHtml(ITEMS[keys[k]].name)+'" style="display:inline-block;margin:2px;border-radius:6px;
'@ @'
s+='<span title="'+escHtml(ITEMS[keys[k]].name)+'" style="display:inline-block;margin:3px;padding:3px;border-radius:8px;
'@

SubRx @'
')+'">'+iconImgHTML(keys[k],34)+'</span>'; n++; } }
'@ @'
')+'">'+iconImgHTML(keys[k],52)+'</span>'; n++; } }   // v19.99, seen on the 4K extraction card (2026-10-08): the haul pictures were 34px chips; 52 now
'@

SubRx @'
var VER='19.98';
'@ @'
var VER='19.99';
'@

$pat = "(?m)^  now:'v19\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.99: The extraction card shows what you brought home in bigger pictures. Check 19.99 fails on v19.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
