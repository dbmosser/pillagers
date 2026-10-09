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

if ($s.Contains("  {v:'21.59',what:")) { throw "check 21.59 is in the fixture already" }

SubRx @'
  {v:'21.58',what:
'@ @'
  {v:'21.59',what:'the attract clip says PRESS ANY BUTTON with a controller in use and PRESS ANY KEY without',
   run:function(){
     if(typeof attShow!=='function'||typeof attStop!=='function'||typeof PAD!=='object') return 'SKIP: no attract mode here';
     var bad=[], on0=PAD.on, d, t;
     try{
       PAD.on=true; attShow('data:video/mp4;base64,AAAA'); d=document.getElementById('attract'); t=d?d.textContent:'';
       if(!/PRESS ANY BUTTON/.test(t)) bad.push('with a controller it reads '+JSON.stringify(t));
       attStop(); PAD.on=false; attShow('data:video/mp4;base64,AAAA'); t=d?d.textContent:'';
       if(!/PRESS ANY KEY/.test(t)) bad.push('without a controller it reads '+JSON.stringify(t));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ attStop(); }catch(_s){} PAD.on=on0; }
     return bad.length?bad.join('; '):null; }},
  {v:'21.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
