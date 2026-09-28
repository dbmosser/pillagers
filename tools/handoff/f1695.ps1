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

if ($s.Contains("  {v:'16.95',what:")) { throw "check 16.95 is in the fixture already" }

SubRx @'
  {v:'16.94',what:
'@ @'
  {v:'16.95',what:'turned down at a box someone else is searching, a player lets go of the box he stepped away from: a linked window sends the stop so the host stops paying that box out to him, and the host lets his own box go',
   run:function(){
     if(typeof netSrchHold!=='function'||typeof netSrchSync!=='function'||typeof netSrchTick!=='function'||typeof netContInit!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no shared box search';
     var keep={}, oSend=netSend, oShown=netUpShown, oRef=netRefresh, sent=[], bad=[], a=null, b=null, i, k, c, r;
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     function stopped(cid){ for(var j=0;j<sent.length;j++){ var m=sent[j]; if(m&&m.t==='srch'&&m.op==='stop'&&m.cid===cid) return true; } return false; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: staging: no raid';
       netSend=function(q,m){ sent.push(m); return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){};
       NET.on=true; NET.role='join'; NET.seat=2; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:0}]; NET.up=[];
       NET.roster=[{seat:0,name:'CHECKHOST'},{seat:2,name:'CHECKTWO'},{seat:3,name:'CHECKTHREE'}];
       netContInit(G);
       for(i=0;i<G.containers.length;i++){ c=G.containers[i]; if(!c.opened&&c.loot&&c.loot.length){ if(!a) a=c; else if(!b){ b=c; break; } } }
       if(!a||!b) return 'SKIP: staging: no two unopened boxes with loot';
       G.searching=a; NET.srch={cid:a.cid,ok:1}; a.netBy=2; b.netBy=3; sent.length=0;
       r=netSrchHold(b,0.1); netSrchSync();
       if(r!=='held') return 'SKIP: staging: the box player 3 holds was not turned down ('+r+')';
       if(!stopped(a.cid)) bad.push('turned down at a box player 3 holds, player 2 never let go of the box he stepped away from (no stop sent), so the host kept paying it out to him');
       if(G.searching===a) bad.push('turned down at a box player 3 holds, player 2 still searches the box he stepped away from');
       G.searching=a; NET.srch={cid:a.cid,ok:1}; a.netBy=2; b.netBy=-1; b.netAskT=G.t; sent.length=0;
       r=netSrchHold(b,0.1); netSrchSync();
       if(r==='wait'&&!stopped(a.cid)) bad.push('waiting to ask again for a box that just turned him down, player 2 kept his search of the box he stepped away from running on the host');
       NET.role='host'; NET.seat=0; NET.peers=[{state:'in',seat:1}]; NET.srch=null; NET.holds={}; NET.srchOwn=-1;
       a.netBy=-1; b.netBy=-1; b.netSaidT=undefined; G.searching=a; netSrchTick(0);
       if(a.netBy!==0) return 'SKIP: staging: the host did not hold his own box ('+a.netBy+')';
       b.netBy=1;
       r=netSrchHold(b,0.1); netSrchTick(0);
       if(r!=='held') bad.push('the host was not turned down at a box player 2 holds ('+r+')');
       else if(a.netBy===0) bad.push('turned down at a box player 2 holds, the host kept his own box marked held by him, so the party is told he is searching it');
     } finally {
       try{ if(G){ G.searching=null; G.searchT=0; } }catch(e){}
       netSend=oSend; netUpShown=oShown; netRefresh=oRef;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
