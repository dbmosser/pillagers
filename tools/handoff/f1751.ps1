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

if ($s.Contains("  {v:'17.51',what:")) { throw "check 17.51 is in the fixture already" }

SubRx @'
  {v:'17.50',what:
'@ @'
  {v:'17.51',what:'drop-in can be reached: back on the Undercroft floor with the host up top, JOIN THE RAID IN PROGRESS shows on the page (not inside the hidden terminal panel), and going up at the lift as a teammate asks to join the raid in progress',
   run:function(){
     if(typeof netLateBtn!=='function'||typeof netGuestHeld!=='function'||typeof showScreen!=='function') return 'SKIP: this build has no drop-in';
     if(typeof NET!=='object'||!NET||!window.__hubEnter) return 'SKIP: no party or floor in this fixture';
     var NK={}, k, sent=[], bad=[], oSend=netSend, oSay=netSay, st0=state, G0=G, b, r, held;
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __hubEnter();
       netSend=function(p,m){ sent.push(m); return true; };
       netSay=function(){};
       G=null; NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upHold=false; NET.specG=null; NET.hostSeed=4242;
       showScreen('hub');
       b=document.getElementById('joinlate');
       if(!b) bad.push('no JOIN THE RAID IN PROGRESS button on the floor after coming back down with the host up');
       else{
         r=b.getBoundingClientRect();
         if(!(r.width>0&&r.height>0)) bad.push('the join button is there but not shown ('+Math.round(r.width)+'x'+Math.round(r.height)+')');
       }
       sent.length=0; held=netGuestHeld();
       if(!held) bad.push('a teammate going up at the lift with the host up top was let up alone');
       if(!sent.some(function(m){ return m&&m.t==='raidq'; })) bad.push('going up at the lift with the host up top did not ask to join the raid in progress');
       NET.hostSeed=0; showScreen('hub');
       if(document.getElementById('joinlate')) bad.push('the join button stayed with the host back down');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netSay=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var jb=document.getElementById('joinlate'); if(jb&&jb.parentNode) jb.parentNode.removeChild(jb); }catch(_j){}
       G=G0; state=st0;
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
