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

# END RUN from the demo pause menu halves the score like a death (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(why==='dead'||why==='burn'){ ARCADE.mine=Math.floor(Math.max(0,ARCADE.mine|0)/2); ARCADE.mate=Math.floor(Math.max(0,ARCADE.mate|0)/2); }

'@ @'
  // v31.27 (cw-endhalf), HIS Q60 (2026-10-18): "Ending early halves the score, the same as dying." END RUN from the pause menu (why 'menu') halves both scores like a death or the burn.
  // An idle out stays as it was (question 78 decides it) and an extraction still doubles (arcadeX2).
  if(why==='dead'||why==='burn'||why==='menu'){ ARCADE.mine=Math.floor(Math.max(0,ARCADE.mine|0)/2); ARCADE.mate=Math.floor(Math.max(0,ARCADE.mate|0)/2); }
'@

SubRx @'
  ARCADE.endSend={id:id,at:now,last:now,x2:x2,ko:ko};
  netSamePost(ko?{t:'arcend',pair:NET.pair,run:id,x2:x2,ko:1}:{t:'arcend',pair:NET.pair,run:id,x2:x2});

'@ @'
  var hf=(!x2&&ARCADE.over&&ARCADE.over.why==='menu')?1:0;   // v31.27 (cw-endhalf): the run ended on END RUN, so player 2 halves its figures too (no failure piece: hf, not ko)
  ARCADE.endSend={id:id,at:now,last:now,x2:x2,ko:ko,hf:hf};
  var _am={t:'arcend',pair:NET.pair,run:id,x2:x2}; if(ko) _am.ko=1; if(hf) _am.hf=1;
  netSamePost(_am);
'@

SubRx @'
  netSamePost(e.ko?{t:'arcend',pair:NET.pair,run:e.id,x2:e.x2?1:0,ko:1}:{t:'arcend',pair:NET.pair,run:e.id,x2:e.x2?1:0});

'@ @'
  var _am={t:'arcend',pair:NET.pair,run:e.id,x2:e.x2?1:0}; if(e.ko) _am.ko=1; if(e.hf) _am.hf=1;   // v31.27 (cw-endhalf): the same word every time, hf kept for END RUN
  netSamePost(_am);
'@

SubRx @'
} else if(m.ko){ ARCADE.mine=Math.floor
'@ @'
} else if(m.ko||m.hf){ ARCADE.mine=Math.floor
'@

SubRx @'
why:(m&&m.x2)?'extract':((m&&m.ko)?'dead':'')
'@ @'
why:(m&&m.x2)?'extract':((m&&m.ko)?'dead':((m&&m.hf)?'menu':''))
'@

SubRx @'
else if(oc&&(o.why==='dead'||o.why==='burn')) ln.splice(1,0,['aoh','KIA -50%']);
'@ @'
else if(oc&&(o.why==='dead'||o.why==='burn')) ln.splice(1,0,['aoh','KIA -50%']); else if(oc&&o.why==='menu') ln.splice(1,0,['aoh','ended early -50%']);
'@

SubRx @'
var VER='31.26';
'@ @'
var VER='31.27';
'@

$pat = "(?m)^  now:'v31\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.27: End run from the demo pause menu now counts half the score, on the RUN OVER card (both players) and the board, the same as dying. Check 31.27 fails on v31.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
