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

if ($s.Contains("  {v:'25.74',what:")) { throw "check 25.74 is in the fixture already" }

SubRx @'
  {v:'25.73',what:
'@ @'
  {v:'25.74',what:'his note (use something better than the plop): a belt key press plays no pick chirp; a throwable is a pouch rustle, a bandage or medkit the cloth wrap, a plate the armour clack, an empty cell or a gun already up the soft menu tick, a vacant gun key the locked buzz, and a gun swap by key adds nothing over its holster clack',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof setHot!=='function'||typeof beltSound!=='function'||typeof hotbarSlots!=='function') return 'the belt keys still end in the plain pick chirp (no beltSound)';
     var bad=[], rec=[], kBlip=blip, kFoley=foley, kUi=sndUi, kSim=null, g=null, p=null, sl, i, n, kinds={};
     try{
       __topClear(); __runPrep(); __deploy({kit:['bandage','medkit','plate','frag','smoke'],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; kSim=g.sim; g.sim=false;
       blip=function(t){ rec.push('b:'+t); };
       foley=function(r){ rec.push('f:'+r); return true; };
       sndUi=function(k){ rec.push('u:'+k); return true; };
       // every belt key, one by one: never the pick chirp
       sl=hotbarSlots(); n=sl.length;
       for(i=0;i<n;i++){
         if(i===G.hot) continue;
         rec.length=0; setHot(i);
         if(rec.indexOf('b:pick')>=0) bad.push('belt key '+(i+1)+' ('+(sl[i]&&sl[i].kind)+') still plays the pick chirp ('+rec.join(',')+')');
         if(sl[i]) kinds[sl[i].kind]=1;
         sl=hotbarSlots();
       }
       // the kinds, straight
       g.t=(g.t||0)+5;
       rec.length=0; beltSound({kind:'throw'}); if(rec.join()!=='f:rummage') bad.push('a throwable plays '+rec.join()+', not the pouch rustle');
       rec.length=0; beltSound({kind:'heal'}); if(rec.join()!=='f:bandageWrap') bad.push('a medical item plays '+rec.join()+', not the cloth wrap');
       rec.length=0; beltSound({kind:'armor'}); if(rec.join()!=='f:plateClack') bad.push('a plate plays '+rec.join()+', not the armour clack');
       rec.length=0; beltSound({kind:'empty'}); if(rec.join()!=='u:move') bad.push('an empty cell plays '+rec.join()+', not the soft tick');
       rec.length=0; beltSound({kind:'gun'}); if(rec.join()!=='u:move') bad.push('a gun already up plays '+rec.join()+', not the soft tick');
       rec.length=0; gearFoley('swap',p.wep); beltSound({kind:'gun'}); if(rec.indexOf('u:move')>=0||rec.indexOf('b:pick')>=0) bad.push('a gun swap adds a second sound over its holster clack ('+rec.join()+')');
       g.sim=true; rec.length=0; beltSound({kind:'throw'}); if(rec.length) bad.push('a belt key made a sound under G.sim');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ blip=kBlip; foley=kFoley; sndUi=kUi; }catch(_b){}
       try{ if(g&&kSim!==null) g.sim=kSim; }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,6).join('; '):null; }},
  {v:'25.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
