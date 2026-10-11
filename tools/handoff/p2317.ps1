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

# NO DOWNED LABEL THROUGH THE WALLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          label(e.x,e.y-16,(e.name||'PILLAGER')+' DOWNED','#ffc04a',0,true);
'@ @'
          // v23.17, parked by the raid text audit of 2026-10-09: ONLY A FALL YOU COULD SEE. Machines down pillagers anywhere on the map, and this
          // label printed through walls, telling him where a man lay; the kill label below has asked canSee since it shipped.
          if(G.player&&canSee(G.player.x,G.player.y,G.player.face,e.x,e.y,G.vseg)) label(e.x,e.y-16,(e.name||'PILLAGER')+' DOWNED','#ffc04a',0,true);
'@

SubRx @'
          if(!G.sim){ label(TG.x,TG.y-18,'PICKED UP','#ffc04a',0,true); }
'@ @'
          if(!G.sim&&G.player&&canSee(G.player.x,G.player.y,G.player.face,TG.x,TG.y,G.vseg)){ label(TG.x,TG.y-18,'PICKED UP','#ffc04a',0,true); }   // v23.17: only a pick-up he could see
'@

SubRx @'
var VER='23.16';
'@ @'
var VER='23.17';
'@

$pat = "(?m)^  now:'v23\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.17: The DOWNED and PICKED UP labels over pillagers show only when you can see him, not through walls. Check 23.17 fails on v23.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
