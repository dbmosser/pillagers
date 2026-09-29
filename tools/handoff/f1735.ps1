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

if ($s.Contains("  {v:'17.35',what:")) { throw "check 17.35 is in the fixture already" }

SubRx @'
  {v:'17.34',what:
'@ @'
  {v:'17.35',what:'a same machine row picked again while player 2 is linked never reloads the player 2 window: the same mode only starts this side and brings that window forward, the other mode is refused with a sentence and keeps the mode, and with no link the row still opens the window',
   run:function(){
     if(typeof netSamePick!=='function'||typeof netInCount!=='function'||typeof netModeMsg!=='function'||typeof NET!=='object'||!NET) return 'SKIP: this build has no same machine rows';
     if(typeof BroadcastChannel!=='function'||typeof netSupported!=='function'||!netSupported()) return 'SKIP: this browser cannot run two game windows';
     var nk=['on','role','same','pair','mode','peers','p2win','p2url','pick','status','bc','sameBusy','err'], keep={}, i;
     for(i=0;i<nk.length;i++) keep[nk[i]]=NET[nk[i]];
     var oOpen=window.open, opens=[], started=0, focused=0, r, bad=[], msg=document.getElementById('modemsg');
     var win={closed:false,focus:function(){ focused++; }};
     var mate={state:'in',seat:1,pid:'zqxmate',name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){},close:function(){}}};
     var chan={posted:[],postMessage:function(m){ this.posted.push(m); },close:function(){},onmessage:null};
     function start(){ started++; }
     try{
       window.open=function(u,nm,ft){ opens.push(String(u)); return null; };
       NET.on=true; NET.role='host'; NET.same='host'; NET.pair='zqxpair'; NET.mode='coop'; NET.pick='coop'; NET.p2win=win; NET.bc=chan; NET.peers=[mate];
       r=netSamePick('coop',start);
       if(opens.length) bad.push('picking 2 PLAYER CO-OP (SAME MACHINE) again with player 2 linked opened the player 2 window again, which reloads his live page ('+r+')');
       if(started!==1) bad.push('picking the same row again with player 2 linked did not start this side ('+started+' starts, '+r+')');
       if(!focused) bad.push('picking the same row again did not bring the player 2 window forward');
       if(NET.mode!=='coop'||NET.p2win!==win||NET.peers[0]!==mate) bad.push('picking the same row again changed the link (mode '+NET.mode+')');
       opens.length=0; started=0;
       r=netSamePick('pvp',start);
       if(opens.length) bad.push('picking the PVP row with player 2 linked in co-op opened the player 2 window again ('+r+')');
       if(NET.mode!=='coop') bad.push('picking the PVP row with player 2 linked in co-op switched the mode quietly to '+NET.mode);
       if(started) bad.push('picking the PVP row with player 2 linked in co-op started this side in the old mode');
       if(!msg||msg.style.display==='none'||!String(msg.textContent||'')) bad.push('picking the PVP row with player 2 linked in co-op said nothing');
       opens.length=0; started=0; mate.state='gone';
       r=netSamePick('coop',start);
       if(opens.length!==1) bad.push('control: with no link the row did not open the player 2 window ('+r+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally {
       window.open=oOpen;
       for(i=0;i<nk.length;i++) NET[nk[i]]=keep[nk[i]];
       try{ netModeMsg(''); }catch(_m){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
