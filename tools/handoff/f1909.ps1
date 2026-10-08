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

if ($s.Contains("  {v:'19.09',what:")) { throw "check 19.09 is in the fixture already" }

SubRx @'
  {v:'19.08',what:
'@ @'
  {v:'19.09',what:'the FASHION piece previews show the piece even with an outfit on: with an outfit worn, two hairstyles and two hats still give different pictures, and the outfit is still worn after',
   run:function(){
     if(typeof cosPreviewURL!=='function'||typeof COSMETICS==='undefined'||typeof OUTFITS==='undefined') return 'SKIP: no rack previews here';
     var bad=[], ow0=cosOwned, k=COSKEY.outfit, o0=P[k], oid=Object.keys(OUTFITS).filter(function(i){ return i!=='outnone'; })[0], cuts, hats, a, b;
     if(!oid) return 'SKIP: no outfit to wear';
     cuts=COSMETICS.filter(function(c){ return c&&c.kind==='cut'; }); hats=COSMETICS.filter(function(c){ return c&&c.kind==='hat'; });
     if(cuts.length<2) return 'SKIP: fewer than two hairstyles';
     try{
       cosOwned=function(c){ return true; }; P[k]=oid;
       for(var q in COSPREV) delete COSPREV[q];
       a=cosPreviewURL('cut',cuts[0].id); b=cosPreviewURL('cut',cuts[1].id);
       if(a&&b&&a===b) bad.push('with an outfit on, two hairstyles show the same picture');
       if(hats.length>=2){ a=cosPreviewURL('hat',hats[0].id); b=cosPreviewURL('hat',hats[1].id); if(a&&b&&a===b) bad.push('with an outfit on, two hats show the same picture'); }
       if(P[k]!==oid) bad.push('drawing the previews took the outfit off');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ cosOwned=ow0; if(o0===undefined) delete P[k]; else P[k]=o0; for(var q2 in COSPREV) delete COSPREV[q2]; }
     return bad.length?bad.join('; '):null; }},
  {v:'19.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
