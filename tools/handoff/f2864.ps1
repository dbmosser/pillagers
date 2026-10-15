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

if ($s.Contains("  {v:'28.64',what:")) { throw "check 28.64 is in the fixture already" }

SubRx @'
  {v:'28.63',what:
'@ @'
  {v:'28.64',what:'cloud-raid-takeover: when player 2 picks up the raid after the host drops, an open stronghold whose garrison he only mirrored is not paid as cleared and the mirrored golden enemy drops no free hoard',
   run:function(){
     if(!(window.__state&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof netHostGone!=='function'||typeof flowNetOut!=='function'||typeof flowNetTake!=='function'||typeof shOpen!=='function'||typeof netEntsInit!=='function') return 'SKIP: no arcade, party or strongholds in this fixture';
     var gr=null, g=null, p=null, rs=say, own=false, NK={}, k, staged=false, oS=netSend, oSF=netSendFast, lines=[], hp={seat:1,state:'in'}, h={seat:0,state:'in'}, s, host=[], i, j, e, m, fl, hoards, bad=[], oMine;
     try{
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4240})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; say=function(t,kd,o){ lines.push(String(t)); }; own=true; oMine=ARCADE.mine;
       for(k in NET) NK[k]=NET[k]; staged=true;
       netSend=function(){ return true; }; netSendFast=function(){ return true; };
       NET.on=true; NET.max=4; NET.upSeed=g.seed>>>0; NET.role='host'; NET.seat=0; NET.peers=[hp];
       g.t=5; flowTick(0.1); flowTick(0.1);
       s=g.flow.sh&&g.flow.sh.sites&&g.flow.sh.sites[0]; if(!s) return 'SKIP: staging: the raid laid out no stronghold';
       shOpen(s);
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(e.shi!==undefined&&e.hp>0) host.push(e); }
       if(!host.length) return 'SKIP: staging: the stronghold has no live garrison';
       netEntsInit(g);
       fl=JSON.parse(JSON.stringify(flowNetOut()));
       // player 2 window: the garrison it has are mirrors of the host bodies, and it keeps the host flow
       for(i=0;i<host.length;i++){ e=host[i]; j=g.ents.indexOf(e); if(j>=0) g.ents.splice(j,1); m=netEntMake(e.nid,e.kind,e.x,e.y); m.hp=e.hp; m.maxhp=e.maxhp; m.nIn=1; g.ents.push(m); NET.entMap[e.nid]=m; }
       delete g.flow.sh; delete g.flow.gold; delete g.flow.clue;
       NET.role='join'; NET.seat=1; NET.peers=[h]; ARCADE.mine=0;
       flowNetTake(fl);
       if(!(g.flow.sh&&g.flow.sh.sites&&g.flow.sh.sites.length)) return 'SKIP: staging: player 2 took no stronghold from the word';
       // the golden enemy is picked far from the player, so its mirror is often off the map (no row for 3 s): take it off as the window does
       var gr=g.flow.gold&&g.flow.gold.ref;
       if(gr&&gr.net){ j=g.ents.indexOf(gr); if(j>=0) g.ents.splice(j,1); gr.nIn=0; }
       lines.length=0;
       netHostGone('lost');
       for(i=0;i<3;i++) flowTick(0.1);
       hoards=g.containers.filter(function(c){ return c&&c.tag==='GOLDEN HOARD'; }).length;
       if(lines.indexOf('STRONGHOLD CLEARED')>=0||g.flow.sh.sites[0].clear) bad.push('the takeover paid STRONGHOLD CLEARED for a garrison nobody fought (score '+ARCADE.mine+')');
       if(lines.indexOf('GOLDEN ENEMY DOWN')>=0||hoards>0) bad.push('the takeover dropped '+hoards+' golden hoard for a golden enemy nobody killed');
       return bad.length?bad.join('; '):null;
     }catch(x){ return 'threw: '+(x&&x.stack||x); }
     finally{ if(own) say=rs; netSend=oS; netSendFast=oSF; if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; } if(oMine!==undefined) ARCADE.mine=oMine; try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} }
   }},
  {v:'28.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
