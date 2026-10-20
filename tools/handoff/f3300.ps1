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

if ($s.Contains("  {v:'33.00',what:")) { throw "check 33.00 is in the fixture already" }

SubRx @'
  {v:'32.99',what:
'@ @'
  {v:'33.00',what:'the experimental page switches five pillager and machine features: roles, suppression, machines vs pillagers, elite affixes and the overseer phases each run with their switch on and stop with it off',
   run:function(){
     if(typeof raiderRole!=='function'||typeof suppHit!=='function'||typeof machFoe!=='function'||typeof machHuntRaider!=='function'||typeof affixApply!=='function'||typeof overseerTick!=='function'||typeof xfSnap!=='function') return 'SKIP: these features are not all here';
     var bad=[], i, g, raiders, r, sentry, bul, boss, fe, n0, nOn, g2, ks=['xfRoles','xfSupp','xfFeud','xfAffix','xfOvPh'];
     function setK(key,v){ CFG[key]=v; xfSnap(); }
     function build(offKey){
       var g3;
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(offKey) CFG[offKey]=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g3=__state(); if(!g3||!g3.player||g3.over) return null;
       return g3;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       SETSUB='exp'; renderSettings();
       ks.forEach(function(q){ var b=document.getElementById('go_'+q); if(!b) bad.push('ONE: no row for '+q); else if(String(b.textContent).toLowerCase()!=='on'||CFG[q]!==1) bad.push('ONE: '+q+' does not start on'); });
       SETSUB=''; renderSettings();
       g=build(null); if(!g) return 'SKIP: no raid';
       raiders=g.ents.filter(function(e){ return e.kind==='raider'&&!e.merc&&!e.friendlyPC&&!e.ghost; });
       nOn=g.ents.filter(function(e){ return e.affix; }).length; var nBody=g.ents.length;
       // ROLES
       setK('xfRoles',1); n0=raiders.filter(function(e){ return raiderRole(e)!==null; }).length;
       if(n0<1) bad.push('ROLES on: no pillager has a role');
       setK('xfRoles',0); n0=raiders.filter(function(e){ return raiderRole(e)!==null; }).length;
       if(n0!==0) bad.push('ROLES off: '+n0+' pillagers still have a role');
       setK('xfRoles',1);
       // SUPPRESSION
       r=raiders.filter(function(e){ return e.hostile!==false&&e.hp>0&&!e.downed&&!e.finished; })[0];
       if(!r) bad.push('SUPP: no hostile pillager on this map');
       else {
         [1,0].forEach(function(v){
           setK('xfSupp',v); r.supp=0; r.pinT=0; for(i=0;i<SUPP_N+1;i++) suppHit(r);
           if(v===1&&!(r.pinT>0)) bad.push('SUPP on: rounds past a pillager did not pin him');
           if(v===0&&(r.pinT>0||r.supp)) bad.push('SUPP off: a pillager was still pinned or counted');
         });
         setK('xfSupp',1); r.supp=0; r.pinT=0;
       }
       // MACHINES VS PILLAGERS
       sentry=g.ents.filter(function(e){ return e.kind==='sentry'&&!e.neutral&&!e.boss&&e.hp>0&&!e.downed; })[0];
       setK('xfFeud',1); if(!sentry||machFoe(sentry)!==true) bad.push('FEUD on: a sentry is not a foe to a pillager');
       setK('xfFeud',0); if(sentry&&machFoe(sentry)!==false) bad.push('FEUD off: a sentry is still a foe to a pillager');
       bul=g.ents.filter(function(e){ return e.kind==='bulwark'&&e.hp>0; })[0]; r=raiders[0];
       if(bul&&r){
         var offs=[[70,0],[-70,0],[0,70],[0,-70],[40,40],[-40,-40]], j, on2, off2, seen=false;
         for(j=0;j<offs.length&&!seen;j++){
           r.x=bul.x+offs[j][0]; r.y=bul.y+offs[j][1]; r.downed=false; r.finished=false; bul.downed=false; bul.face=Math.atan2(offs[j][1],offs[j][0]);
           bul.cd=1; setK('xfFeud',1); on2=machHuntRaider(bul,0.1);
           bul.cd=1; setK('xfFeud',0); off2=machHuntRaider(bul,0.1);
           if(on2){ seen=true; if(off2) bad.push('FEUD off: a bulwark still hunted a pillager'); }
         }
         if(!seen) bad.push('FEUD on: no placement made the bulwark hunt a pillager');
       } else bad.push('FEUD: no bulwark or no pillager on this map');
       setK('xfFeud',1);
       // OVERSEER PHASES
       boss=g.ents.filter(function(e){ return e.boss&&e.hp>0; })[0];
       if(!boss&&typeof bossTick==='function'){ g.t=Math.max(g.t||0,5); g.bossDone=0; try{ boss=bossTick(true); }catch(_bt){ boss=null; } }
       if(!boss) bad.push('OVPH: no overseer on this map');
       else {
         [1,0].forEach(function(v){
           boss.hp=(boss.maxhp||boss.hp)*0.5; boss.phase=1; boss.stagT=0; setK('xfOvPh',v);
           var got=overseerTick(boss,g.player,true,0.1);
           if(v===1&&got!==true) bad.push('OVPH on: the overseer did not stagger into phase two');
           if(v===0&&(got!==false||boss.phase!==1)) bad.push('OVPH off: the overseer still changed phase');
         });
         boss.phase=1; boss.stagT=0; setK('xfOvPh',1);
       }
       // ELITE AFFIXES: the function, and the build from the raid start
       fe={kind:'sentry',elite:1,maxhp:100,spd:100};
       setK('xfAffix',1); if(!affixApply(fe,0)) bad.push('AFFIX on: an elite machine got no affix');
       fe={kind:'sentry',elite:1,maxhp:100,spd:100};
       setK('xfAffix',0); if(affixApply(fe,0)!==null||fe.affix) bad.push('AFFIX off: an elite machine still got an affix');
       setK('xfAffix',1);
       if(nOn<1) bad.push('AFFIX on: no elite on the seed 4242 map carries an affix');
       g2=build('xfAffix');
       if(!g2) bad.push('AFFIX off: no raid');
       else {
         if(g2.ents.filter(function(e){ return e.affix; }).length!==0) bad.push('AFFIX off: the raid built with the switch off still has affixes');
         if(g2.ents.length!==nBody) bad.push('AFFIX off: the body count moved from '+nBody+' to '+g2.ents.length);
       }
     } catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       SETSUB='';
       for(i=0;i<ks.length;i++){ try{ if(P.gameOpts) delete P.gameOpts[ks[i]]; }catch(_d){} }
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); xfSnap(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'32.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
