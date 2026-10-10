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

if ($s.Contains("  {v:'21.96',what:")) { throw "check 21.96 is in the fixture already" }

SubRx @'
  {v:'21.95',what:
'@ @'
  {v:'21.96',what:'a guest who abandons and joins the same raid again finds his dropped armoury gun only in the pile: the record of piled guns is kept for that raid, the gun comes out of his armoury and onto the raid list, and taking it back clears the record',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netLootTake!=='function'||typeof netContInit!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], gk=null, key=null, ok=null, i, ks=Object.keys(ITEMS), g, c, cid, r, w0, rs0, gp0, e0, s0, oSwf=sayWhenFree;
     function starter(x){ return typeof STARTERS!=='undefined'&&STARTERS.indexOf(x)>=0; }
     for(i=0;i<ks.length;i++){ var _it=ITEMS[ks[i]]; if(!/^gun_/.test(ks[i])||!_it||_it.use!=='gun'||!_it.gk||!WEAPONS[_it.gk]||starter(_it.gk)||_it.gk==='fists') continue; if(!key){ key=ks[i]; gk=_it.gk; } else if(_it.gk!==gk){ ok=_it.gk; break; } }
     if(!key||!ok) return 'SKIP: no two armoury gun items here';
     for(k in NET) NK[k]=NET[k];
     w0=(P.weapons||[]).slice(); rs0=P.raidSpliced; gp0=P.gunPiled; e0=P.equipped; s0=P.equippedSec;
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep();
       P.weapons=w0.filter(function(x){ return x!==gk&&x!==ok; }).concat([gk,ok]); P.equipped=gk; P.equippedSec='none';
       P.gunPiled=[{gk:gk,sd:4242,home:1},{gk:ok,sd:515151,home:1}];
       NET.upHold=true; NET.upIss=null;
       try{ __deploy({kit:[],safe:null,mapIx:0,seed:4242}); }finally{ NET.upHold=false; NET.upIss=null; }
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if((g.seed>>>0)!==4242) return 'SKIP: staging: the raid is not on seed 4242';
       if(P.weapons.indexOf(gk)>=0) bad.push('he joined the raid his gun lies in and it is in his armoury as well as in the pile');
       if(!g.spliced||g.spliced.indexOf(gk)<0) bad.push('the piled gun is not on this raid list, so a second abandon would not bring it home');
       if(g.player.wep&&g.player.wep.id===gk) bad.push('he came up holding the gun that lies in the pile');
       if(!Array.isArray(P.gunPiled)||P.gunPiled.length!==1||P.gunPiled[0].gk!==gk) bad.push('the record of the gun piled in this raid was wiped ('+JSON.stringify(P.gunPiled)+')');
       if(P.weapons.indexOf(ok)<0) bad.push('a record from another raid took that raid gun out of his armoury');
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0;
       netContInit(g);
       c=setLoot(mkContainer(g.player.x+30,g.player.y,'crate'),[key]); c.time=0.6; c.dropped=1;
       g.containers.push(c); cid=g.containers.length-1; c.cid=cid; NET.contMap[cid]=c; NET.contN=cid+1;
       P.gunPiled=[{gk:gk,sd:g.seed>>>0,home:0}];
       sayWhenFree=function(){};
       r=netLootTake({seat:0,state:'in'},{t:'loot',cid:cid,items:[key]});
       if(g.bag.indexOf(key)<0&&!(g.player.wep&&g.player.wep.id===gk)&&!(g.player.sec&&g.player.sec.id===gk)) return bad.length?bad.join('; '):'SKIP: staging: the gun did not come out of the pile ('+r+')';
       if(P.gunPiled.some(function(e){ return e&&e.gk===gk; })) bad.push('he took his gun back out of the pile and its record stayed, so a later rejoin would strip the gun he holds');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       sayWhenFree=oSwf;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.spliced=[]; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P.weapons=w0; if(rs0===undefined) delete P.raidSpliced; else P.raidSpliced=rs0; if(gp0===undefined) delete P.gunPiled; else P.gunPiled=gp0; P.equipped=e0; P.equippedSec=s0;
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
