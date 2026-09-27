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

if ($s.Contains("  {v:'16.59',what:")) { throw "check 16.59 is in the fixture already" }

SubRx @'
  {v:'16.58',what:
'@ @'
  {v:'16.59',what:'a fault in the raid the spectating host keeps running is written into the host run report once, not swallowed',
   run:function(){
     if(typeof netSpecTick!=='function'||typeof netSpecStart!=='function'||!window.__P||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no spectating host';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,up:NET.up,peers:NET.peers,specAcc:NET.specAcc,specIdle:NET.specIdle,specHow:NET.specHow,status:NET.status},
         oSend=netSend, oShown=netUpShown, oRef=netRefresh, oUE=updateEnts, oSay=say, bad=[], k, P0=__P(), c0, got;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSend=function(){ return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){}; say=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.up=[{seat:1,n:1}];
       if(!netSpecStart('dead')) return 'SKIP: staging: the host did not start to spectate';
       G.over=true;
       P0=__P(); if(!Array.isArray(P0.crashes)) P0.crashes=[]; c0=P0.crashes.length;
       updateEnts=function(){ throw new Error('check1659 staged fault'); };
       netSpecTick(0.1); netSpecTick(0.1);
       got=P0.crashes.filter(function(c){ return c&&String(c.msg).indexOf('check1659 staged fault')>=0; });
       if(!got.length) bad.push('a fault in the kept raid was swallowed and never reached the run report');
       else if(got.length>1||(got[0].n||1)>1) bad.push('the fault was written more than once ('+got.length+' entries, n '+(got[0].n||1)+')');
     } finally {
       updateEnts=oUE; netSend=oSend; netUpShown=oShown; netRefresh=oRef; say=oSay;
       for(k in keep) NET[k]=keep[k];
       try{ P0.crashes=P0.crashes.filter(function(c){ return !(c&&String(c.msg).indexOf('check1659')>=0); }); }catch(e){}
       try{ if(G&&G.player) G.player.specOut=0; }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
