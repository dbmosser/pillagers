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

if ($s.Contains("  {v:'16.55',what:")) { throw "check 16.55 is in the fixture already" }

SubRx @'
  {v:'16.54',what:
'@ @'
  {v:'16.55',what:'a teammate still on the run card goes up with the party: the kit question closes the card and asks him, and the host word carries him up instead of leaving him below',
   run:function(){
     if(typeof netKitTake!=='function'||typeof netUpTake!=='function'||typeof netUpStart!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no party ascent';
     var keep={on:NET.on,role:NET.role,peers:NET.peers,status:NET.status,err:NET.err}, oSend=netSend, oStart=netUpStart, oRef=netRefresh, bad=[], r, went=0,
         oc=document.getElementById('outcome'), mod=document.getElementById('askmodal');
     function card(){ var o1=NET.on, o2=NET.role; NET.on=false; NET.role=null; try{ __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); if(G) __endRaid('dead'); } finally { NET.on=o1; NET.role=o2; } return !!(oc&&oc.classList.contains('on')&&G&&G.over); }
     try{
       netSend=function(){ return true; }; netRefresh=function(){}; netUpStart=function(){ went++; return 'up'; };
       NET.on=true; NET.role='join'; NET.peers=[{state:'in',seat:0}];
       if(!card()) return 'SKIP: staging: no run card after a death';
       r=netKitTake({state:'in'},{t:'kitask'});
       if(r!=='kit:ask') bad.push('the kit question reached a teammate on the run card as '+r+', so he was never asked');
       if(oc.classList.contains('on')) bad.push('the run card stayed up when the party was asked for kits');
       if(mod) mod.classList.remove('on');
       if(!card()) return 'SKIP: staging: no second run card';
       r=netUpTake({state:'in'},{t:'up',seed:4242});
       if(r!=='up'||!went) bad.push('the host word left a teammate on the run card below ('+r+')');
     } finally {
       netSend=oSend; netUpStart=oStart; netRefresh=oRef;
       NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.status=keep.status; NET.err=keep.err;
       if(mod) mod.classList.remove('on'); try{ ASKYES=null; ASKALT=null; ASKBACK=null; }catch(e){}
       try{ __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
