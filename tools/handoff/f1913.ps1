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

if ($s.Contains("  {v:'19.13',what:")) { throw "check 19.13 is in the fixture already" }

SubRx @'
  {v:'19.12',what:
'@ @'
  {v:'19.13',what:'the FASHION preview caches keep one look: previewing pieces under three different looks leaves only the last look pictures stored',
   run:function(){
     if(typeof cosPreviewURL!=='function'||typeof COSMETICS==='undefined') return 'SKIP: no rack previews here';
     var bad=[], ow0=cosOwned, ks=COSKEY.skin, s0=P[ks], skins=COSMETICS.filter(function(c){ return c&&c.kind==='skin'; }), faces=COSMETICS.filter(function(c){ return c&&c.kind==='face'; }), i, j, n;
     if(skins.length<3||faces.length<3) return 'SKIP: too few skins or faces';
     try{
       cosOwned=function(c){ return true; };
       for(i=0;i<3;i++){ P[ks]=skins[i].id; for(j=0;j<3;j++) cosPreviewURL('face',faces[j].id); }
       n=Object.keys(COSPREV).filter(function(q){ return q.indexOf('face:')===0; }).length;
       if(n>3) bad.push(n+' face pictures are kept after three looks; only the current look 3 should be');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ cosOwned=ow0; if(s0===undefined) delete P[ks]; else P[ks]=s0; }
     return bad.length?bad.join('; '):null; }},
  {v:'19.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
