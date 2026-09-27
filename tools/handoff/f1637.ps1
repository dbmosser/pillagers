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

if ($s.Contains("  {v:'16.37',what:")) { throw "check 16.37 is in the fixture already" }

SubRx @'
  {v:'16.36',what:
'@ @'
  {v:'16.37',what:'every player chooses a kit: the host waits for each teammate, a teammate is shown MY LOADOUT and FREEBIE KIT, and its answer tells the host',
   run:function(){
     if(typeof netKitGate!=='function'||typeof netKitTake!=='function'||typeof askKit!=='function') return 'this build never asks a teammate for a kit';
     var keep={on:NET.on,role:NET.role,peers:NET.peers,status:NET.status}, oSend=netSend, oRef=netRefresh, sent=[], went=0, r, bad=[], mod=document.getElementById('askmodal');
     try{
       netSend=function(q,m){ sent.push(m.t); return true; }; netRefresh=function(){};
       NET.on=true; NET.role='host'; NET.peers=[{state:'in',seat:1}];
       r=netKitGate(function(){ went++; });
       if(r!=='wait'||went) bad.push('the host went up without waiting for its teammate ('+r+', '+went+')');
       if(sent.indexOf('kitask')<0) bad.push('the host did not ask its teammate');
       netKitTake({state:'in'},{t:'kitok'});
       if(went!==1) bad.push('the teammate answer did not send the party up');
       NET.role='join'; sent=[];
       r=netKitTake({state:'in'},{t:'kitask'});
       if(r==='kit:ask'){
         if(!mod||!mod.classList.contains('on')) bad.push('the teammate was not shown the kit card');
         var y=document.getElementById('askyes'), a=document.getElementById('askalt');
         if(!y||y.textContent!=='MY LOADOUT'||!a||a.textContent!=='FREEBIE KIT'||a.style.display==='none') bad.push('the teammate card does not offer MY LOADOUT and FREEBIE KIT');
         if(ASKBACK) bad.push('the teammate card puts back a sector page it never showed');
         if(typeof ASKYES==='function') ASKYES();
         if(sent.indexOf('kitok')<0) bad.push('the teammate answer did not tell the host');
       } else if(r!=='kit:busy') bad.push('a teammate asked for its kit answered '+r);
     } finally {
       netSend=oSend; netRefresh=oRef; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.status=keep.status; NET.kitWait=null;
       if(mod) mod.classList.remove('on'); ASKYES=null; ASKALT=null; ASKBACK=null;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.36',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
