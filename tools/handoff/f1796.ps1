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

if ($s.Contains("  {v:'17.96',what:")) { throw "check 17.96 is in the fixture already" }

SubRx @'
  {v:'17.95',what:
'@ @'
  {v:'17.96',what:'the seal spawns at random: across 24 seeds the door lands in more than one place on the first sector, and the same seed lands it in the same place twice, so both windows of a pair agree',
   run:function(){
     if(!(window.__seal&&__seal.spot)||typeof FIXED_MAPS==='undefined'||typeof sideStream!=='function') return 'SKIP: no seal spot to roll here';
     var bad=[], def=FIXED_MAPS[0], map={}, spots={}, n=0, s, a=null, b=null, k;
     if(!def||!def.landmarks||def.landmarks.length<3) return 'SKIP: the first sector has under three landmarks';
     try{
       for(s=1;s<=24;s++){ sideStream(s*7919,4,function(){ a=__seal.spot(map,def); }); k=Math.round(a.x/200)+','+Math.round(a.y/200); if(!spots[k]){ spots[k]=1; n++; } }
       sideStream(4242,4,function(){ a=__seal.spot(map,def); }); sideStream(4242,4,function(){ b=__seal.spot(map,def); });
       if(!a||!b||a.x!==b.x||a.y!==b.y) bad.push('the same seed rolled two different doors');
       if(n<2) bad.push('24 seeds all put the seal in the same place');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'17.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
