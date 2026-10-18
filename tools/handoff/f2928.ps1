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

if ($s.Contains("  {v:'29.28',what:")) { throw "check 29.28 is in the fixture already" }

SubRx @'
  {v:'29.27',what:
'@ @'
  {v:'29.28',what:'the first Settings tab is not called Display (it holds every section, Display is one of them)',
   run:function(){
     if(typeof openSettings!=='function'||typeof openModal!=='function') return 'SKIP: no settings here';
     var bad=[], m=document.getElementById('settingsmodal'), was, tb, t;
     if(!m) return 'SKIP: no settings window';
     was=m.classList.contains('on');
     try{
       __topClear(); openSettings('display');
       tb=document.getElementById('settabs');
       if(!tb||!tb.children.length) return 'no Settings tabs';
       t=String(tb.children[0].textContent).trim().toLowerCase();
       if(t==='display') bad.push('the first Settings tab is still called Display');
       if(t!=='game') bad.push('the first Settings tab reads '+t+', not game');
       if(tb.children.length<2||String(tb.children[1].textContent).trim().toLowerCase()!=='send play data') bad.push('the Send play data tab moved');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} if(was) try{ openModal('settingsmodal'); }catch(_o){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
