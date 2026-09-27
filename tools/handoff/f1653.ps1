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

if ($s.Contains("  {v:'16.53',what:")) { throw "check 16.53 is in the fixture already" }

SubRx @'
  {v:'16.52',what:
'@ @'
  {v:'16.53',what:'while the host spectates, a teammate search still runs on the host, and a box the host was searching when his run ended is let go',
   run:function(){
     if(typeof netSpecTick!=='function'||typeof netSrchTick!=='function'||typeof netContInit!=='function'||typeof netSpecStart!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no spectating host';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,up:NET.up,peers:NET.peers,specAcc:NET.specAcc,specIdle:NET.specIdle,specHow:NET.specHow,status:NET.status},
         oSend=netSend, oShown=netUpShown, oRef=netRefresh, bad=[], ct=null, mine=null, i, k, p0=0;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSend=function(){ return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.up=[{seat:1,n:1}];
       netContInit(G);
       for(i=0;i<G.containers.length;i++){ var c=G.containers[i]; if(!c.opened&&c.loot&&c.loot.length){ if(!ct) ct=c; else if(!mine){ mine=c; break; } } }
       if(!ct||!mine) return 'SKIP: staging: no two unopened boxes with loot';
       G.searching={cid:mine.cid}; netSrchTick(0);
       if(mine.netBy!==0) return 'SKIP: staging: the host did not hold its own box ('+mine.netBy+')';
       NET.holds[1]={cid:ct.cid,slow:1}; ct.netBy=1;
       if(!netSpecStart('dead')) return 'SKIP: staging: the host did not start to spectate';
       G.over=true; p0=ct.prog||0;
       for(i=0;i<10;i++) netSpecTick(0.1);
       if(!((ct.prog||0)>p0)) bad.push('while the host spectates a teammate search does not move (prog '+(ct.prog||0)+')');
       if(mine.netBy===0) bad.push('the box the host was searching when his run ended stays held by the host');
     } finally {
       netSend=oSend; netUpShown=oShown; netRefresh=oRef;
       for(k in keep) NET[k]=keep[k];
       NET.holds={}; NET.contMap={}; NET.srchOwn=-1;
       try{ if(G&&G.player) G.player.specOut=0; }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
