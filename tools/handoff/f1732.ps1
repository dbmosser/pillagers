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

if ($s.Contains("  {v:'17.32',what:")) { throw "check 17.32 is in the fixture already" }

SubRx @'
  {v:'17.31',what:
'@ @'
  {v:'17.32',what:'a siege machine for a ring player 2 called lands at least 700 from player 2 as well as from player 1: in co-op a spot beside player 2 and far from player 1 is passed over for the next spot clear of both, and solo the same spot beside the ring is still taken',
   run:function(){
     if(typeof tickExtractPoints!=='function'||typeof netNearDist!=='function'||typeof freeSpot!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no extraction tick or no party distance';
     var keep={}, k, oFree=freeSpot, bad=[], S, C;
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     function unNet(){ var j; for(j in NET) if(Object.prototype.hasOwnProperty.call(NET,j)&&!Object.prototype.hasOwnProperty.call(keep,j)) delete NET[j]; for(j in keep) NET[j]=keep[j]; }
     function arrive(coop){
       var z, p, n0, calls=0, i, e, got=[];
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player||!G.zones||!G.zones.length||!G.tel) return null;
       z=G.zones[0]; p=G.player;
       for(i=0;i<G.zones.length;i++){ G.zones[i].beaconT=null; G.zones[i].hold=null; }
       z.beaconT=20; z.hold=null; z.siegeGreed=0.2; z.siegeSpawnT=50; z.siegeSpawned=0; z.siege=0; z.pinged=1;
       p.x=z.x+3000; p.y=z.y; p.downed=false;
       NET.on=!!coop; NET.role=coop?'host':null; NET.seat=coop?0:-1; NET.upSeed=coop?(G.seed>>>0):0; NET.peers=[]; NET.upOut=undefined; NET.fxQ=[];
       NET.roster=coop?[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}]:[];
       NET.up=coop?[{seat:1,n:1,age:0,sd:G.seed>>>0,tx:z.x,ty:z.y,tf:0,dn:0}]:[];
       n0=G.ents.length;
       freeSpot=function(){ calls++; return calls===1?{x:z.x+40,y:z.y}:{x:z.x-1200,y:z.y}; };
       try{ tickExtractPoints(0.01); } finally{ freeSpot=oFree; unNet(); }
       for(i=n0;i<G.ents.length;i++){ e=G.ents[i]; if(e&&e.siegeBorn) got.push(e); }
       return {z:z,got:got,calls:calls};
     }
     function down(){ try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(_e){} }
     try{
       S=arrive(false);
       if(!S) return 'SKIP: staging: no live raid with a ring';
       if(S.got.length!==1||dist(S.got[0],S.z)>100) return 'SKIP: staging: solo, the siege did not take the spot beside the ring ('+S.got.length+' arrivals, '+S.calls+' draws), so this staging does not reach the placement';
       down();
       C=arrive(true);
       if(!C) return 'SKIP: staging: no live raid with a ring for the co-op arm';
       if(C.got.length!==1) bad.push('co-op, the siege made '+C.got.length+' arrivals from '+C.calls+' draws, not one');
       else if(dist(C.got[0],C.z)<700) bad.push('co-op, a siege machine landed '+Math.round(dist(C.got[0],C.z))+' from player 2 at the ring he called, because only the host player '+Math.round(dist(C.got[0],{x:C.z.x+3000,y:C.z.y}))+' away was kept clear');
       if(C.got.length===1&&C.calls<2) bad.push('co-op, the spot beside player 2 was taken on the first draw');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       freeSpot=oFree; unNet(); down();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
