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

if ($s.Contains("  {v:'33.03',what:")) { throw "check 33.03 is in the fixture already" }

SubRx @'
  {v:'33.02',what:
'@ @'
  {v:'33.03',what:'the experimental page switches the raid director and the air strike: each runs with its switch on and stops with it off, and the air strike goal leaves the goal pool with the strike off',
   run:function(){
     if(typeof flowDir!=='function'||typeof flowAmbushOk!=='function'||typeof arcadeWaveOk!=='function'||typeof airKey!=='function'||typeof airScan!=='function'||typeof airCharge!=='function'||typeof goalsMake!=='function'||typeof arcadeDeploy!=='function'||typeof xfSnap!=='function') return 'SKIP: these features are not all here';
     var bad=[], i, g, p, S, D, A, ks=['xfDir','xfAir'], e, r, z, pt, q, a, x, y, seen={}, sd, t, got;
     function setK(key,v){ CFG[key]=v; xfSnap(); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       SETSUB='exp'; renderSettings();
       ks.forEach(function(k){ var b=document.getElementById('go_'+k); if(!b) bad.push('ONE: no row for '+k); else if(String(b.textContent).toLowerCase()!=='on'||CFG[k]!==1) bad.push('ONE: '+k+' does not start on'); });
       SETSUB=''; renderSettings();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; ARCADE.holdT=0; g.t=300; S=flowS();
       // RAID DIRECTOR: a hard hit, the ambush rule, the ring rule
       [1,0].forEach(function(v){
         setK('xfDir',v); S.dir=null; p.hp=p.maxhp||100; D=flowDir(0.1); D.st=1.4; D=flowDir(0.1);
         if(v===1&&!(D.pace===0&&D.ph==='breather')) bad.push('DIR on: a hard hit did not start a breather');
         if(v===0&&(D.pace!==1||D.ph!=='build')) bad.push('DIR off: the director still ran the wave clock (pace '+D.pace+', '+D.ph+')');
         r=flowAmbushOk({ph:'build',quiet:99,waves:5,lastAmb:-999},{x:-9999,y:-9999});
         if(v===1&&r!==true) bad.push('DIR on: a long quiet did not allow an ambush');
         if(v===0&&r!==false) bad.push('DIR off: an ambush was still allowed');
       });
       z=g.zones&&g.zones[0]; pt=null;
       if(!z) bad.push('DIR: the map has no extraction ring');
       else {
         setK('xfDir',0);
         for(q=0;q<48&&!pt;q++){ a=q/48*6.2832; x=z.x+Math.cos(a)*200; y=z.y+Math.sin(a)*200; if(arcadeWaveOk([],{x:x,y:y},x,y,-1,1e9)) pt={x:x,y:y}; }
         if(!pt) bad.push('DIR off: no free spot beside an extraction ring to test the ring rule');
         else { setK('xfDir',1); if(arcadeWaveOk([],{x:pt.x,y:pt.y},pt.x,pt.y,-1,1e9)!==false) bad.push('DIR on: a pack may land on an extraction ring'); }
       }
       setK('xfDir',1);
       // AIR STRIKE: the key, the meter, player 2's meter, the goal pool
       e=g.ents.filter(function(m){ return m.kind==='sentry'&&m.hp>0&&!m.neutral; })[0];
       if(!e) bad.push('AIR: no sentry to charge the meter with');
       [1,0].forEach(function(v){
         setK('xfAir',v); A=airS(); A.m=AIR.need; A.aim=0; A.dealt=0;
         got=airKey();
         if(v===1&&(got!==true||A.aim!==1)) bad.push('AIR on: G with a full meter did not arm the strike');
         if(v===0&&(got!==false||A.aim)) bad.push('AIR off: G still armed the strike');
         A.aim=0; A.m=0; A.dealt=0; A.rdy=0;
         if(e){
           e.airH=e.hp+50; e.pHitT=0.3; e.pHitSeat=0; airScan();
           if(v===1&&A.dealt<50) bad.push('AIR on: damage you dealt did not fill the meter');
           if(v===0&&A.dealt!==0) bad.push('AIR off: the meter still filled');
           A.m=0; A.dealt=0; A.rdy=0; got=airCharge(e,30);
           if(v===1&&!(got>0)) bad.push('AIR on: player 2 damage did not fill the meter');
           if(v===0&&got!==0) bad.push('AIR off: player 2 damage still filled the meter');
           e.airH=e.hp; e.pHitT=0; A.m=0; A.dealt=0; A.rdy=0;
         }
         seen={}; for(sd=1;sd<=40;sd++){ g.seed=sd*977; t={}; goalsMake(t); t.goals.forEach(function(gl){ seen[gl.id]=1; }); }
         if(v===1&&!seen.air1) bad.push('AIR on: the air strike goal never came up in 40 seeds');
         if(v===0&&seen.air1) bad.push('AIR off: the air strike goal was drawn with the strike off');
       });
     } catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       SETSUB='';
       for(i=0;i<ks.length;i++){ try{ if(P.gameOpts) delete P.gameOpts[ks[i]]; }catch(_d){} }
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); xfSnap(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
