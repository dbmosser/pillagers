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

if ($s.Contains("  {v:'32.34',what:")) { throw "check 32.34 is in the fixture already" }

SubRx @'
  {v:'32.33',what:
'@ @'
  {v:'32.34',what:'the idle loop cycles through three variations of the piece in turn (his 2.70 c)',
   run:function(){
     var T, B, p0, leads=[], i, st, pass, adv, seen=[], bad=[], key, sorted;
     if(typeof musAdvance!=='function'||typeof musLeadAt!=='function') return 'the title piece has no variations (no musAdvance or musLeadAt)';
     T=THEME_TITLE; B=T.bars[0]; p0=MUS.pass;
     try{
       for(i=0;i<3;i++){ MUS.pass=i; leads.push(T.bars[0].lead.map(function(_x,si){ return musLeadAt(T,B,si); }).join(',')); }
       if(leads[0]===leads[1]||leads[1]===leads[2]||leads[0]===leads[2]) bad.push('the three passes play the same tune');
       sorted=leads.map(function(s){ return s.split(',').sort().join(','); });
       if(sorted[0]!==sorted[1]||sorted[1]!==sorted[2]) bad.push('a variation plays other notes than the piece');
       st=0; pass=0; seen.push(pass);
       for(i=0;i<T.bars.length*16*4;i++){ adv=musAdvance(st,T.bars.length*16,pass,T); st=adv.step; pass=adv.pass; if(st===0) seen.push(pass); }
       if(seen.join('')!=='01201') bad.push('the passes go '+seen.join('')+', not 0 1 2 0 1');
       MUS.pass=0; if(musLeadAt(T,B,0)!==74) bad.push('pass 0 is no longer the piece as written');
       return bad.length?bad.join('; '):null;
     } finally { MUS.pass=p0; } }},
  {v:'32.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
