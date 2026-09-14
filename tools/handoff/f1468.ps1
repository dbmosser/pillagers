$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.67',what:
'@ @'
  {v:'14.68',what:'a hat marked his alone is never on a pillager: across 600 pillager looks no hat marked crowd:0 appears, while several other hats do (wardrobe audit finding 5)',
   run:function(){
     if(typeof raiderLook!=='function'||typeof COSMETICS==='undefined') return 'SKIP: no pillager looks in this build';
     var his=COSMETICS.filter(function(c){ return c.kind==='hat'&&c.crowd===0; }).map(function(c){ return c.id; });
     if(!his.length) return 'SKIP: no hat is marked his alone in this build';
     var seen={}, bad=[], worn=0;
     for(var i=0;i<600;i++){
       var L=raiderLook('zqx'+i,(i*37)%3000,(i*53)%3000);
       if(L&&L.hat){ seen[L.hat]=(seen[L.hat]||0)+1; if(his.indexOf(L.hat)>=0) worn++; }
     }
     // CONTROL: pillagers wear a spread of hats, so the pick is running.
     var kinds=Object.keys(seen).filter(function(h){ return h!=='none'; });
     if(kinds.length<3) return 'SKIP: 600 pillager looks drew only '+kinds.length+' hats, so the pick is not varied here';
     if(worn) bad.push(worn+' of 600 pillagers wore a hat ruled his alone ('+his.filter(function(h){ return seen[h]; }).join(', ')+')');
     return bad.length?bad.join('; '):null; }},
  {v:'14.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
