$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
# v10.54, second part. The full corpus caught it: a random look now drew from
# the OUTFIT rack too, and with seven suits to one Own Clothes it put a suit on
# seven times in eight, hiding the hat, the jersey and the boots it had just
# rolled. A random look leaves the outfit rack alone; a saved look still
# carries it.
SubRx @'
  for(var i=0;i<LOOK_KINDS.length;i++){
    var k=LOOK_KINDS[i], pool=COSMETICS.filter(function(c){ return c.kind===k&&cosOwned(c); });
    if(pool.length) P[COSKEY[k]]=pool[Math.floor(Math.random()*pool.length)].id;
  }
'@ @'
  for(var i=0;i<LOOK_KINDS.length;i++){
    var k=LOOK_KINDS[i];
    if(k==='outfit') continue;   // v10.54: a random look never puts a suit on over what it rolled
    var pool=COSMETICS.filter(function(c){ return c.kind===k&&cosOwned(c); });
    if(pool.length) P[COSKEY[k]]=pool[Math.floor(Math.random()*pool.length)].id;
  }
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
