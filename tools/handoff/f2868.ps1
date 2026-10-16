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

if ($s.Contains("  {v:'28.68',what:")) { throw "check 28.68 is in the fixture already" }

SubRx @'
  {v:'28.67',what:
'@ @'
  {v:'28.68',what:'his order 2026-10-15 (crawlers too fast): a crawler moves at 120 units a second, a fifth under the old 150, and chases a runner more slowly than before',
   run:function(){
     if(typeof mkCrawler!=='function'||typeof navSeek!=='function') return 'SKIP: no crawler here';
     var bad=[], c, c2;
     try{
       c=mkCrawler(0,0);
       if(!c||c.kind!=='crawler') return 'SKIP: mkCrawler made no crawler';
       if(c.spd>125||c.spd<115) bad.push('a crawler moves at '+c.spd+' a second, not the 120 (a fifth under 150)');
       c2=mkCrawler(50,50);
       if(c2.spd!==c.spd) bad.push('two crawlers have different base speeds ('+c.spd+' and '+c2.spd+')');
       if(c.dmg!==13||c.rng!==26) bad.push('the crawler bite or reach moved (dmg '+c.dmg+', reach '+c.rng+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     return bad.length?bad.join('; '):null; }},
  {v:'28.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
