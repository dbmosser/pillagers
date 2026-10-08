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

# AN OPEN PAUSE BOX FOLLOWS THE PAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
r.innerHTML=padB(r.dataset.src); } }catch(_r){} } }
'@ @'
r.innerHTML=padB(r.dataset.src); } }catch(_r){} if(typeof pauseOpen!=='undefined'&&pauseOpen){ try{ keysLegendApply(); }catch(_k){} } } }   // v19.87, code review: an open pause box follows a pad plugged in or pulled out
'@

SubRx @'
var VER='19.86';
'@ @'
var VER='19.87';
'@

$pat = "(?m)^  now:'v19\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.87: Plugging a controller in or out while paused switches the pause box hints at once. Check 19.87 fails on v19.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
