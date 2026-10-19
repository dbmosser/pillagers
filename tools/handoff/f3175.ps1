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

if ($s.Contains("  {v:'31.75',what:")) { throw "check 31.75 is in the fixture already" }

SubRx @'
  {v:'31.74',what:
'@ @'
  {v:'31.75',what:'Settings and keys lists fade out at the bottom and the settings detail pane runs the full height of the list',
   run:function(){
     var bad=[], l, d, k, m, a, b;
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       openSettings('display');
       try{ window.__setDetailSync(); }catch(_s){}
       l=document.getElementById('setlist'); d=document.getElementById('setdetail');
       m=l?getComputedStyle(l).maskImage:'none';
       if(!l||!m||m==='none') bad.push('settings list has no bottom fade ('+m+')');
       if(l&&d){ a=l.getBoundingClientRect().height; b=d.getBoundingClientRect().height; if(b<a-4) bad.push('detail pane is '+Math.round(b)+' tall against the list '+Math.round(a)); }
       document.getElementById('settingsmodal').classList.remove('on');
       keysOpen();
       k=document.getElementById('keyslist'); m=k?getComputedStyle(k).maskImage:'none';
       if(!k||!m||m==='none') bad.push('keys list has no bottom fade ('+m+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); var kq=document.getElementById('keysmodal'); if(kq) kq.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'31.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
