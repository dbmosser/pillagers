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

if ($s.Contains("  {v:'19.49',what:")) { throw "check 19.49 is in the fixture already" }

SubRx @'
  {v:'19.48',what:
'@ @'
  {v:'19.49',what:'trying on an outfit keeps the FASHION previews: after a hat preview is painted, wearing a different outfit and asking for the same hat repaints nothing',
   run:function(){
     if(typeof cosPreviewURL!=='function'||typeof COSKEY==='undefined'||typeof OUTFITS==='undefined') return 'SKIP: no previews here';
     var bad=[], ok=COSKEY.outfit, o0=P[ok], ow0=cosOwned, hats=COSMETICS.filter(function(c){ return c&&c.kind==='hat'; }), outs=Object.keys(OUTFITS).filter(function(k){ return k!=='outnone'; }), proto=HTMLCanvasElement.prototype, oTD=proto.toDataURL, n=0;
     if(!hats.length||outs.length<2) return 'SKIP: too few hats or outfits';
     try{
       cosOwned=function(){ return true; };
       P[ok]=outs[0]; cosPreviewURL('hat',hats[0].id);
       proto.toDataURL=function(){ n++; return oTD.apply(this,arguments); };
       P[ok]=outs[1]; cosPreviewURL('hat',hats[0].id);
       if(n>0) bad.push('wearing a different outfit repainted the hat preview ('+n+' pictures)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.toDataURL=oTD; cosOwned=ow0; if(o0===undefined) delete P[ok]; else P[ok]=o0; }
     return bad.length?bad.join('; '):null; }},
  {v:'19.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
