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

if ($s.Contains("  {v:'30.20',what:")) { throw "check 30.20 is in the fixture already" }

SubRx @'
  {v:'30.19',what:
'@ @'
  {v:'30.20',what:'the attract backdrop blurs the world by 16px (the 16px spacing token): at 8px the hub labels read through the card scrim as ghost words (critic on v30.18: 56 back to 2; screens 46 52 55 56 64)',
   run:function(){
     if(typeof attEl!=='function') return 'SKIP: no attract here';
     var d, wasDisp, bf, m, res=null;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       bf=String(getComputedStyle(d).backdropFilter||getComputedStyle(d).webkitBackdropFilter);
       m=/blur\(([0-9.]+)px\)/.exec(bf);
       if(!m) return 'the attract backdrop does not blur the world';
       if(parseFloat(m[1])<15) res='the backdrop blur is '+m[1]+'px, under the 16px token';
       return res;
     } finally { try{ d.style.display=wasDisp; }catch(_f){} }
   }},
  {v:'30.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
