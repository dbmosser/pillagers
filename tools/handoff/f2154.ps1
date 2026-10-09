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

if ($s.Contains("  {v:'21.54',what:")) { throw "check 21.54 is in the fixture already" }

SubRx @'
  {v:'21.53',what:
'@ @'
  {v:'21.54',what:'while F9 records, the controls list is not drawn, and it is back when the recording stops',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawLegend!=='function'||typeof REC!=='object') return 'SKIP: no legend or recorder here';
     var bad=[], g, n=0, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, on0=REC.on, lo0;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       lo0=g.legendOn; g.legendOn=1; g.bagOpen=false;
       ctx.fillText=function(){ n++; return of.apply(this,arguments); };
       REC.on=false; n=0; drawLegend(1);
       if(!n) return 'SKIP: staging: the controls list drew nothing';
       REC.on=true; n=0; drawLegend(1);
       if(n) bad.push('while recording the controls list still drew '+n+' words');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ REC.on=on0; if(own) ctx.fillText=of; else delete ctx.fillText; try{ var g2=__state(); if(g2){ g2.legendOn=lo0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
