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

# RUN INFO: THE GOALS JOIN THE CONDITIONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(G.arcade){ delete HUDBOX.cond; return; }
'@ @'
    var _arc=!!G.arcade;   // v27.42 (info1): the DEMO shows the panel too, with its run goals only
    if(_arc&&!(G.flow&&G.flow.goals&&G.flow.goals.length)){ delete HUDBOX.cond; return; }   // v23.35 (arcade13): no CONDITIONS in the arcade; v27.42 (info1): but its goals
'@

SubRx @'
    // THE FIRST CUT PUT THE EFFECT RIGHT ALIGNED ON THE NAME'S OWN LINE
'@ @'
    // v27.42 (info1), HIS ANSWER (2026-10-14): "merge into conditions, maybe rename it run info". THE RUN GOALS ARE ROWS OF THIS PANEL. They
    // were a panel of their own under CONDITIONS, one more box in the right column for the gun card, the feed and the badges to land on;
    // now the panel is RUN INFO: the conditions and the contracts, then RUN GOALS (the goal, its count and what it pays, DONE in green
    // once it has paid), in one box. In the DEMO, which never had the conditions or the contracts, it holds only the goals.
    if(_arc) rows=[];
    if(G.flow&&G.flow.goals&&G.flow.goals.length){
      rows.push({k:'RUN GOALS',v:'',c:'#ffc04a'});
      for(var _gq=0;_gq<G.flow.goals.length;_gq++){
        var _gl=G.flow.goals[_gq];
        rows.push({k:'',v:String(_gl.t)+((!_gl.done&&_gl.n>1)?('\u00a0\u00a0'+_gl.v+'/'+_gl.n):'')+'\u00a0\u00a0'+(_gl.done?'DONE':('+'+arcadeCr(_gl.chip))),vc:_gl.done?'#7fc4a0':'#cdd6dd'});
      }
    }
    // THE FIRST CUT PUT THE EFFECT RIGHT ALIGNED ON THE NAME'S OWN LINE
'@

SubRx @'
    ctx.fillStyle='#ffc04a'; ctx.fillText('CONDITIONS',bx+pad,ry);
'@ @'
    ctx.fillStyle='#ffc04a'; ctx.fillText('RUN INFO',bx+pad,ry);   // v27.42 (info1): was CONDITIONS
'@

SubRx @'
  EDGEBOX.goals=null; try{ if(flowOn()) goalsHud(ctx); }catch(_gh){}
'@ @'
  EDGEBOX.goals=null;   // v27.42 (info1): the run goals are rows of RUN INFO (goalsHud is kept, not drawn)
'@

SubRx @'
  if(!S.gtold&&(G.t||0)>=1.5){ S.gtold=1; say('RUN GOALS','obj',{sub:'THREE SMALL GOALS'}); }
'@ @'
  if(!S.gtold&&(G.t||0)>=1.5){ S.gtold=1; }   // v27.42 (info1): the goals are rows of RUN INFO all raid, no callout for them at the start
'@

SubRx @'
  if(first&&!S.gtoldP){ S.gtoldP=1; try{ say('RUN GOALS','obj',{sub:'THREE SMALL GOALS'}); }catch(_rg){} }
'@ @'
  if(first&&!S.gtoldP){ S.gtoldP=1; }   // v27.42 (info1): as on the host, no callout for the goals
'@

SubRx @'
var VER='27.41';
'@ @'
var VER='27.42';
'@

$pat = "(?m)^  now:'v27\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.42: The conditions panel is now RUN INFO and holds the run goals with the contracts. Check 27.42 fails on v27.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
