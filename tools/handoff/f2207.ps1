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

if ($s.Contains("  {v:'22.07',what:")) { throw "check 22.07 is in the fixture already" }

SubRx @'
  {v:'22.06',what:
'@ @'
  {v:'22.07',what:'in co-op a round from player 2 turns the Survivor on the host and he fires back at player 2, and a Survivor or Peddler player 2 kills costs player 2 a notoriety point',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netShotTake!=='function'||typeof netKillTake!=='function'||typeof netEntsInit!=='function'||typeof updateEnts!=='function') return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], oSay=say, oSwf=sayWhenFree, oTF=netTargetFor, oPL=netPlayersList, oFW=fireWeapon, S=null, D=null, i, r, n0, no0=P.notoriety, E0=null, shots=[], H, Bd, s1, s2;
     var p0={seat:0,state:'in'}, p1={seat:1,state:'in'};
     function spot(e,d,not){ var j, a, x, y; for(j=0;j<16;j++){ if(j===not) continue; a=j*Math.PI/8; x=e.x+Math.cos(a)*d; y=e.y+Math.sin(a)*d; if(losClear(x,y,e.x,e.y,G.vseg)) return {x:x,y:y,j:j}; } return null; }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       say=function(){}; sayWhenFree=function(){};
       for(i=0;i<G.ents.length;i++){ if(G.ents[i].kind==='stray'&&!S) S=G.ents[i]; if(G.ents[i].kind==='peddler'&&!D) D=G.ents[i]; }
       if(!S){ S={kind:'stray',x:G.player.x+300,y:G.player.y,r:11,hp:70,maxhp:70,face:0,coat:'#7a8a6a',name:'SURVIVOR',neutral:1,bag:[],stock:[],want:'medkit',helped:0,found:0,askedT:0,state:'idle',tx:G.player.x+300,ty:G.player.y,cd:0,alert:0,spd:0,dmg:0,rng:0,cone:0,hitT:0,step:0,goal:null,skips:[],goalT:0,goalD:0,extracting:0}; G.ents.push(S); }
       S.hostile=false; S.helped=1; S.hp=70; S.gone=0; S.downed=false;
       NET.on=true; NET.max=4; NET.upSeed=G.seed>>>0; NET.specG=null; NET.up=[]; netEntsInit(G);
       NET.role='host'; NET.seat=0; NET.peers=[p1];
       r=netShotTake(p1,{t:'shot',id:S.nid,dmg:3,x:Math.round(S.x-200),y:Math.round(S.y),a:0});
       if(r!=='shot') return 'SKIP: staging: the host took no round ('+r+')';
       if(!S.hostile) bad.push('a round from player 2 never turned the Survivor on the host, so he never fires back');
       if(S.helped) bad.push('the Survivor player 2 shot still walks to the ring as a helped man');
       s1=spot(S,60,-1); s2=s1?spot(S,150,s1.j):null;
       if(s1&&s2){
         H={x:s1.x,y:s1.y,r:11,face:0,downed:false,hp:100,maxhp:100};
         Bd={net:1,seat:1,x:s2.x,y:s2.y,r:11,face:0,downed:false,moving:false,cr:0,sp:0,hp:100,maxhp:100,iv:0,roll:0,ads:false,wep:null,pendKiller:null,rig:'none'};
         netTargetFor=function(){ return H; }; netPlayersList=function(){ return [H,Bd]; };
         fireWeapon=function(e,w,x,y){ if(e===S) shots.push({x:x,y:y}); };
         S.cd=0; S.downed=false; E0=G.ents; G.ents=[S];
         try{ updateEnts(0.016); } finally{ G.ents=E0; }
         netTargetFor=oTF; netPlayersList=oPL; fireWeapon=oFW;
         if(!shots.length) bad.push('the Survivor player 2 shot never fired back');
         else if(Math.abs(shots[0].x-Bd.x)>1||Math.abs(shots[0].y-Bd.y)>1) bad.push('the Survivor player 2 shot fired at the host standing nearer, not at player 2');
       }
       NET.role='join'; NET.seat=1; NET.peers=[p0];
       if(!netEntsPeer()) return 'SKIP: staging: this window is not linked';
       P.notoriety=0;
       r=netKillTake(p0,{t:'kill',seat:1,id:S.nid,k:'stray',el:0});
       if((P.notoriety|0)!==1) bad.push('player 2 killed the Survivor and his notoriety stayed at '+(P.notoriety|0)+' ('+r+')');
       if(D){ n0=P.notoriety|0; netKillTake(p0,{t:'kill',seat:1,id:D.nid,k:'peddler',el:0}); if((P.notoriety|0)!==n0+1) bad.push('player 2 killed the Peddler and paid no notoriety'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; sayWhenFree=oSwf; netTargetFor=oTF; netPlayersList=oPL; fireWeapon=oFW;
       try{ if(E0) G.ents=E0; }catch(_r){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ P.notoriety=no0; saveProfile(); }catch(_n){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
