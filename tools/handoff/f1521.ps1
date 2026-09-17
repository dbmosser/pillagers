$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.20',what:
'@ @'
  {v:'15.21',what:'a self-revive clears your hire pickup: you go down beside him, get up on F part way through his pickup and go down again, and he calls out to you again and starts a fresh 3.2 second pickup rather than finishing the old one (hire audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__ents)) return 'SKIP: this fixture cannot deploy or step the pillagers';
     if(typeof mkRaider!=='function'||typeof damagePlayer!=='function'||typeof selfRevive!=='function'||typeof losClear!=='function'||typeof dist!=='function') return 'SKIP: no pillagers, downs or self-revive in this build';
     var bad=[], snap=null, g=null, kept=null, _say=say, said=[];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var COMING=' is coming '+'for you', PULLS=' pulls you '+'up';
     var heard=function(k){ for(var j=0;j<said.length;j++) if(said[j].indexOf(k)>=0) return true; return false; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       if(CFG.raiderDown===0) return 'SKIP: pillager downs are switched off here, so your hire does not pick you up';
       if(!g.zones||!g.zones.length||!g.map||!g.map.segs) return 'SKIP: no open ground to stage on';
       var p=g.player, Z=null, zi;
       for(zi=0;zi<g.zones.length&&!Z;zi++) if(losClear(g.zones[zi].x-60,g.zones[zi].y,g.zones[zi].x+60,g.zones[zi].y,g.map.segs)) Z=g.zones[zi];
       if(!Z) return 'SKIP: no clear spot beside a ring';
       kept={ents:g.ents,cont:g.containers,order:g.mercOrder,hold:g.mercHold};
       // One stage: nobody else on the map and no crates, you 30 left of your hire on FOLLOW, so no walk and no fight is involved.
       var M=mkRaider(Z.x+15,Z.y,null,false); M.merc=1; M.hostile=false; M.grudge=false;
       M.hp=1000; M.maxhp=1000; M.state='follow'; M.downed=false; M.finished=false; M.cd=0; M.roll=0; M.bag=[]; M.mgoal=null; M.mlootT=0;
       g.ents=[M]; g.containers=[]; g.mercOrder='follow'; g.mercHold=null;
       p.x=Z.x-15; p.y=Z.y; p.downed=false; p.dying=false; p.revived=false; p.hp=p.maxhp; p.armor=0; p.iv=0; p.roll=0;
       var step=function(k){ for(var f=0;f<k;f++) __ents(0.05); };
       say=function(m){ said.push(String(m)); };
       // ONE: you go down beside your hire and he works on you for 2.5 of his 3.2 seconds.
       damagePlayer(999,'sentry','PROBE UNIT NINE',p.x-2,p.y);
       step(50);
       // CONTROL: you are down beside a named hire who stayed on the stage, said he was coming, and whose clock ran without finishing.
       if(!p.downed||!M.name) return 'SKIP: you did not go down beside a named hire here';
       if(g.ents.indexOf(M)<0||M.downed) return 'SKIP: the hire did not stay on the stage here';
       if(!heard(COMING)||!((M.revProgP||0)>=2.4)) return 'SKIP: your hire did not start his pickup beside you here (clock '+M.revProgP+', lines '+said.length+')';
       // TWO: you press F part way through his pickup and stand for two frames.
       if(!selfRevive()||p.downed||!p.revived) return 'SKIP: the self-revive did not stand you up here';
       step(2);
       // CONTROL: nothing put you down again while you stood, and he is still close enough to work on you without a walk.
       if(p.downed) return 'SKIP: something put you down again while you stood here';
       if(g.ents.indexOf(M)<0||M.downed||dist(M,p)>44) return 'SKIP: your hire did not stay beside you while you stood here';
       // THREE: you go down again. The self-revive is spent, so he is the only way up.
       said.length=0; p.iv=0;
       damagePlayer(999,'sentry','PROBE UNIT NINE',p.x-2,p.y);
       // CONTROL: the second down took.
       if(!p.downed) return skip('the second down did not take here');
       step(1);
       if(!heard(COMING)) bad.push('on your second down your hire never called out to you');
       if((M.revProgP||0)>0.06) bad.push('one frame into your second down his pickup clock already read '+(Math.round(M.revProgP*100)/100)+' of 3.2 seconds, carried over from the pickup your self-revive cut short');
       step(19);
       if(!p.downed||heard(PULLS)) bad.push('your hire pulled you up within one second of your second down, where a pickup takes 3.2 seconds');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say;
       try{ if(g&&kept){ g.ents=kept.ents; g.containers=kept.cont; g.mercOrder=kept.order; g.mercHold=kept.hold; } }catch(_k){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
