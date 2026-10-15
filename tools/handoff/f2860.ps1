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

if ($s.Contains("  {v:'28.60',what:")) { throw "check 28.60 is in the fixture already" }

SubRx @'
  {v:'28.59',what:
'@ @'
  {v:'28.60',what:'cloud-raid-p2boss: player 2 copy of THE OVERSEER is the boss: his front round into it is not soaked as a plain Warden front and is not called WARDEN ARMOUR, and he sees its sweeping laser',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof bossTick!=='function'||typeof netEntNewWord!=='function'||typeof netEntWord!=='function'||typeof netEntsApply!=='function'||typeof updateBullets!=='function'||typeof netShotSend!=='function') return 'SKIP: no boss or party in this fixture';
     var g=null, p=null, e=null, mm=null, NK={}, k, staged=false, oKeys=null, peer={state:'in',seat:0}, nw, row, bad=[];
     function link(L){ var w=L.map(netEntNewWord), r=L.map(netEntRow); g.ents=[]; for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[peer]; NET.up=[]; NET.entMap={}; NET.entLast=0;
       w.forEach(function(x){ netEntWord(peer,x); }); netEntsApply(peer,{t:'ents',sd:g.seed>>>0,e:r,n:5}); }
     var oS=netShotSend, oSay=say, sent=[], says=[], dy=0, cand=[80,-80,60,-60], j, front, h0, host;
     function shoot(en){ g.bullets.length=0; g.bullets.push({x:en.x+25,y:en.y+dy,vx:0,vy:(dy>0?-1180:1180),dmg:100,life:0.3,player:true,owner:p,tint:'#ffffff',el:'',thru:0}); for(var q=0;q<8;q++) updateBullets(1/60); }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       p=g.player; p.iv=99; keys={};
       g.t=5; g.bossDone=0; e=bossTick(true); if(!e) return 'SKIP: staging: no Overseer could be raised';
       g.ents=[e]; e.nid=777;
       for(j=0;j<cand.length&&!dy;j++) if(rayHitG(e.x,e.y+cand[j],0,-cand[j]/Math.abs(cand[j]),Math.abs(cand[j]))>=Math.abs(cand[j])-0.5) dy=cand[j];
       if(!dy) return 'SKIP: staging: no clear line in front of the Overseer';
       front=(dy>0)?1.5708:-1.5708;
       e.face=front; e.overheat=0; h0=e.hp; shoot(e); host=h0-e.hp; e.hp=e.maxhp;
       if(!(host>0)) return 'SKIP: staging: the host round did not land';
       link([e]); mm=NET.entMap[777]; if(!mm) return 'SKIP: staging: the linked window made no copy';
       if(!mm.boss) bad.push('player 2 copy of THE OVERSEER is not the boss');
       netShotSend=function(en,d){ sent.push(Math.round(d)); return true; }; say=function(t){ says.push(String(t)); };
       try{ mm.face=front; mm.overheat=0; mm.x=e.x; mm.y=e.y; shoot(mm); } finally{ netShotSend=oS; say=oSay; }
       if(!sent.length) return bad.length?bad.join('; '):'SKIP: staging: player 2 round did not land on the copy';
       if(Math.abs(sent[0]-host)>1) bad.push('the same front round does '+host+' on the host and player 2 sends '+sent[0]);
       if(says.indexOf('WARDEN ARMOUR')>=0) bad.push('player 2 is told WARDEN ARMOUR on the Overseer');
       return bad.length?bad.join('; '):null;
     }catch(x){ return 'threw: '+(x&&x.stack||x); }
     finally{ if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; } try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} }
   }},
  {v:'28.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
