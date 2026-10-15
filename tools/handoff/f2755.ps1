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

if ($s.Contains("  {v:'27.55',what:")) { throw "check 27.55 is in the fixture already" }

SubRx @'
  {v:'27.54',what:
'@ @'
  {v:'27.55',what:'his 2026-10-14 note (UI cleanup uic7): the Settings row descriptions are in one voice, sentence case like the rows of THE RAID: none of the rows is a line in capitals (38 of them were, in CONTROLS, DISPLAY, AUDIO, CONTROLLER and ACCESSIBILITY)',
   run:function(){
     if(typeof openSettings!=='function') return 'SKIP: no Settings window in this build';
     var m=document.getElementById('settingsmodal'), was=m&&m.classList.contains('on');
     if(!m) return 'SKIP: no Settings window';
     var bad=[];
     try{
       try{ __topClear(); }catch(_t){}
       openSettings();
       var hs=document.querySelectorAll('#setlist .row .hint'), i, t, n=0, caps=[];
       for(i=0;i<hs.length;i++){ t=String(hs[i].textContent||'').trim(); if(t.length<12) continue; n++; if(t===t.toUpperCase()&&/[A-Z]{4}/.test(t)) caps.push(t.slice(0,48)); }
       if(n<20) return 'SKIP: only '+n+' row descriptions are drawn here';
       if(caps.length) bad.push(caps.length+' of '+n+' row descriptions are in capitals, such as: '+caps.slice(0,3).join(' | '));
       return bad.length?bad.join('; '):null;
     } finally { try{ __topClear(); }catch(_c){} if(!was) m.classList.remove('on'); } }},
  {v:'27.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
