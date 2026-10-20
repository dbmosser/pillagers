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

if ($s.Contains("  {v:'32.03',what:")) { throw "check 32.03 is in the fixture already" }

SubRx @'
  {v:'32.02',what:
'@ @'
  {v:'32.03',what:'the controls list is not drawn over the item wheel, and is back when the wheel closes',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawLegend!=='function') return 'SKIP: no legend here';
     var bad=[], g, n=0, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, lo0, w0, on0=(typeof REC==='object'&&REC)?REC.on:false;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       lo0=g.legendOn; w0=g.wheel; g.legendOn=1; g.bagOpen=false; g.wheel=null;
       if(typeof REC==='object'&&REC) REC.on=false;
       ctx.fillText=function(){ n++; return of.apply(this,arguments); };
       n=0; drawLegend(1);
       if(!n) return 'SKIP: staging: the controls list drew nothing';
       g.wheel={t:0,list:[],sel:-1,mx:W/2,my:H/2,ox:0,oy:0,armed:0,d:0};
       n=0; drawLegend(1);
       if(n) bad.push('with the item wheel open the controls list still drew '+n+' words');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(typeof REC==='object'&&REC) REC.on=on0; if(own) ctx.fillText=of; else delete ctx.fillText; try{ var g2=__state(); if(g2){ g2.legendOn=lo0; g2.wheel=w0||null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
