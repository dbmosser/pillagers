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

# ERASE ASKS AGAIN AT THE CLICK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        if(w!=='delete'||!armed) return;
'@ @'
        if(w!=='delete'||!armed) return;
        // v18.56, from the code comb (2026-10-07): asked again at the click. A save armed before the player 2 window opened it
        // was erased under that window; now ERASE on a save the other window has open does nothing and the list redraws.
        if(slotBlocked(armed)){ armed=null; try{ document.getElementById('delconfirm').style.display='none'; }catch(_dc){} renderSlots(); return; }
'@

SubRx @'
var VER='18.55';
'@ @'
var VER='18.56';
'@

$pat = "(?m)^  now:'v18\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.56: ERASE never removes a save the other player window has open. Check 18.56 fails on v18.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
