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

if ($s.Contains("  {v:'24.74',what:")) { throw "check 24.74 is in the fixture already" }

SubRx @'
  {v:'24.73',what:
'@ @'
  {v:'24.74',what:'his #35 and #50 (UI redesign ui5q1t): the HUD meters have a graphite ring (no periwinkle) and the belt keys are not filled navy',
   run:function(){
     if(typeof bar!=='function') return 'SKIP: no meter here';
     var bad=[], keep=ctx, oc=document.createElement('canvas'), c2, d, src;
     oc.width=200; oc.height=60; c2=oc.getContext('2d');
     try{ ctx=c2; bar(10,10,180,30,0.5,'#5fae6f'); }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ctx=keep; }
     d=c2.getImageData(150,10,1,1).data;
     if(d[3]>0&&d[2]-d[0]>25) bad.push('the meter ring is periwinkle (rgba '+[d[0],d[1],d[2],d[3]].join(',')+')');
     src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('');
     if(src.indexOf('rgba(28,36'+',64,.86)')>=0) bad.push('the belt keys are still filled navy');
     return bad.length?bad.join('; '):null; }},
  {v:'24.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
