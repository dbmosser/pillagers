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

# STASH KEY ROW NAMES KEY 0 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
            b.textContent=String(slot+1);
            b.title=mine?('Already on key '+(slot+1)+', click to clear')
                        :(taken?('Key '+(slot+1)+' holds '+(ITEMS[taken]?ITEMS[taken].name:taken)+', click to replace')
                               :('Put it on key '+(slot+1)+' and carry it up'));
'@ @'
            b.textContent=slotKeyName(slot);   // v28.xx (cw-stashkey0): the tenth key is 0, as on the hotbar (it read 10 after v36.37)
            b.title=mine?('Already on key '+slotKeyName(slot)+', click to clear')
                        :(taken?('Key '+slotKeyName(slot)+' holds '+(ITEMS[taken]?ITEMS[taken].name:taken)+', click to replace')
                               :('Put it on key '+slotKeyName(slot)+' and carry it up'));
'@

SubRx @'
var VER='36.45';
'@ @'
var VER='36.46';
'@

$pat = "(?m)^  now:'v36\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.46: the stash item key row ends on key 0, as the hotbar does Check 36.46 fails on v36.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
