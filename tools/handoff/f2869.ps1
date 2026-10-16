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

if ($s.Contains("  {v:'28.69',what:")) { throw "check 28.69 is in the fixture already" }

SubRx @'
  {v:'28.68',what:
'@ @'
  {v:'28.69',what:'his order 2026-10-15 (liquor too intense): the Liquor screen effect strength is half of what it was, one dose draws the warp at about 0.96 where it drew 1.93',
   run:function(){
     if(typeof drawBuzzFx!=='function'||typeof buzzWarp!=='function'||typeof BUZZT==='undefined') return 'SKIP: no Liquor effects here';
     if(typeof __vpAlive==='function'&&!__vpAlive()) return 'SKIP: the pane has no layout, nothing is drawn';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim raid is loaded and draws no buzz';
     var bad=[], P2=__P(), keepBuzz=P2.buzz, keepT=BUZZT, oW=buzzWarp, seen=[];
     try{
       if(window.__pinDPR) __pinDPR(1);
       if(window.__forceSize) __forceSize(1920,1080);
       P2.buzz=[{id:'liquor',tag:'drunk',t:90,dur:180}];
       BUZZT=7.5;
       buzzWarp=function(c2,cnv,t,dr){ seen.push(+dr); };
       drawBuzzFx();
       if(!seen.length) return 'SKIP: the Liquor effect drew no warp';
       if(!(seen[0]>0.5)) bad.push('one Liquor dose draws the world warp at '+seen[0]+', which is no effect at all');
       if(seen[0]>1.2) bad.push('one Liquor dose draws the world warp at '+seen[0].toFixed(2)+', not the halved 0.96 (it was 1.93)');
       seen.length=0;
       P2.buzz=[{id:'liquor',tag:'drunk',t:90,dur:180},{id:'liquor',tag:'drunk',t:90,dur:180},{id:'liquor',tag:'drunk',t:90,dur:180},{id:'liquor',tag:'drunk',t:90,dur:180}];
       drawBuzzFx();
       if(seen.length&&seen[0]>4.3) bad.push('a stack of Liquor draws the warp at '+seen[0].toFixed(2)+', past the halved ceiling of 4.25');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ buzzWarp=oW; P2.buzz=keepBuzz||[]; BUZZT=keepT; }
     return bad.length?bad.join('; '):null; }},
  {v:'28.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
