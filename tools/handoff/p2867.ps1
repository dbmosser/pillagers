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

# KIA IS A 50 PERCENT SCORE PENALTY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
fin=ex?s*2:s, b=c.b||{}
'@ @'
fin=ex?s*2:Math.floor(s/2), b=c.b||{}
'@

SubRx @'
  if(ex) h+=row('','<span class="lgt">EXTRACTION</span><span class="lgl">x2</span>'+cnt(s,'+'));
'@ @'
  if(ex) h+=row('','<span class="lgt">EXTRACTION</span><span class="lgl">x2</span>'+cnt(s,'+'));
  else if(s>0) h+=row('lost','<span class="lgt">KIA</span><span class="lgl">-50%</span><b>-'+arcadeCr(s-fin)+'</b>');   // v28.67 (lean1): HIS RULE, KIA is a 50% score penalty
'@

SubRx @'
<b><s>+'+arcadeCr(s)+'</s> LOST</b>
'@ @'
<b><s>+'+arcadeCr(fin)+'</s> LOST</b>
'@

SubRx @'
R=careerBoardAdd(how,(how==='extract')?fin:s);
'@ @'
R=careerBoardAdd(how,(how==='extract')?fin:Math.floor(s/2));
'@

SubRx @'
  var host=(ARCADE.role==='host'), me={s:Math.max(0,ARCADE.mine|0),k:ARCADE.kills|0,x:ARCADE.ext|0,d:ARCADE.deaths|0},
'@ @'
  // v28.67 (lean1), HIS ORDER (2026-10-15): "EXTRACTING should be a 2x multiplier on score, KIA should be a 50% penalty". The extraction x2 was already in the
  // DEMO (arcadeX2) and the CAREER payout; a run that ends on a death or the burn now counts half its score, on the RUN OVER card, the board row and the CAREER ledger.
  if(why==='dead'||why==='burn'){ ARCADE.mine=Math.floor(Math.max(0,ARCADE.mine|0)/2); ARCADE.mate=Math.floor(Math.max(0,ARCADE.mate|0)/2); }
  var host=(ARCADE.role==='host'), me={s:Math.max(0,ARCADE.mine|0),k:ARCADE.kills|0,x:ARCADE.ext|0,d:ARCADE.deaths|0},
'@

SubRx @'
if(m.x2){ ARCADE.mine=Math.max(0,ARCADE.mine|0)*2; ARCADE.mate=Math.max(0,ARCADE.mate|0)*2; }
'@ @'
if(m.x2){ ARCADE.mine=Math.max(0,ARCADE.mine|0)*2; ARCADE.mate=Math.max(0,ARCADE.mate|0)*2; } else if(m.ko){ ARCADE.mine=Math.floor(Math.max(0,ARCADE.mine|0)/2); ARCADE.mate=Math.floor(Math.max(0,ARCADE.mate|0)/2); }
'@

SubRx @'
if(oc&&o.why==='extract') ln.splice(1,0,['aoh','EXTRACTED x2']);
'@ @'
if(oc&&o.why==='extract') ln.splice(1,0,['aoh','EXTRACTED x2']); else if(oc&&(o.why==='dead'||o.why==='burn')) ln.splice(1,0,['aoh','KIA -50%']);
'@

SubRx @'
var VER='28.66';
'@ @'
var VER='28.67';
'@

$pat = "(?m)^  now:'v28\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.67: Dying now halves your run score (KIA -50%), as extracting doubles it. Check 28.67 fails on v28.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
