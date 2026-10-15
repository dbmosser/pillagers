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

if ($s.Contains("  {v:'27.84',what:")) { throw "check 27.84 is in the fixture already" }

SubRx @'
  {v:'27.83',what:
'@ @'
  {v:'27.84',what:'feel2h, a cloud review finding (#16): hit-stop cannot stun-lock a body. A stream of heavy rounds (DOUBLE DAMAGE and RAPID FIRE) holds a body frozen at most a fifth of the time, one heavy round still stops it for the same beat, and a second one after the immunity stops it again',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof hitStopOn!=='function'||typeof elemTick!=='function') return 'SKIP: no hit stop here';
     var bad=[], g, p, all, cr, t, frozen, n, ok1, ok2, ok3;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice();
       cr=all.filter(function(x){ return x.kind==='crawler'&&x.hp>0&&!x.downed&&!x.boss; })[0];
       if(!cr) return 'SKIP: no crawler on this map';
       g.ents=[cr]; cr.hp=cr.maxhp=1e6; cr.stopT=0; cr.stopImm=0;
       // ONE: one heavy round still stops it, once
       ok1=hitStopOn(cr,64);
       if(!ok1||!(cr.stopT>0)) bad.push('ONE: a heavy round left no hit-stop');
       // TWO: a stream of heavy rounds, 66 ms apart for two seconds: frozen at most a third of the time
       cr.stopT=0; cr.stopImm=0; frozen=0; n=0;
       for(t=0;t<2000;t++){ if(t%66===0) hitStopOn(cr,64); elemTick(0.001); n++; if(cr.stopT>0) frozen++; }
       if(!(frozen/n<=0.30)) bad.push('TWO: a stream of heavy rounds held the body frozen '+Math.round(100*frozen/n)+' percent of two seconds, not 30 or less');
       if(!(frozen>0)) bad.push('TWO: a stream of heavy rounds never stopped the body');
       // THREE: after the immunity a heavy round stops it again
       cr.stopT=0; cr.stopImm=0; hitStopOn(cr,64); for(t=0;t<400;t++) elemTick(0.001);
       if(cr.stopT>0) bad.push('THREE: the stop did not wear off in 0.4 s ('+cr.stopT+')');
       ok3=hitStopOn(cr,64);
       if(!ok3||!(cr.stopT>0)) bad.push('THREE: a heavy round 0.4 s after the last stopped nothing');
       // FOUR: a light round does nothing, as before
       cr.stopT=0; cr.stopImm=0;
       if(hitStopOn(cr,16)||cr.stopT>0) bad.push('FOUR: a 16 damage round stopped the body');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&all) g.ents=all.slice(); if(cr){ cr.stopT=0; cr.stopImm=0; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
