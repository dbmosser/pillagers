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

if ($s.Contains("  {v:'22.20',what:")) { throw "check 22.20 is in the fixture already" }

SubRx @'
  {v:'22.19',what:
'@ @'
  {v:'22.20',what:'in co-op the Pillbox, Peddler and Survivor lines go to the player who walked up: when it is player 2 the host window is not told and player 2 window is',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof updateEnts!=='function'||typeof netTargetFor!=='function'||typeof netOnMsg!=='function'||typeof netEntsInit!=='function') return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], oSay=say, oSwf=sayWhenFree, oTF=netTargetFor, oSend=netSend, oBlip=blip, said=[], sent=[], E0=null, i, C=null, D=null, S=null, B=null;
     var p0={seat:0,state:'in'}, p1={seat:1,state:'in'};
     function spot(e,d){ var j, a, x, y; for(j=0;j<16;j++){ a=j*Math.PI/8; x=e.x+Math.cos(a)*d; y=e.y+Math.sin(a)*d; if(losClear(x,y,e.x,e.y,G.vseg)) return {x:x,y:y}; } return null; }
     function walk(e,d){ var s=spot(e,d); if(!s) return false; B.x=s.x; B.y=s.y; B.face=Math.atan2(e.y-s.y,e.x-s.x); said=[]; sent=[]; G.ents=[e]; try{ updateEnts(0.016); } finally{ G.ents=E0; } return true; }
     function told(t){ var j, rx=new RegExp(t,'i'); for(j=0;j<said.length;j++) if(rx.test(String(said[j]))) return true; return false; }
     function hand(){ var j, w; NET.role='join'; NET.seat=1; NET.peers=[p0]; said=[]; try{ for(j=0;j<sent.length;j++){ w=sent[j]; if(w.q!==p1||!w.m||w.m.t==='hit'||w.m.t==='en'||w.m.t==='ent') continue; netOnMsg(p0,JSON.stringify(w.m)); } } finally{ NET.role='host'; NET.seat=0; NET.peers=[p1]; } }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       for(i=0;i<G.ents.length;i++){ var e=G.ents[i]; if(e.kind==='choir'&&!C) C=e; if(e.kind==='peddler'&&!D) D=e; if(e.kind==='stray'&&!S) S=e; }
       if(!C||!D) return 'SKIP: staging: no Pillbox or no Peddler in this raid';
       say=function(t){ said.push(t); }; sayWhenFree=say; blip=function(){};
       netSend=function(q,m){ sent.push({q:q,m:JSON.parse(JSON.stringify(m))}); return true; };
       NET.on=true; NET.max=4; NET.upSeed=G.seed>>>0; NET.specG=null; NET.up=[]; netEntsInit(G);
       NET.role='host'; NET.seat=0; NET.peers=[p1];
       B={net:1,seat:1,x:0,y:0,r:11,face:0,downed:false,moving:false,cr:0,sp:0,hp:100,maxhp:100,iv:0,roll:0,ads:false,wep:null,pendKiller:null,rig:'none'};
       netTargetFor=function(){ return B; };
       E0=G.ents;
       C.sang=0;
       if(!walk(C,200)) return 'SKIP: staging: no clear ground beside the Pillbox';
       if(told('pillbox has seen you')) bad.push('the host window was told THE PILLBOX HAS SEEN YOU when player 2 walked into its reach');
       hand();
       if(!told('pillbox has seen you')) bad.push('player 2 walked into the Pillbox reach and his window said nothing');
       D.hailed=0; D.fleeT=0; D._back=0; D._lastHp=D.hp;
       if(!walk(D,90)) return 'SKIP: staging: no clear ground beside the Peddler';
       if(told('the peddler (waves|turns)')) bad.push('the host window was hailed by the Peddler when player 2 walked up');
       hand();
       if(!told('the peddler (waves|turns)')) bad.push('player 2 walked up to the Peddler and was not hailed');
       if(S&&!S.gone){
         S.found=0; S.helped=0; S.hostile=false; S.downed=false;
         if(walk(S,80)){
           if(told('someone is hiding|survivor found')) bad.push('the host window was told SURVIVOR FOUND when player 2 found the Survivor');
           hand();
           if(!told('someone is hiding|survivor found')) bad.push('player 2 found the Survivor and his window said nothing');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; sayWhenFree=oSwf; netTargetFor=oTF; netSend=oSend; blip=oBlip;
       try{ if(E0) G.ents=E0; }catch(_r){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
