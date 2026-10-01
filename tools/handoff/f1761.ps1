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

if ($s.Contains("  {v:'17.61',what:")) { throw "check 17.61 is in the fixture already" }

SubRx @'
  {v:'17.60',what:
'@ @'
  {v:'17.61',what:'JOIN THE RAID IN PROGRESS is big enough to see from the couch (20 px lettering at least) and says the lift joins too',
   run:function(){
     if(typeof netLateBtn!=='function'||typeof NET!=='object'||!NET||!window.__hubEnter) return 'SKIP: this build has no drop-in';
     var NK={}, k, bad=[], st0=state, G0=G, b, fs, r;
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __hubEnter();
       G=null; NET.on=true; NET.role='join'; NET.seat=1; NET.hostSeed=4242; state='hub';
       try{ var ob=document.getElementById('joinlate'); if(ob&&ob.parentNode) ob.parentNode.removeChild(ob); }catch(_o){}
       netLateBtn(); b=document.getElementById('joinlate');
       if(!b) return 'SKIP: staging: no join button';
       fs=parseFloat(getComputedStyle(b).fontSize); r=b.getBoundingClientRect();
       if(!(fs>=20)) bad.push('the join button lettering is '+fs+' px');
       if(!/ENTER RAID/.test(b.textContent||'')) bad.push('the join button does not say the lift joins too ('+b.textContent+')');
       if(b.textContent.indexOf('JOIN THE RAID IN PROGRESS')!==0) bad.push('the join button no longer leads with JOIN THE RAID IN PROGRESS');
       if(!(r.top>=0&&r.left>=0&&r.right<=innerWidth)) bad.push('the join button runs off the screen');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var jb=document.getElementById('joinlate'); if(jb&&jb.parentNode) jb.parentNode.removeChild(jb); }catch(_j){}
       G=G0; state=st0;
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
