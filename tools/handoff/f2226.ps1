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

if ($s.Contains("  {v:'22.26',what:")) { throw "check 22.26 is in the fixture already" }

SubRx @'
  {v:'22.25',what:
'@ @'
  {v:'22.26',what:'the rounds a gun was stowed with leave with the gun: sold at the stall, handed to a teammate, or taken by a teammate out of a pile, the next gun of that model from the backpack comes up on half a magazine, and a gun lying in his own pile keeps its load',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof stowRounds!=='function'||typeof takeRounds!=='function'||typeof pedSellAll!=='function'||typeof netGunGoneTake!=='function'||typeof netGiftTake!=='function'||typeof netGunsGone!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSend=netSend, oGS=netGiftSend, gk=null, key=null, mag=0, half, i, ks=Object.keys(ITEMS), g, r, w0, rs0, gp0, e0, s0;
     for(i=0;i<ks.length;i++){ var _it=ITEMS[ks[i]], _w=_it&&_it.gk?WEAPONS[_it.gk]:null; if(/^gun_/.test(ks[i])&&_it&&_it.use==='gun'&&_w&&(_w.mag|0)>=4&&ival(ks[i])>0){ key=ks[i]; gk=_it.gk; mag=_w.mag|0; break; } }
     if(!key) return 'SKIP: no gun with a magazine of four or more here';
     half=Math.ceil(mag/2);
     function left(){ var q=g.stowAmmo&&g.stowAmmo[gk]; return q?q.length:0; }
     for(k in NET) NK[k]=NET[k];
     w0=(P.weapons||[]).slice(); rs0=P.raidSpliced; gp0=P.gunPiled; e0=P.equipped; s0=P.equippedSec;
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       g.spliced=[]; g.hotAssign={}; delete P.gunPiled;
       g.stowAmmo={}; stowRounds(gk,1); g.bag.push(key);
       g.trade={x:g.player.x,y:g.player.y,stock:[]};
       try{ pedSellAll(); }finally{ g.trade=null; }
       if(g.bag.indexOf(key)>=0) return 'SKIP: staging: the stall did not buy the gun';
       if(left()) bad.push('a gun sold at the stall left its 1 stowed round queued for the next one of its model');
       g.stowAmmo={}; stowRounds(gk,1); g.bag.push(key); dropItem(g.bag.length-1);
       if(left()!==1) bad.push('a gun dropped in his own pile lost the load it comes back up with');
       netSend=function(){ return true; }; netGiftSend=function(){ return true; };
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0;
       g.stowAmmo={}; stowRounds(gk,1);
       r=netGunGoneTake({seat:0,state:'in'},{t:'gungone',k:gk});
       if(r!=='gungone') bad.push('staging: the taken word said '+r);
       else if(left()) bad.push('a gun his teammate took out of his pile left its stowed round queued here');
       g.stowAmmo={}; stowRounds(gk,1); g.bag.push(key);
       g.giftOut={id:'zq7gift',k:key,to:0,t:g.t};
       r=netGiftTake({seat:0,state:'in'},{t:'gift',op:'yes',id:'zq7gift',from:0,to:1});
       if(r!=='gave') bad.push('staging: the hand-over said '+r);
       else if(left()) bad.push('a gun handed to his teammate left its stowed round queued here');
       NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}];
       g.stowAmmo={}; stowRounds(gk,1);
       netGunsGone({x:g.player.x,y:g.player.y,dropped:1,loot:[]},[key]);
       if(left()) bad.push('a gun a teammate took out of the host pile left its stowed round queued on the host');
       r=takeRounds(gk,mag);
       if(r!==half) bad.push('the next one of that model from the backpack comes up with '+r+' rounds, not half a magazine ('+half+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netGiftSend=oGS;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.trade=null; g2.giftOut=null; g2.spliced=[]; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P.weapons=w0; if(rs0===undefined) delete P.raidSpliced; else P.raidSpliced=rs0; if(gp0===undefined) delete P.gunPiled; else P.gunPiled=gp0; P.equipped=e0; P.equippedSec=s0;
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
