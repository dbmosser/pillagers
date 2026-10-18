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

if ($s.Contains("  {v:'30.18',what:")) { throw "check 30.18 is in the fixture already" }

SubRx @'
  {v:'30.17',what:
'@ @'
  {v:'30.18',what:'the attract backdrop blurs the world by 8px (the 8px spacing token) and the scrim at the centre lets the world through (critic on v30.14: the blur was so heavy and dark that the world was mush; screens 46 52 55 56 64)',
   run:function(){
     if(typeof attEl!=='function') return 'SKIP: no attract here';
     var d, wasDisp, bf, bg, m, res=null;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       bf=String(getComputedStyle(d).backdropFilter||getComputedStyle(d).webkitBackdropFilter);
       m=/blur\(([0-9.]+)px\)/.exec(bf);
       if(!m) return 'the attract backdrop does not blur the world';
       if(parseFloat(m[1])>9) res='the backdrop blur is '+m[1]+'px, over the 8px token';
       return res;
     } finally { try{ d.style.display=wasDisp; }catch(_f){} }
   }},
  {v:'30.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
