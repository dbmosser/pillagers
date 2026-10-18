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

# PAUSE FRAME FIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
b.style.setProperty('--pbh',Math.max(400,Math.ceil(bo-t)+64)+'px');
'@ @'
// v28.xx (cw-pausefit) critic c-31 round 3 (pause 25/42/49 at 3): the title sat 14px under the card top and the Esc hint touched the bottom, because the hint is a pseudo element the child loop above cannot see. The frame now adds the hint row (24 gap, 16 text, 8 margin) when it shows, so the title and the hint both get the 32px the card pads with
    var _hint=0; try{ _hint=(getComputedStyle(b,'::after').display!=='none'&&/Esc/.test(getComputedStyle(b,'::after').content))?48:0; }catch(_h){}
    b.style.setProperty('--pbh',Math.max(400,Math.ceil(bo-t)+64+_hint)+'px');
'@

SubRx @'
var VER='29.56';
'@ @'
var VER='29.57';
'@

$pat = "(?m)^  now:'v29\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.57: The pause card gives its title and hint room. Check 29.57 fails on v29.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
