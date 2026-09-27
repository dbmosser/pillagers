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

if ($s.Contains("  {v:'16.30',what:")) { throw "check 16.30 is in the fixture already" }

SubRx @'
  {v:'16.29',what:
'@ @'
  {v:'16.30',what:'quieter clock alarms and inbound: the clock warning plays a triangle tone at .04, the tick at .03, and the extraction banner says INBOUND',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     var bad=[];
     if(src.indexOf("cwg.gain.setValueAtTime(.04*vol,cwt)")<0) bad.push('the clock warning is not at .04');
     if(src.indexOf("ckg.gain.setValueAtTime(.03*vol,t)")<0) bad.push('the clock tick is not at .03');
     if(src.indexOf("' INBOUND  '")<0||src.indexOf("' INCOMING  '")>=0) bad.push('the extraction banner does not say INBOUND');
     return bad.length?bad.join('; '):null; }},
  {v:'16.29',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
