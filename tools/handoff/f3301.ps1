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

if ($s.Contains("  {v:'33.01',what:")) { throw "check 33.01 is in the fixture already" }

SubRx @'
  {v:'33.00',what:
'@ @'
  {v:'33.01',what:'the experimental page switches style medals, team combo, fuel fires and the five raid events: each runs with its switch on and stops with it off',
   run:function(){
     if(typeof styleKill!=='function'||typeof styleTick!=='function'||typeof styleDraw!=='function'||typeof teamKill!=='function'||typeof arcadeTeamTake!=='function'||typeof fireTick!=='function'||typeof evEligible!=='function'||typeof arcadeDeploy!=='function'||typeof xfSnap!=='function') return 'SKIP: these features are not all here';
     var bad=[], i, g, p, S, paid, arcs, ks=['xfStyle','xfTeam','xfFire','xfEvDebris','xfEvConvoy','xfEvBounty','xfEvCool','xfEvRamp'], ids=['debris','convoy','bounty','cool','rampage'], was, mc;
     function setK(key,v){ CFG[key]=v; xfSnap(); }
     function ring(){
       arcs=0; mc=new Proxy({},{get:function(o,k){ if(k==='arc') return function(){ arcs++; }; return function(){}; },set:function(){ return true; }});
       styleDraw(mc,p,400,300); return arcs;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       SETSUB='exp'; renderSettings();
       ks.forEach(function(q){ var b=document.getElementById('go_'+q); if(!b) bad.push('ONE: no row for '+q); else if(String(b.textContent).toLowerCase()!=='on'||CFG[q]!==1) bad.push('ONE: '+q+' does not start on'); });
       SETSUB=''; renderSettings();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; ARCADE.holdT=0; g.t=4; S=styS();
       // STYLE MEDALS: the kill medal, the untouched medal and the ring
       [1,0].forEach(function(v){
         setK('xfStyle',v);
         paid=styleKill('crawler',0,false,p.x+10,p.y,{blow:'m',blowT:g.t});
         if(v===1&&!(paid>0)) bad.push('STYLE on: a melee kill paid no medal');
         if(v===0&&paid!==0) bad.push('STYLE off: a melee kill still paid '+paid);
         S.calmAt=0; S.calmK=3; S.hp0=-1; styleTick(p,0.1);
         if(v===1&&S.calmK!==0) bad.push('STYLE on: the calm clock did not run');
         if(v===0&&S.calmK!==3) bad.push('STYLE off: the calm clock still ran');
         ARCADE.streak={n:3,t:g.t-0.05};
         if(v===1&&!(ring()>0)) bad.push('STYLE on: the combo ring was not drawn');
         if(v===0&&ring()>0) bad.push('STYLE off: the combo ring was still drawn');
       });
       setK('xfStyle',1); ARCADE.streak=null;
       // TEAM COMBO
       ARCADE.solo=false;
       [1,0].forEach(function(v){
         setK('xfTeam',v); ARCADE.team=null; ARCADE.mk={x:p.x,y:p.y,at:Date.now(),used:0};
         try{ teamKill(p.x,p.y); }catch(_tk){}
         var took=arcadeTeamTake({x:p.x,y:p.y,lk:0});
         if(v===1&&(!ARCADE.team||took!=='arckill')) bad.push('TEAM on: a pair of kills made no team combo (take '+took+')');
         if(v===0&&(ARCADE.team||took!=='ignored')) bad.push('TEAM off: a team combo still ran (take '+took+')');
       });
       setK('xfTeam',1); ARCADE.team=null; ARCADE.mk=null;
       // FUEL FIRES
       [1,0].forEach(function(v){
         setK('xfFire',v); flowS().fplan=null; fireTick(0.1);
         if(v===1&&!Array.isArray(flowS().fplan)) bad.push('FIRE on: no fuel fire was planned');
         if(v===0&&flowS().fplan) bad.push('FIRE off: a fuel fire was planned');
       });
       setK('xfFire',1);
       // THE FIVE EVENTS: one at a time
       was=evEligible();
       ids.forEach(function(id){ if(was.indexOf(id)<0) bad.push('EVENT on: '+id+' is not eligible'); });
       ids.forEach(function(id){
         var key=XF_EV[id], now;
         setK(key,0); now=evEligible();
         if(now.indexOf(id)>=0) bad.push('EVENT off: '+id+' is still eligible');
         ids.forEach(function(o){ if(o!==id&&was.indexOf(o)>=0&&now.indexOf(o)<0) bad.push('EVENT off: switching '+id+' off also removed '+o); });
         setK(key,1);
       });
       ids.forEach(function(id){ CFG[XF_EV[id]]=0; }); xfSnap();
       if(evEligible().length!==0) bad.push('EVENT off: all five off and '+evEligible().join(',')+' still eligible');
       if(typeof evPlan==='function'){ var E={plan:null}; try{ evPlan(E); if(!E.plan||E.plan.length!==0) bad.push('EVENT off: the plan holds events with all five off'); }catch(_ep){ bad.push('EVENT off: evPlan threw '+_ep); } }
     } catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       SETSUB='';
       for(i=0;i<ks.length;i++){ try{ if(P.gameOpts) delete P.gameOpts[ks[i]]; }catch(_d){} }
       try{ ARCADE.solo=true; ARCADE.team=null; ARCADE.mk=null; }catch(_a){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); xfSnap(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
