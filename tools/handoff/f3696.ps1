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

if ($s.Contains("  {v:'36.96',what:")) { throw "check 36.96 is in the fixture already" }

SubRx @'
  {v:'36.95',what:
'@ @'
  {v:'36.96',what:'in the Undercroft whoever stands lower on screen is drawn in front (his note of 2026-10-31: his pillager was painted over a crowd pillager standing lower on screen): a crowd pillager whose feet are 20 px lower than his is drawn after him, one 20 px higher is drawn before him, and the seeded stream never moves',
   run:function(){
     if(typeof drawHubWorld!=='function'||typeof drawOp!=='function') return 'this build has no Undercroft floor to draw';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running, and the crowd stands on the Undercroft floor';
     if(!(window.__hubEnter&&window.__topClear&&window.__runPrep)) return 'SKIP: this fixture cannot drive the floor';
     var bad=[], ops=[], oOp=drawOp, oCrowd=(typeof tickHubCrowd==='function')?tickHubCrowd:null, oList=null, spied=false, rng0=null, rng1=null, py;
     function frame(){ ops=[]; try{ drawHubWorld(0); }catch(e){ bad.push('a floor frame threw: '+(e&&e.message||e)); } }
     function order(){ var s=[], j; for(j=0;j<ops.length;j++) s.push(ops[j].hero?'H':'C'); return s.join(''); }
     function body(x,y){ return {x:x,y:y,face:0,coat:'#44505a',look:{},t0:0,talk:0,job:'talk',roam:1,r:13,fade:1,away:0,walking:0,step:0,state:'idle',dest:null,errT:99,stuckT:0,hx:0,hy:0,amp:5,rate:0.6}; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       try{ var pbx=document.getElementById('pausebox'); if(pbx&&pbx.classList.contains('on')){ try{ togglePauseBox(false); }catch(_tp){} if(pbx.classList.contains('on')){ pbx.classList.remove('on'); pauseOpen=false; } } }catch(_pb){}
       if(typeof state==='undefined'||state!=='hub'||!HB||!HB.player||!wc) return 'SKIP: the Undercroft floor is not up here';
       for(var k in keys) keys[k]=false;
       oList=HB.crowd; rng0=RNGS;
       spied=true;
       drawOp=function(x,y,face,ph,coat,pk,mz,mode,iv,st){ ops.push({x:x,y:y,hero:!!(st&&st.hero)}); return oOp.apply(null,arguments); };
       if(oCrowd) tickHubCrowd=function(){};
       py=HB.player.y;
       HB.crowd=[body(HB.player.x+8,py+20)];
       frame(); frame();
       if(order()!=='HC') bad.push('a pillager 20 px lower on screen is drawn '+(order()==='CH'?'under':'out of order with')+' him ('+order()+'), want him first and the pillager over him (HC)');
       HB.crowd=[body(HB.player.x+8,py-20)];
       frame(); frame();
       if(order()!=='CH') bad.push('a pillager 20 px higher on screen is not drawn behind him ('+order()+', want CH)');
       rng1=RNGS;
       if(rng0!==rng1) bad.push('the draw moved the seeded stream');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(spied){ drawOp=oOp; if(oCrowd) tickHubCrowd=oCrowd; } }catch(_r){}
       try{ HB.crowd=oList; }catch(_c){}
       try{ __topClear(); }catch(_t){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'36.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
