$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'27.42',what:")) { throw "check 27.42 is in the fixture already" }

SubRx @'
  {v:'27.41',what:
'@ @'
  {v:'27.42',what:'his answer: the run goals are rows of one panel with the contracts, called RUN INFO, and there is no separate goals panel; in the DEMO the panel holds the goals alone',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame||!window.__textTrace||typeof goalsHud!=='function'||typeof careerPostBuild!=='function') return 'SKIP: no raid or goals here';
     var bad=[], g, tr, i, gl, at, wasA, ok;
     function at2(t){ return tr.filter(function(e){ return e.t.indexOf(t)===0; }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       try{ careerPostBuild(g); }catch(_c){}
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={};
       try{ goalsTick(0.1); }catch(_gt){}
       for(i=0;i<4;i++) __frame(0.016);
       if(!(g.flow&&g.flow.goals&&g.flow.goals.length)) return 'SKIP: the raid has no run goals here';
       g.t=2; try{ goalsTick(0.1); }catch(_g2){}
       if(g.fd&&g.fd.lines.some(function(l){ return l.txt.indexOf('RUN GOALS')===0; })) bad.push('a RUN GOALS callout is still said at the start of the raid');
       gl=g.flow.goals[0];
       tr=__textTrace(function(){ __frame(0.016); });
       if(!at2('RUN INFO').length) bad.push('the panel is not called RUN INFO');
       if(at2('CONDITIONS').length) bad.push('the panel still says CONDITIONS');
       if(!at2('RUN GOALS').length) bad.push('RUN GOALS is not a heading of the panel');
       if(!at2(String(gl.t)).length) bad.push('the first run goal ('+gl.t+') is not drawn');
       if(EDGEBOX.goals) bad.push('a separate run goals panel is still drawn');
       if(!HUDBOX.cond) bad.push('there is no info panel box');
       else if(at2('RUN GOALS').length&&(at2('RUN GOALS')[0].y<HUDBOX.cond.y*(DPRH||1)||at2('RUN GOALS')[0].y>(HUDBOX.cond.y+HUDBOX.cond.h)*(DPRH||1)+2)) bad.push('RUN GOALS is not inside the info panel');
       // the DEMO holds the goals only
       wasA=g.arcade; g.arcade=1;
       try{ for(i=0;i<3;i++) __frame(0.016); tr=__textTrace(function(){ __frame(0.016); }); } finally { g.arcade=wasA; }
       if(!at2('RUN INFO').length) bad.push('the DEMO panel is not drawn');
       if(at2('CONTRACTS').length) bad.push('the DEMO panel lists contracts');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.arcade=0; g2.career=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
