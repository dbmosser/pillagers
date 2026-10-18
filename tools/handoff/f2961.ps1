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

if ($s.Contains("  {v:'29.61',what:")) { throw "check 29.61 is in the fixture already" }

SubRx @'
  {v:'29.60',what:
'@ @'
  {v:'29.61',what:'the run info panel is on the shared palette: accent headings and tx_1 goal rows, not the old off-palette amber and grey',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)||typeof goalsTick!=='function'||typeof careerPostBuild!=='function') return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText, heads={}, rowc=null, g, gl, i, key;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       try{ careerPostBuild(g); }catch(_c){}
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={};
       try{ goalsTick(0.1); }catch(_gt){}
       for(i=0;i<4;i++) __frame(0.016);
       if(!(g.flow&&g.flow.goals&&g.flow.goals.length)) return 'SKIP: the raid has no run goals here';
       g.t=2; try{ goalsTick(0.1); }catch(_g2){}
       gl=g.flow.goals[0]; key=String(gl.t).slice(0,8).toLowerCase();
       proto.fillText=function(t,x,y){ var s=String(t).toLowerCase(); if(/^(run info|run goals)$/.test(s)) heads[s]=String(this.fillStyle).toLowerCase(); else if(rowc===null&&key&&s.indexOf(key)===0) rowc=String(this.fillStyle).toLowerCase(); return o.apply(this,arguments); };
       __frame(0.001);
       if(heads['run info']!==UIC.acc) bad.push('the run info heading is '+heads['run info']+', not the accent '+UIC.acc);
       if(heads['run goals']!==UIC.acc) bad.push('the run goals heading is '+heads['run goals']+', not the accent '+UIC.acc);
       if(rowc!==UIC.tx_1) bad.push('the first goal row is '+rowc+', not tx_1 '+UIC.tx_1);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'29.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
