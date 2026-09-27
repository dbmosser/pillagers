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

if ($s.Contains("  {v:'16.57',what:")) { throw "check 16.57 is in the fixture already" }

SubRx @'
  {v:'16.56',what:
'@ @'
  {v:'16.57',what:'while the host spectates, a party that is all paused is paused: the kept raid clock and world stand still, and run again when a teammate unpauses',
   run:function(){
     if(typeof netSpecTick!=='function'||typeof netSpecStart!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no spectating host';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,up:NET.up,peers:NET.peers,specAcc:NET.specAcc,specIdle:NET.specIdle,specHow:NET.specHow,status:NET.status},
         oSend=netSend, oShown=netUpShown, oRef=netRefresh, bad=[], k, t0, t1, t2;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSend=function(){ return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.up=[{seat:1,n:1,pz:1}];
       if(!netSpecStart('dead')) return 'SKIP: staging: the host did not start to spectate';
       G.over=true;
       t0=G.t; netSpecTick(0.5); netSpecTick(0.5); t1=G.t;
       if(t1!==t0) bad.push('with the whole party paused the kept raid ran on ('+(t1-t0).toFixed(2)+' s)');
       NET.up[0].pz=0; netSpecTick(0.5); t2=G.t;
       if(!(t2>t1)) bad.push('control: with the teammate unpaused the kept raid did not run');
     } finally {
       netSend=oSend; netUpShown=oShown; netRefresh=oRef;
       for(k in keep) NET[k]=keep[k];
       try{ if(G&&G.player) G.player.specOut=0; }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.56',what:
'@

# The welcome pack news (13.34) ages off the card once a later card replaces the v16.33 one.
SubRx @'
     var ver=parseFloat(WHATSNEW_VER);
     if(!(ver>=13.29))
'@ @'
     var ver=parseFloat(WHATSNEW_VER);
     if(ver>16.33+0.001) return 'SKIP: the card has moved on to v'+WHATSNEW_VER+' and the welcome pack news has aged off it';
     if(!(ver>=13.29))
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
