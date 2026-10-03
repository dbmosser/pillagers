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

if ($s.Contains("  {v:'17.70',what:")) { throw "check 17.70 is in the fixture already" }

SubRx @'
  {v:'17.69',what:
'@ @'
  {v:'17.70',what:'one sound setting for the pair: BOTH PLAYERS, PLAYER 1 ONLY or PLAYER 2 ONLY, read by each window from the shared setting; the PARTY window button cycles it',
   run:function(){
     if(typeof netSndWhoSet!=='function'||typeof netSndApply!=='function') return 'each window has its own SOUND ON/OFF button';
     if(typeof NET!=='object'||!NET||typeof renderParty!=='function') return 'SKIP: no party in this fixture';
     var NK={}, k, bad=[], g0=NET.sndG, p0=NET.sndP, who0=null, b;
     for(k in NET) NK[k]=NET[k];
     try{ who0=localStorage.getItem(NET_WHO_KEY); }catch(_r){}
     try{
       NET.sndG={gain:{value:1}}; NET.sndP={pan:{value:0}}; NET.same='p2'; NET.pair='t';
       netSndWhoSet('p1'); if(NET.sndG.gain.value!==0) bad.push('with player 1 only, the player 2 window still plays');
       netSndWhoSet('p2'); if(NET.sndG.gain.value!==1) bad.push('with player 2 only, the player 2 window is silent');
       NET.same='host'; netSndApply(); if(NET.sndG.gain.value!==0) bad.push('with player 2 only, the player 1 window still plays');
       netSndWhoSet('both'); if(NET.sndG.gain.value!==1) bad.push('with both, the player 1 window is silent');
       renderParty(); b=document.getElementById('partysndbtn');
       if(!b||b.textContent.indexOf('BOTH PLAYERS')<0) bad.push('the PARTY button reads '+JSON.stringify(b&&b.textContent));
       b.onclick(); if(netSndWho()!=='p1'||b.textContent.indexOf('PLAYER 1 ONLY')<0) bad.push('the button did not cycle to player 1 only ('+netSndWho()+', '+JSON.stringify(b.textContent)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(who0===null) localStorage.removeItem(NET_WHO_KEY); else localStorage.setItem(NET_WHO_KEY,who0); }catch(_w){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       NET.sndG=g0; NET.sndP=p0;
       try{ netSndApply(); }catch(_a){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
