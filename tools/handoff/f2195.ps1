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

if ($s.Contains("  {v:'21.95',what:")) { throw "check 21.95 is in the fixture already" }

SubRx @'
  {v:'21.94',what:
'@ @'
  {v:'21.95',what:'an armoury gun dropped for a teammate is in one save only when a window is gone: the host drop comes off his saved list while a teammate is up top, a gun he takes back goes on it again, and a word for a teammate whose window closed waits for his next link and acts only on that raid',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof dropItem!=='function'||typeof netGunTold!=='function'||typeof netGunGoneTake!=='function'||typeof netPileTake!=='function'||typeof grantLoot!=='function'||typeof netOnMsg0!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSend=netSend, oShown=netUpShown, oGone=netUpGone, sent=[], gk=null, key=null, i, ks=Object.keys(ITEMS), g, g0, c, pc, r, lp, w0, rs0, gp0, e0, s0;
     for(i=0;i<ks.length;i++) if(/^gun_/.test(ks[i])&&ITEMS[ks[i]]&&ITEMS[ks[i]].use==='gun'&&ITEMS[ks[i]].gk&&WEAPONS[ITEMS[ks[i]].gk]){ key=ks[i]; gk=ITEMS[key].gk; break; }
     if(!key) return 'SKIP: no armoury gun item here';
     for(k in NET) NK[k]=NET[k];
     w0=(P.weapons||[]).slice(); rs0=P.raidSpliced; gp0=P.gunPiled; e0=P.equipped; s0=P.equippedSec;
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       P.weapons=P.weapons.filter(function(x){ return x!==gk; });
       g.spliced=[gk]; P.raidSpliced=[gk];
       g.bag.push(key); dropItem(g.bag.length-1);
       if((P.raidSpliced||[]).indexOf(gk)<0) bad.push('solo: a dropped armoury gun came off the saved list');
       netSend=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netUpShown=function(u){ return !!u&&u.seat===1; }; netUpGone=function(){ return false; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.upSeed=g.seed>>>0; NET.peers=[{seat:1,state:'in',pid:'zq7mate'}]; NET.up=[null,{seat:1}]; NET.gunOwed=[];
       g.spliced=[gk]; P.raidSpliced=[gk];
       g.bag.push(key); dropItem(g.bag.length-1);
       c=g.containers[g.containers.length-1];
       if(!c||!c.dropped||!c.loot||c.loot[0]!==key) return 'SKIP: staging: the host drop made no pile';
       if((P.raidSpliced||[]).indexOf(gk)>=0) bad.push('the host dropped his armoury gun with a teammate up top and it stayed on his saved list, so a closed window puts it back while the teammate banks it');
       if(g.spliced.indexOf(gk)<0) bad.push('the host drop took the gun off this raid list, so an abandon would not bring it home');
       c.loot=[]; grantLoot(c,[key]);
       if((P.raidSpliced||[]).indexOf(gk)<0) bad.push('a gun the host took back out of his own pile is not on his saved list again');
       r=netPileTake({seat:2,state:'in',pid:'zq7gone'},{t:'pile',k:key,x:Math.round(g.player.x),y:Math.round(g.player.y)});
       pc=g.containers[g.containers.length-1];
       if(r!=='pile'||!pc||pc.dropBy!==2) return 'SKIP: staging: the host made no pile for seat 2 ('+r+')';
       sent=[];
       netGunTold(pc,[key],0);
       if(sent.length) bad.push('a word went out with no window on that seat');
       if(typeof netGunOwedTell!=='function') bad.push('the word for a teammate whose window closed is thrown away');
       else {
         netGunOwedTell({seat:1,state:'in',pid:'zq7other'});
         if(sent.length) bad.push('the waiting word went to someone else');
         netGunOwedTell({seat:3,state:'in',pid:'zq7gone'});
         lp=sent.filter(function(m){ return m.t==='gungone'&&m.k===gk&&m.late===1&&(m.sd>>>0)===(g.seed>>>0); });
         if(lp.length!==1) bad.push('his next link got '+lp.length+' waiting words, not 1 ('+JSON.stringify(sent)+')');
         sent=[]; netGunOwedTell({seat:3,state:'in',pid:'zq7gone'});
         if(sent.length) bad.push('the waiting word went twice');
       }
       if(String(netOnMsg0).indexOf('netGunOwed'+'Tell(peer)')<0) bad.push('a teammate who links again is never told');
       NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}];
       P.weapons=P.weapons.filter(function(x){ return x!==gk; }).concat([gk]); P.gunPiled=[{gk:gk,sd:777001,home:1}];
       g0=G; G=null;
       try{
         netGunGoneTake({seat:0,state:'in'},{t:'gungone',k:gk,late:1,sd:777002});
         if(P.weapons.indexOf(gk)<0) bad.push('a waiting word about another raid took the gun out of his armoury');
         netGunGoneTake({seat:0,state:'in'},{t:'gungone',k:gk,late:1,sd:777001});
         if(P.weapons.indexOf(gk)>=0) bad.push('the waiting word about the raid he dropped it in left the gun in his armoury as well (two saves)');
         if(P.gunPiled.length) bad.push('the record of the piled gun stayed after the word');
       }finally{ G=g0; }
       g.spliced=[gk]; P.raidSpliced=[gk]; P.gunPiled=[{gk:gk,sd:777001,home:0}];
       netGunGoneTake({seat:0,state:'in'},{t:'gungone',k:gk,late:1,sd:777001});
       if(g.spliced.indexOf(gk)<0||(P.raidSpliced||[]).indexOf(gk)<0) bad.push('a waiting word took the gun off the lists of the raid he is in now');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netUpShown=oShown; netUpGone=oGone;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.spliced=[]; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P.weapons=w0; if(rs0===undefined) delete P.raidSpliced; else P.raidSpliced=rs0; if(gp0===undefined) delete P.gunPiled; else P.gunPiled=gp0; P.equipped=e0; P.equippedSec=s0;
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
