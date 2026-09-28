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

if ($s.Contains("  {v:'17.06',what:")) { throw "check 17.06 is in the fixture already" }

SubRx @'
  {v:'17.05',what:
'@ @'
  {v:'17.06',what:'an armoury gun the host dropped and a teammate searched up comes off the host put back list: the saved list a closed window reads loses it, and an abandon after it no longer puts it back in the host armoury, while a gun nobody took still comes back',
   run:function(){
     if(typeof netSrchTick!=='function'||typeof netContInit!=='function'||typeof netPeerOfSeat!=='function'||!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot stage a party search';
     var keep={}, oSend=netSend, w0=(P.weapons||[]).slice(), hadRs=Object.prototype.hasOwnProperty.call(P,'raidSpliced'), rs0=P.raidSpliced,
         sent=[], bad=[], ct=null, p=null, gk=null, other=null, i, k, c, ids=['carbine','lance','whisper','shotgun','magnum','smg','lmg','sniper'];
     function netBack(){ netSend=oSend; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k]; for(k in keep) NET[k]=keep[k]; }
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       p=G.player;
       for(i=0;i<ids.length;i++){ k=ids[i]; if(!ITEMS['gun_'+k]||!WEAPONS[k]) continue; if((p.wep&&p.wep.id===k)||(p.sec&&p.sec.id===k)||P.equipped===k||P.equippedSec===k) continue; if(!gk) gk=k; else if(!other){ other=k; break; } }
       if(!gk||!other) return 'SKIP: staging: no two armoury guns free to stage';
       netSend=function(q,m){ sent.push(m); return true; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.up=[];
       netContInit(G);
       for(i=0;i<G.containers.length;i++){ c=G.containers[i]; if(!c.opened&&c.loot&&c.loot.length){ ct=c; break; } }
       if(!ct) return 'SKIP: staging: no unopened box';
       ct.loot=['gun_'+gk]; ct.pulled=0; ct.prog=0; ct.time=1; ct.dropped=1;
       P.weapons=P.weapons.filter(function(q){ return q!==gk&&q!==other; });
       G.spliced=[gk,other]; P.raidSpliced=[gk,other]; G.searching=null;
       NET.holds[1]={cid:ct.cid,slow:1}; ct.netBy=1;
       netSrchTick(2);
       if(!sent.some(function(m){ return m&&m.t==='loot'&&m.items&&m.items.indexOf('gun_'+gk)>=0; })) return 'SKIP: staging: the host did not hand the gun to the teammate';
       if((P.raidSpliced||[]).indexOf(gk)>=0) bad.push('the saved list a closed window puts back still names the gun the teammate took');
       if(G.spliced.indexOf(other)<0||(P.raidSpliced||[]).indexOf(other)<0) bad.push('a gun nobody handed over left the put back list');
       netBack();
       __endRaid('abandon');
       if(P.weapons.indexOf(gk)>=0) bad.push('after the host abandons, the gun the teammate took home is back in the host armoury as well');
       if(P.weapons.indexOf(other)<0) bad.push('after the host abandons, a gun still on the put back list did not come back');
     } finally {
       netBack();
       try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(e){}
       P.weapons=w0; if(hadRs) P.raidSpliced=rs0; else delete P.raidSpliced;
       try{ saveProfile(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
