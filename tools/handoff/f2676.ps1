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

if ($s.Contains("  {v:'26.76',what:")) { throw "check 26.76 is in the fixture already" }

SubRx @'
  {v:'26.75',what:
'@ @'
  {v:'26.76',what:'his yes (suggestion 26): a searcher that loses the player sweeps three widening rings before it gives up, and shows a scan cone that widens, shortens to the crouch-hide distance when the player crouches, is only drawn while searching, and rides the network flags',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof mkRaider!=='function'||typeof render2D!=='function'||typeof spotFree!=='function'||typeof freeSpot!=='function') return 'SKIP: no raid here';
     var tr=[], bad=[], g=null, p=null, all=null, R=null, B=null, T=null, i, k, q, aa, lv=0, maxRad=0, rad, cc, cl, c0, f, cp, hF, oF, cnt, OWN=Object.prototype.hasOwnProperty, crouch0, x, y;
     function inW(x,y){ return x>60&&y>60&&x<WORLD_W-60&&y<WORLD_H-60; }
     try{
       if(typeof searchCone!=='function'||typeof searchAdvance!=='function') return 'a searcher shows no scan cone';
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false; all=g.ents.slice(); crouch0=G.pCrouch; G.pCrouch=false;
       for(k in keys) keys[k]=false;
       for(i=0;i<120&&!B;i++){
         q=freeSpot(g.map,40); if(Math.hypot(q.x-p.x,q.y-p.y)<800) continue;
         for(k=0;k<16&&!B;k++){ aa=k/16*6.2832; x=q.x+Math.cos(aa)*70; y=q.y+Math.sin(aa)*70; if(inW(x,y)&&spotFree(g.map,x,y,22)&&losClear(q.x,q.y,x,y,G.vseg)){ B=q; T={x:x,y:y}; } }
       }
       if(!B) return 'SKIP: no open ground far from the player';
       R=mkRaider(B.x,B.y,undefined,true); R.elite=0; R.hostile=true; R.hp=R.maxhp; R.bag=[]; R.cd=9; R.state='chase'; R.alert=2.4; R.tx=T.x; R.ty=T.y; R.face=Math.atan2(T.y-B.y,T.x-B.x); R.searchLvl=0;
       g.ents=[R];
       for(i=0;i<1500&&R.state==='chase';i++){
         __sim(1/60);
         if((R.searchLvl|0)>lv) lv=R.searchLvl|0;
         if(R.searchX!==undefined){ rad=Math.hypot(R.searchX-T.x,R.searchY-T.y); if(rad>maxRad) maxRad=rad; }
         if(i%20===0) tr.push((R.searchLvl|0)+':'+(Math.round(R.alert*10)/10)+':'+(R.searchX===undefined?'-':Math.round(dist(R,{x:R.searchX,y:R.searchY})))+':'+(R.searchX===undefined?'-':Math.round(Math.hypot(R.searchX-T.x,R.searchY-T.y))));
       }
       if(lv<2) bad.push('ai26 lvl:alert:distToPoint:radius '+tr.join(' ')+' searched only '+(lv+1)+' ring(s), not three');
       if(maxRad<160) bad.push('the search never went wider than '+Math.round(maxRad)+' units from the last known point');
       if(R.state==='chase') bad.push('the search never ended');
       // the scan cone
       R.state='chase'; R.searchX=R.x+10; R.searchY=R.y; R.sirenSeeT=-99; R.rng=259; R.hp=R.maxhp; R.downed=0;
       R.searchLvl=0; cl=searchCone(R); if(!cl||cl.reach>171||cl.half>0.6) bad.push('the first ring cone is '+(cl?(Math.round(cl.reach)+' long, '+cl.half.toFixed(2)+' wide'):'missing'));
       R.searchLvl=2; cc=searchCone(R); if(!cc||!(cc.reach>300)||!(cc.half>0.9)) bad.push('the third ring cone is '+(cc?(Math.round(cc.reach)+' long, '+cc.half.toFixed(2)+' wide'):'missing')+', not 340 long and 0.95 wide');
       G.pCrouch=true; cl=searchCone(R); G.pCrouch=false;
       if(!cl||!(cl.reach<=170.5)) bad.push('with the player crouched the cone still reaches '+(cl?Math.round(cl.reach):'nowhere')+', past the crouch-hide distance');
       R.state='loot'; if(searchCone(R)) bad.push('a pillager who is not hunting shows a search cone');
       R.state='chase'; R.sirenSeeT=(G.t||0); if(searchCone(R)) bad.push('a pillager who can see the player shows a search cone');
       R.sirenSeeT=-99;
       f=netEntFlags(R); if(!(f&-2147483648)) bad.push('the party is not told a body is searching');
       cp={kind:'raider',net:1,x:R.x,y:R.y,face:0,hp:50,maxhp:50,rng:259,state:'chase'}; netEntFlagsApply(cp,f);
       if(cp.srch!==1||!searchCone(cp)) bad.push('a linked window does not draw the search it is told of');
       R.state='loot'; f=netEntFlags(R); if(f&-2147483648) bad.push('a pillager who is not searching sends the searching flag');
       // drawn in the world
       for(k=0;k<24;k++){ aa=k/24*6.2832; x=p.x+Math.cos(aa)*90; y=p.y+Math.sin(aa)*90; if(inW(x,y)&&spotFree(g.map,x,y,22)&&losClear(p.x,p.y,x,y,G.vseg)) break; }
       if(k<24){
         p.face=Math.atan2(y-p.y,x-p.x); R.x=x; R.y=y; R.face=aa; R.searchLvl=1; R.searchX=x+10; R.searchY=y; R.state='chase'; R.sirenSeeT=-99; g.ents=[R];
         hF=OWN.call(wc,'fill'); oF=wc.fill; cnt=0;
         wc.fill=function(){ if(/255,\s*196,\s*72/.test(String(this.fillStyle))) cnt++; return oF.apply(this,arguments); };
         try{ render2D(0.016); } finally { if(hF) wc.fill=oF; else delete wc.fill; }
         if(!cnt) bad.push('a searching pillager in view draws no scan cone');
         R.state='loot'; cnt=0;
         wc.fill=function(){ if(/255,\s*196,\s*72/.test(String(this.fillStyle))) cnt++; return oF.apply(this,arguments); };
         try{ render2D(0.016); } finally { if(hF) wc.fill=oF; else delete wc.fill; }
         if(cnt) bad.push('a pillager who is not searching draws a scan cone');
       }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       try{ if(typeof oF==='function'&&hF!==undefined){ if(hF) wc.fill=oF; else delete wc.fill; } }catch(_e0){}
       try{ G.pCrouch=crouch0; }catch(_e1){}
       try{ if(g&&all){ g.ents=all; g.bullets.length=0; } var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
