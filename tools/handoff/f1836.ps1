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

if ($s.Contains("  {v:'18.36',what:")) { throw "check 18.36 is in the fixture already" }

SubRx @'
  {v:'18.35',what:
'@ @'
  {v:'18.36',what:'ground shadows are stamps: with the sprites warm a raid frame issues under 70 ellipse calls (it issued about 165), and a stamped shadow is as dark at its middle as the live one',
   run:function(){
     if(typeof SHADSPR==='undefined') return 'the shadows are painted live every frame';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], P2=CanvasRenderingContext2D.prototype, real=P2.ellipse, n=0, g, i, e, d;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; g.mapOpen=false;
       for(i=0;i<3;i++) __frame(0.016);
       if(!SHADSPR.n) bad.push('no shadow was stamped');
       P2.ellipse=function(){ n++; return real.apply(this,arguments); };
       __frame(0.016);
       P2.ellipse=real;
       if(!(n<70)) bad.push('a warm frame still issues '+n+' ellipse calls');
       e=SHADSPR.m[Object.keys(SHADSPR.m)[0]];
       if(e){ d=e.c.getContext('2d').getImageData(Math.floor(e.c.width/2),Math.floor(e.c.height/2),1,1).data; if(d[3]<20) bad.push('a stamp is blank at its middle'); }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ P2.ellipse=real; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
