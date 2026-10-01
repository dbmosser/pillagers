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

if ($s.Contains("  {v:'17.60',what:")) { throw "check 17.60 is in the fixture already" }

SubRx @'
  {v:'17.59',what:
'@ @'
  {v:'17.60',what:'drop-in: a stale mark that the host is up top clears: the host answering it is not up takes JOIN THE RAID IN PROGRESS away, and a welcome from a host below clears the mark',
   run:function(){
     if(typeof netOnMsg0!=='function'||typeof netLateBtn!=='function') return 'SKIP: this build has no drop-in';
     if(typeof NET!=='object'||!NET||!window.__hubEnter) return 'SKIP: no party or floor in this fixture';
     var NK={}, k, bad=[], oSay=netSay, st0=state, G0=G, peer;
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __hubEnter();
       netSay=function(){};
       G=null; peer={seat:0,state:'in'}; NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[peer]; NET.hostSeed=4242;
       showScreen('hub');
       if(!document.getElementById('joinlate')) return 'SKIP: staging: no join button to take away';
       netOnMsg0(peer,JSON.stringify({t:'raidno'}));
       if(NET.hostSeed) bad.push('the host said it is not up top and the mark stayed ('+NET.hostSeed+')');
       if(document.getElementById('joinlate')) bad.push('JOIN THE RAID IN PROGRESS stayed after the host said it is not up top');
       NET.hostSeed=4242; peer={state:'open'}; NET.peers=[peer];
       netOnMsg0(peer,JSON.stringify({t:'welcome',you:1,roster:[{seat:0,host:1,name:'HOST',pid:'h0'},{seat:1,name:'TESTER',pid:'t1'}],ver:VER,up:0}));
       if(NET.hostSeed) bad.push('a welcome from a host below left the old mark ('+NET.hostSeed+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSay=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var jb=document.getElementById('joinlate'); if(jb&&jb.parentNode) jb.parentNode.removeChild(jb); }catch(_j){}
       G=G0; state=st0;
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
