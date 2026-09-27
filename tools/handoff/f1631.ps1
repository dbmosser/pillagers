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

if ($s.Contains("  {v:'16.31',what:")) { throw "check 16.31 is in the fixture already" }

SubRx @'
  {v:'16.30',what:
'@ @'
  {v:'16.31',what:'check 15.24 follows his newer note: the clock warning is distinct by its three rising sweeps and quieter than the old .12',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("v16.31: the warning keeps its own rising shape")<0) return 'this build does not carry the v16.31 note';
     if(src.indexOf("for(var cwi=0;cwi<3;cwi++)")<0) return 'the clock warning lost its three sweeps';
     return null; }},
  {v:'16.30',what:
'@


SubRx @'
       else if(!(cw>=al*1.5)) bad.push('the clock siren starts at '+cw+', not clearly louder than the machine alarm at '+al);
'@ @'
       else if(!(cw>0&&cw<0.12)) bad.push('the clock siren starts at '+cw+', not the quieter level of his v16.30 note (under the old 0.12)');   // v16.31: distinct by its rising sweeps, no longer by loudness
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
