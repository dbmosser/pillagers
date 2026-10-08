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

if ($s.Contains("  {v:'19.40',what:")) { throw "check 19.40 is in the fixture already" }

SubRx @'
  {v:'19.39',what:
'@ @'
  {v:'19.40',what:'the rewards XP count can be read: the count over the bar is light text with a dark edge, readable on the empty track and on the amber fill',
   run:function(){
     var el=document.getElementById('seasontext'), bad=[], s, m, lum;
     if(!el) return 'SKIP: no rewards bar here';
     s=getComputedStyle(el); m=(/rgba?\((\d+),\s*(\d+),\s*(\d+)/).exec(s.color||'');
     if(!m) return 'SKIP: the count has no readable colour';
     lum=(0.2126*m[1]+0.7152*m[2]+0.0722*m[3])/255;
     if(lum<0.5) bad.push('the count is dark ('+s.color+') over a bar that is nearly always empty and dark');
     if(!s.textShadow||s.textShadow==='none') bad.push('the count has no dark edge to read over the amber fill');
     return bad.length?bad.join('; '):null; }},
  {v:'19.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
