$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'13.49',what:
'@ @'
  {v:'13.50',what:'the build picker asks for the build archive only on his machine: off localhost it makes no request for builds/index.json and says there is no archive on this host, while on localhost it still requests the archive (crash sweep 2026-09-14)',
   run:function(){
     if(typeof initBuildPicker!=='function') return 'SKIP: no build picker in this build';
     var sel=document.getElementById('buildsel'), go=document.getElementById('buildgo');
     if(!sel||!go) return 'SKIP: the build picker is not in this page';
     if(typeof buildArchiveHost!=='function') return 'the build picker has no host test, so off his machine (itch) it requests builds/index.json on every page load and logs a missing file';
     var bad=[], keepF=window.fetch, keepH=buildArchiveHost, keepSel=sel.innerHTML, keepDis=go.disabled, calls=[];
     try{
       window.fetch=function(u){ calls.push(String(u)); return new Promise(function(){}); };
       buildArchiveHost=function(){ return false; };
       initBuildPicker();
       var asked=calls.filter(function(u){ return u.indexOf('index.json')>=0; }).length;
       if(asked) bad.push('off his machine the build picker still requested the archive '+asked+' time(s)');
       if(!go.disabled) bad.push('off his machine the build picker left its open button live with no archive to open');
       calls.length=0;
       buildArchiveHost=function(){ return true; };
       initBuildPicker();
       if(!calls.filter(function(u){ return u.indexOf('index.json')>=0; }).length) bad.push('control: on his machine the build picker no longer requests the archive');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ window.fetch=keepF; }catch(_f){}
       try{ buildArchiveHost=keepH; }catch(_h){}
       try{ sel.innerHTML=keepSel; go.disabled=keepDis; }catch(_s){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
