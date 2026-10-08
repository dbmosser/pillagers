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

if ($s.Contains("  {v:'18.82',what:")) { throw "check 18.82 is in the fixture already" }

SubRx @'
  {v:'18.81',what:
'@ @'
  {v:'18.82',what:'the other racks show the look: a fit, face, tattoo, hat, beard or hairstyle tile is a painted preview of the operator with that piece on, two pieces give two pictures, and the worn look and ownership are untouched after',
   run:function(){
     if(typeof cosSwatch!=='function'||typeof COSMETICS==='undefined'&&typeof cosFind!=='function') return 'SKIP: no cosmetics here';
     var bad=[], kinds=['fit','face','tattoo','hat','beard','cut'], all=(typeof COSMETICS!=='undefined')?COSMETICS:null, ow0=cosOwned, keep={};
     if(!all) return 'SKIP: no cosmetics list to read';
     kinds.forEach(function(kd){ keep[kd]=P[COSKEY[kd]]; });
     kinds.forEach(function(kd){
       var ids=all.filter(function(c){ return c&&c.kind===kd; }).map(function(c){ return c.id; }), a, b;
       if(ids.length<2) return;
       var pics=ids.map(function(id){ return String(cosSwatch({kind:kd,id:id,name:id})); }), uniq={}; pics.forEach(function(s){ uniq[s]=1; });
       if(pics[0].indexOf('<img')<0||pics[0].indexOf('data:image/png')<0) bad.push('a '+kd+' tile is still a placeholder');
       else if(Object.keys(uniq).length<2) bad.push('every '+kd+' tile shows the same picture');
       if(P[COSKEY[kd]]!==keep[kd]) bad.push('drawing the '+kd+' previews changed what is worn');
     });
     if(cosOwned!==ow0) bad.push('the ownership test was left replaced');
     return bad.length?bad.join('; '):null; }},
  {v:'18.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
