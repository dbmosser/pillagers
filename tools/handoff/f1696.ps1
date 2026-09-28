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

if ($s.Contains("  {v:'16.96',what:")) { throw "check 16.96 is in the fixture already" }

SubRx @'
  {v:'16.95',what:
'@ @'
  {v:'16.96',what:'with the whole party paused a teammate search on the host stands still: the box does not fill or pay out, and it runs again once a teammate unpauses',
   run:function(){
     if(typeof netUpTick!=='function'||typeof netSrchTick!=='function'||typeof netContInit!=='function'||typeof netPauseLive!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no party search on the host';
     var keep={}, oSend=netSend, oShown=netUpShown, oRef=netRefresh, bad=[], ct=null, i, k, c, p0, n0, p1;
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: staging: no raid';
       netSend=function(){ return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:1}];
       NET.roster=[{seat:0,name:'CHECKHOST'},{seat:1,name:'CHECKTWO'}];
       NET.up=[]; NET.up[1]={seat:1,n:1,pz:1,sa:1,dn:0,x:G.player.x,y:G.player.y,tx:G.player.x,ty:G.player.y,f:0,tf:0,bob:0,roll:0,age:0,mv:0};
       NET.upAcc=-1e9;
       netContInit(G);
       for(i=0;i<G.containers.length;i++){ c=G.containers[i]; if(!c.opened&&c.loot&&c.loot.length>1&&(c.time||1)>2){ ct=c; break; } }
       if(!ct) return 'SKIP: staging: no unopened box with loot and a long enough search';
       NET.holds[1]={cid:ct.cid,slow:1}; ct.netBy=1; ct.prog=0; ct.pulled=0;
       G.paused=true;
       if(netPauseLive()) return 'SKIP: staging: the whole party paused did not stop the world';
       p0=ct.prog||0; n0=ct.loot.length;
       for(i=0;i<8;i++) netUpTick(0.1);
       if((ct.prog||0)!==p0||ct.loot.length!==n0) bad.push('with the whole party paused the teammate search ran on (bar '+p0+' to '+(+(ct.prog||0)).toFixed(2)+' s, items in the box '+n0+' to '+ct.loot.length+')');
       NET.up[1].pz=0;
       if(!netPauseLive()) return 'SKIP: staging: with the teammate unpaused the world did not run';
       p1=ct.prog||0;
       for(i=0;i<5;i++) netUpTick(0.1);
       if(!((ct.prog||0)>p1)) bad.push('control: with the teammate unpaused his search did not move');
     } finally {
       try{ if(G){ G.paused=false; G.searching=null; } }catch(e){}
       netSend=oSend; netUpShown=oShown; netRefresh=oRef;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
