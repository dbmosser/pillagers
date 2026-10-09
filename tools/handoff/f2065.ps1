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

if ($s.Contains("  {v:'20.65',what:")) { throw "check 20.65 is in the fixture already" }

SubRx @'
  {v:'20.64',what:
'@ @'
  {v:'20.65',what:'in co-op a hunting Listener hears the sprint of the player it hunts: player 2 sprinting is heard at the sprinting reach while the host walks, and player 2 walking is not heard there while the host sprints',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netTargetFor!=='function'||typeof mkListener!=='function'||typeof updateEnts!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], g=null, oNT=netTargetFor, oEnts=null, oSp=false, oLive=CFG.listenLive, Ls, B, gn, rS, rW, d, arm, h1, h2;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       oSp=g.sprinting; oEnts=g.ents;
       CFG.listenLive=1;
       gn=(CFG.listenGain===undefined?1.35:CFG.listenGain)/1.35;
       rS=((CFG.listenFair!==0)?300:430)*gn; rW=((CFG.listenFair!==0)?210:290)*gn; d=(rS+rW)/2;
       B={net:1,seat:1,x:g.player.x+0.375,y:g.player.y+0.625,r:11,face:0,downed:false,moving:true,cr:0,sp:0,hp:100,maxhp:100,iv:0,roll:0,ads:false,wep:null,pendKiller:null,rig:'none'};
       Ls=mkListener(B.x+d,B.y);
       g.ents=[Ls];
       NET.on=true; NET.upSeed=g.seed>>>0;
       netTargetFor=function(e){ return e===Ls?B:g.player; };
       arm=function(sp,hostSp){
         Ls.x=B.x+d; Ls.y=B.y; Ls.state='hunt'; Ls.wakeT=0; Ls.cd=5; Ls.windup=null; Ls.millT=0; Ls.hp=Ls.maxhp; Ls.roll=0; Ls.downed=0;
         Ls.heardX=B.x+d+0.5; Ls.heardY=B.y+0.5;
         B.sp=sp; B.moving=true; B.downed=false; B.cr=0; g.sprinting=hostSp;
         updateEnts(0.016);
         return Ls.heardX===B.x&&Ls.heardY===B.y;
       };
       h1=arm(1,false);
       h2=arm(0,true);
       if(!h1) bad.push('player 2 sprinting '+Math.round(d)+' away was not heard while the host walked (the sprinting reach is '+Math.round(rS)+')');
       if(h2) bad.push('player 2 walking '+Math.round(d)+' away was heard because the host sprinted (the walking reach is '+Math.round(rW)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netTargetFor=oNT;
       if(oLive===undefined) delete CFG.listenLive; else CFG.listenLive=oLive;
       try{ if(g){ if(oEnts) g.ents=oEnts; g.sprinting=oSp; } }catch(_r){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
