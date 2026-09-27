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

if ($s.Contains("  {v:'16.64',what:")) { throw "check 16.64 is in the fixture already" }

SubRx @'
  {v:'16.63',what:
'@ @'
  {v:'16.64',what:'a host back in the Undercroft while his party is still up top is still hosting: the leave warning holds and Settings greys the buttons that reload the window',
   run:function(){
     if(typeof netHostHolds!=='function'||typeof netSpecStart!=='function'||typeof renderSettings!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no spectating host';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,up:NET.up,peers:NET.peers,specAcc:NET.specAcc,specIdle:NET.specIdle,specHow:NET.specHow,status:NET.status},
         oSend=netSend, oShown=netUpShown, oRef=netRefresh, bad=[], k, kG=null, b;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSend=function(){ return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.up=[{seat:1,n:1}];
       if(!netSpecStart('dead')) return 'SKIP: staging: the host did not start to spectate';
       G.over=true; kG=G; G=null;
       if(!netHostHolds()) bad.push('a host in the Undercroft running the raid for his party is not holding it: no leave warning');
       renderSettings(); b=document.getElementById('set_restore');
       if(b&&!b.disabled) bad.push('Settings offers PICK FILE to a host running the raid for his party');
       NET.specG=null;
       if(netHostHolds()) bad.push('control: with no raid run for the party the host still reads as holding one');
     } finally {
       if(kG) G=kG;
       netSend=oSend; netUpShown=oShown; netRefresh=oRef;
       for(k in keep) NET[k]=keep[k];
       try{ renderSettings(); }catch(e){}
       try{ if(G&&G.player) G.player.specOut=0; }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
