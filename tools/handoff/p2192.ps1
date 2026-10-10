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

# A TEAMMATE DOWN IS NEVER LOST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(up&&m.dn&&!g.dn&&g.n>1&&typeof G!=='undefined'&&G&&!G.over&&!G.sim&&(G.seed>>>0)===((+m.sd)>>>0)){ try{ sayWhenFree((netSeatName(s)||'Your teammate')+' is down. Pick them up.'); padRumble(0.55,420); }catch(_md){} }
'@ @'
  // v21.92, the raid text rewrite (fix after the queue): a teammate down is a critical line, so it outranks every ordinary row and is
  // said at once; as a plain line it waited in the queue, where the cap or the time limit could drop it, and it is said only once.
  if(up&&m.dn&&!g.dn&&g.n>1&&typeof G!=='undefined'&&G&&!G.over&&!G.sim&&(G.seed>>>0)===((+m.sd)>>>0)){ try{ sayWhenFree((netSeatName(s)||'Your teammate')+' is down. Pick them up.','crit'); padRumble(0.55,420); }catch(_md){} }
'@

SubRx @'
      sayWhenFree('Extraction '+extLetter(cz)+' closes in two minutes.');   // v14.11, HUD audit: waits its turn instead of writing over a line
'@ @'
      sayWhenFree('Extraction '+extLetter(cz)+' closes in two minutes.','ext');   // v21.92: an extraction line, ranked over ordinary rows so the queue never drops it;   // v14.11, HUD audit: waits its turn instead of writing over a line
'@

SubRx @'
      sayWhenFree('Extraction '+extLetter(cz)+' is closed.');   // v10.75: the letter, as everywhere else; v14.11: waits its turn
'@ @'
      sayWhenFree('Extraction '+extLetter(cz)+' is closed.','ext');   // v21.92: ranked as an extraction line;   // v10.75: the letter, as everywhere else; v14.11: waits its turn
'@

SubRx @'
      setTimeout((function(nm,g0){return function(){ if(G===g0&&!G.over) sayWhenFree('YOUR RIVAL is out here: '+nm+'. He will shoot on sight.'); };})(G.ents[_rv].name,G),4000);   // v13.33: waits its turn
'@ @'
      setTimeout((function(nm,g0){return function(){ if(G===g0&&!G.over) sayWhenFree('YOUR RIVAL is out here: '+nm+'. He will shoot on sight.','warn'); };})(G.ents[_rv].name,G),4000);   // v13.33: waits its turn; v21.92: a warning, so it is said over ordinary rows
'@

SubRx @'
var VER='21.91';
'@ @'
var VER='21.92';
'@

$pat = "(?m)^  now:'v21\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.92: A teammate going down, an extraction closing and your rival showing up are never lost when many lines arrive at once. Check 21.92 fails on v21.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
