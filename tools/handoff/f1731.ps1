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

if ($s.Contains("  {v:'17.31',what:")) { throw "check 17.31 is in the fixture already" }

SubRx @'
  {v:'17.30',what:
'@ @'
  {v:'17.31',what:'a round from player 2 into a pillager who made peace turns him on the host but charges player 2: the host save keeps its standing and the host window says nothing, the player 2 window takes the standing and the line; a host round still charges the host, but not once he is out of the raid and only watching',
   run:function(){
     if(typeof netShotTake!=='function'||typeof updateEnts!=='function'||typeof mkRaider!=='function'||typeof canSee!=='function'||typeof idRec!=='function'||typeof netOnMsg!=='function'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no party round on a pillager';
     var keep={}, k, oSend=netSend, oRef=netRefresh, oSay=say, oSWF=sayWhenFree, oSave=saveProfile, oCS=canSee,
         bad=[], g=null, p=null, R=null, r, said=[], sent=[], ID='zqx_parley_shot_rival', NID=987321, hp={state:'in',seat:1}, hq={state:'in',seat:0},
         hadR=!!(P.rivals&&Object.prototype.hasOwnProperty.call(P.rivals,ID)), r0=hadR?P.rivals[ID]:null;
     function lay(){
       R=mkRaider(p.x+260,p.y,null,false);
       R.hostile=false; R.friendlyPC=1; R.merc=0; R.grudge=false; R.downed=0; R.finished=0; R.roll=0; R.rollCd=5; R.fleeT=0;
       R.ident=ID; R.name='ZQX PARLEY'; R.nid=NID; R.hp=Math.max(50,R.hp||0); R.face=Math.PI;
       g.ents.length=0; g.ents.push(R); g.bullets.length=0;
       NET.entMap={}; NET.entMap[NID]=R; NET.entDead={};
       if(P.rivals) delete P.rivals[ID];
       said.length=0; sent.length=0;
     }
     function line(){ return said.some(function(t){ return String(t).indexOf(' trusted '+'you')>=0; }); }
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=G; p=g&&g.player;
       if(!g||!p||!g.ents||!g.bullets) return 'SKIP: staging: no live raid';
       say=function(t){ said.push(t); }; sayWhenFree=function(t){ said.push(t); }; saveProfile=function(){}; netRefresh=function(){};
       netSend=function(q,m){ sent.push(m); return true; }; canSee=function(){ return true; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[hp]; NET.up=[]; NET.specG=null;
       lay();
       R.hp-=1; R.hitT=.16; R.pHitT=.3; R.pHitSeat=0; R.alert=2.6; R.state='chase'; R.tx=p.x; R.ty=p.y;
       updateEnts(0.02);
       if(R.friendlyPC||!R.hostile||!(P.rivals&&P.rivals[ID]&&(P.rivals[ID].standing||0)<=-1)||!line()) return 'SKIP: staging: a round of the host player into a man who made peace did not turn him and charge the host save';
       lay(); p.specOut=1;
       R.hp-=1; R.hitT=.16; R.pHitT=.3; R.pHitSeat=0; R.alert=2.6; R.state='chase'; R.tx=p.x; R.ty=p.y;
       updateEnts(0.02);
       delete p.specOut;
       if(P.rivals&&P.rivals[ID]&&(P.rivals[ID].standing||0)<0) bad.push('the host player save lost standing ('+P.rivals[ID].standing+') while he was out of the raid and only watching');
       if(line()) bad.push('the host window said the betrayal line while the host player was out of the raid');
       lay();
       r=netShotTake(hp,{t:'shot',id:NID,dmg:1,x:p.x,y:p.y});
       if(r!=='shot') return 'SKIP: staging: the host did not take the round of player 2 ('+r+')';
       updateEnts(0.02);
       if(R.friendlyPC||!R.hostile) bad.push('the round of player 2 no longer turns the man who made peace on the host');
       if(P.rivals&&P.rivals[ID]&&(P.rivals[ID].standing||0)<0) bad.push('the host player save lost standing ('+P.rivals[ID].standing+') for a round player 2 fired');
       if(line()) bad.push('the host window said the betrayal line for a round player 2 fired');
       if(!sent.some(function(m){ return m&&m.t==='betray'&&(m.id|0)===NID; })) bad.push('player 2 was not told the man he shot had trusted him');
       if(P.rivals) delete P.rivals[ID];
       said.length=0;
       NET.role='join'; NET.seat=1; NET.peers=[hq];
       r=netOnMsg(hq,JSON.stringify({t:'betray',seat:1,id:NID}));
       if(!(P.rivals&&P.rivals[ID]&&(P.rivals[ID].standing||0)<=-1)) bad.push('the player 2 window took no standing for the man he turned ('+r+')');
       if(!line()) bad.push('the player 2 window did not say the betrayal line ('+r+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netRefresh=oRef; say=oSay; sayWhenFree=oSWF; saveProfile=oSave; canSee=oCS;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ if(p) delete p.specOut; }catch(e4){}
       try{ if(P.rivals){ if(hadR) P.rivals[ID]=r0; else delete P.rivals[ID]; } }catch(e2){}
       try{ if(g){ g.ents.length=0; g.bullets.length=0; } __endRaid('abandon'); __topClear(); }catch(e3){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
