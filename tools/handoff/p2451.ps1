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

# PILLAGERS TAUNT WHEN THEY HIT YOU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          if(!_mOwn&&!p.specOut&&dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
'@ @'
          if(!_mOwn&&!p.specOut&&dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
          // v23.xx, HIS ANSWERS (2026-10-12), answer 34 b: "pillager taunts". A PILLAGER WHO HITS YOU TAUNTS YOU. The hurt lines (YOU ARE
          // BLEEDING, NEARLY HAD YOU) were written in v2 but nothing ever called them: a pillager taunted only when he spotted you, put
          // you down or ran. Now a round of his that lands on you can draw one, through the same taunt gate (one line on the map at a
          // time, never twice inside four seconds, only within 620), so a firefight has a voice without becoming a wall of shouting.
          // Machines never taunt. The line is picked from his position and the time, as every taunt is, so no seeded draw moves.
          if(hit&&b.owner&&b.owner.kind==='raider'&&!b.owner.merc&&!G.sim){ try{ taunt(b.owner,'hurt'); }catch(_tht){} }
'@

SubRx @'
var VER='24.50';
'@ @'
var VER='24.51';
'@

$pat = "(?m)^  now:'v24\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.51: A pillager whose shot lands on you now taunts you. Check 24.51 fails on v24.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
