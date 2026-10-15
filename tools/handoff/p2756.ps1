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

# THE FLOOR CARD AND BACKPACK ARE SOLID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillStyle='rgba(6,9,13,.94)'; ctx.fillRect(wnX,wnY,wnW,wnH);
    ctx.strokeStyle='#3a4552'; ctx.lineWidth=1; ctx.strokeRect(wnX+.5,wnY+.5,wnW-1,wnH-1);
'@ @'
    // v27.xx, UI CLEANUP uic8 (his 2026-10-14 note, from the 1080p shot of the card over the floor): THE CARD IS THE ONE HUD PLATE, AND SOLID. It was a flat 94 percent
    // rectangle with its own blue-grey border, unlike every other plate, and the station signs of the floor (SHOP, CRAFT AND HIRE, SETTINGS) read through its words.
    hudPanel(wnX,wnY,wnW,wnH,1);
'@

SubRx @'
  hudPanel(x,y,PW,hh,0.96);   // v18.13: the one HUD panel
'@ @'
  hudPanel(x,y,PW,hh,(typeof hubBagG!=='undefined'&&G===hubBagG)?1:0.96);   // v18.13: the one HUD panel   // v27.xx (uic8): solid in the Undercroft, where the station signs read through it; in a raid the world still shows through
'@

SubRx @'
var VER='27.55';
'@ @'
var VER='27.56';
'@

$pat = "(?m)^  now:'v27\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.56: The What is New card and the Undercroft backpack are solid plates. Check 27.56 fails on v27.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
