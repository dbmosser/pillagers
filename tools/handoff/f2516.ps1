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

if ($s.Contains("  {v:'25.16',what:")) { throw "check 25.16 is in the fixture already" }

SubRx @'
  {v:'25.15',what:
'@ @'
  {v:'25.16',what:'his order 2026-10-12, pillagers say no words: no taunt() and no TAUNT lines are left; a pillager spotting him, a pillager round hitting him, him going down beside a pillager and a pillager breaking off to extract draw no bubble over the pillager; the spot still plays the seen swell once, gated to once in four seconds',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof updateEnts!=='function'||typeof updateBullets!=='function'||typeof damagePlayer!=='function'||typeof emoteBubble!=='function') return 'SKIP: no raid here';
     var bad=[], skip='', g, p, R=null, E0=null, kr=null, f, i, k, ok=false, own=false, oBlip=blip, oSfx=sfx, oEB=emoteBubble, seen=0, bubs=[];
     if(typeof taunt!=='undefined') bad.push('the taunt function is still in the game');
     if(typeof TAUNT!=='undefined') bad.push('the taunt lines are still in the game');
     function look(e){ e.face=Math.atan2(p.y-e.y,p.x-e.x); e.state='patrol'; e.alert=0; e.tx=e.x; e.ty=e.y; }
     function near(b){ return !!R&&Math.abs(b.x-R.x)<70&&Math.abs(b.y-R.y)<90; }
     function spot(){ look(R); for(f=0;f<30&&R.state!=='chase';f++) updateEnts(0.016); return R.state==='chase'; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++){ var en=g.ents[i]; if(en&&en.kind==='raider'&&!en.merc&&!en.friendlyPC&&!en.downed&&en.hp>0){ R=en; break; } }
       if(!R) return 'SKIP: no pillager on this map';
       kr={x:R.x,y:R.y,face:R.face,state:R.state,alert:R.alert,tx:R.tx,ty:R.ty};
       blip=function(t){ if(String(t)==='seen') seen++; }; sfx=function(){};
       emoteBubble=function(x,y){ bubs.push({x:x,y:y,g:arguments[2]}); return oEB.apply(this,arguments); }; own=true;
       p.iv=99; p.crouch=false; p.hp=100; p.downed=false;
       E0=g.ents; g.ents=[R];
       var OFF=[[-140,0],[140,0],[0,140],[0,-140]];
       for(k=0;k<OFF.length&&!ok;k++){ R.x=p.x+OFF[k][0]; R.y=p.y+OFF[k][1]; g.tauntAt=-99; g.seenBlipAt=undefined; seen=0; bubs.length=0; ok=spot(); }
       if(!ok) skip='staging: a pillager 140 away facing him never acquired him ('+R.state+')';
       else {
         if(seen!==1) bad.push('a pillager who spotted him played the seen swell '+seen+' times, not once');
         if(bubs.some(near)) bad.push('a pillager who spotted him drew a mark over his head');
         seen=0; spot();
         if(seen!==0) bad.push('a second sighting inside four seconds played the seen swell again');
         g.t=(g.t||0)+4.5; seen=0; g.tauntAt=-99; spot();
         if(seen!==1) bad.push('a sighting four seconds later did not play the seen swell ('+seen+')');
         bubs.length=0; g.tauntAt=-99; p.iv=0; p.hp=100;
         g.bullets.length=0; g.bullets.push({x:p.x,y:p.y,vx:0.01,vy:0,dmg:1,life:0.5,player:false,owner:R,tint:'#ffffff',thru:0}); updateBullets(0.001);
         if(!(p.hp<100)) skip=skip||'staging: the pillager round did not land';
         if(bubs.some(near)) bad.push('a pillager round that hit him drew a mark over the pillager');
         bubs.length=0; g.tauntAt=-99; p.iv=0; p.armor=0; p.hp=1;
         damagePlayer(40,'raider',R.name||'Pillager',R.x,R.y);
         if(!p.downed) skip=skip||'staging: he did not go down';
         if(bubs.some(near)) bad.push('going down beside a pillager drew a mark over the pillager');
         p.downed=false; p.downT=0; p.hp=100; p.iv=99;
         bubs.length=0; g.tauntAt=-99; R._fledSaid=0; R.state='extract'; R.face=Math.atan2(p.y-R.y,p.x-R.x);
         updateEnts(0.016);
         if(bubs.some(near)) bad.push('a pillager breaking off to extract drew a mark over his head');
         if(R.state==='chase') bad.push('a pillager breaking off went back to the chase');
       }
       if(g.tel&&g.tel.taunts) bad.push('the raid still counts taunts ('+g.tel.taunts+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(own){ blip=oBlip; sfx=oSfx; emoteBubble=oEB; } try{ var g2=__state(); if(g2){ if(E0) g2.ents=E0; if(R&&kr){ R.x=kr.x; R.y=kr.y; R.face=kr.face; R.state=kr.state; R.alert=kr.alert; R.tx=kr.tx; R.ty=kr.ty; } if(!g2.over){ g2.bullets.length=0; g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); }
     if(bad.length) return bad.join('; ');
     return skip?'SKIP: '+skip:null; }},
  {v:'25.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
