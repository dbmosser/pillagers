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

if ($s.Contains("  {v:'17.23',what:")) { throw "check 17.23 is in the fixture already" }

SubRx @'
  {v:'17.22',what:
'@ @'
  {v:'17.23',what:'an armoury gun the host dropped and a teammate searched up after the host abandoned leaves the host armoury and his gun slots, so the one gun is not in both saves, while a gun nobody took stays in his armoury',
   run:function(){
     if(typeof netSrchTick!=='function'||typeof netContInit!=='function'||typeof netPeerOfSeat!=='function'||!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot stage a party search';
     var keep={}, oSend=netSend, w0=(P.weapons||[]).slice(), e0=P.equipped, s0=P.equippedSec, hadRs=Object.prototype.hasOwnProperty.call(P,'raidSpliced'), rs0=P.raidSpliced,
         sent=[], bad=[], ct=null, p=null, g=null, gEnd=null, ended=false, gk=null, other=null, i, k, c, ids=['carbine','lance','whisper','shotgun','magnum','smg','lmg','sniper'];
     function netBack(){ netSend=oSend; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k]; for(k in keep) NET[k]=keep[k]; }
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=G; p=G.player;
       for(i=0;i<ids.length;i++){ k=ids[i]; if(!ITEMS['gun_'+k]||!WEAPONS[k]) continue; if((p.wep&&p.wep.id===k)||(p.sec&&p.sec.id===k)||P.equipped===k||P.equippedSec===k) continue; if(!gk) gk=k; else if(!other){ other=k; break; } }
       if(!gk||!other) return 'SKIP: staging: no two armoury guns free to stage';
       P.weapons=P.weapons.filter(function(q){ return q!==gk&&q!==other; });
       G.spliced=[gk,other]; P.raidSpliced=[gk,other]; G.searching=null;
       // The host abandons with both guns out of his armoury, one of them lying in a pile he dropped.
       __endRaid('abandon'); ended=true; gEnd=G;
       if(g.over!=='abandon'||P.weapons.indexOf(gk)<0||P.weapons.indexOf(other)<0) return 'SKIP: staging: the abandon did not put the two guns back in the host armoury';
       P.equipped=gk; P.equippedSec='none';   // back in the Undercroft he takes the gun up again
       // His party is still up top, so the ended raid runs on as the kept raid, as netSpecTick runs it.
       G=g; G.searching=null;
       netSend=function(q,m){ sent.push(m); return true; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.up=[]; NET.specG=G;
       netContInit(G);
       for(i=0;i<G.containers.length;i++){ c=G.containers[i]; if(!c.opened&&c.loot&&c.loot.length){ ct=c; break; } }
       if(!ct) return 'SKIP: staging: no unopened box';
       ct.loot=['gun_'+gk]; ct.pulled=0; ct.prog=0; ct.time=1; ct.dropped=1;
       NET.holds[1]={cid:ct.cid,slow:1}; ct.netBy=1;
       netSrchTick(2);
       if(!sent.some(function(m){ return m&&m.t==='loot'&&m.items&&m.items.indexOf('gun_'+gk)>=0; })) return 'SKIP: staging: the host did not hand the gun to the teammate';
       if(P.weapons.indexOf(gk)>=0) bad.push('the host abandoned, then a teammate searched up the gun the host had dropped, and the gun is still in the host armoury as well: one gun in both saves');
       if(P.equipped===gk) bad.push('the host gun 1 still names the gun the teammate took home');
       if(P.weapons.indexOf(other)<0) bad.push('a gun nobody took left the host armoury');
     } finally {
       netBack();
       if(ended) G=gEnd;
       try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(e){}
       P.weapons=w0; P.equipped=e0; P.equippedSec=s0; if(hadRs) P.raidSpliced=rs0; else delete P.raidSpliced;
       try{ saveProfile(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
