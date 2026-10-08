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

if ($s.Contains("  {v:'19.58',what:")) { throw "check 19.58 is in the fixture already" }

SubRx @'
  {v:'19.57',what:
'@ @'
  {v:'19.58',what:'the kill feed keeps its place under a low CONDITIONS panel: with the panel dragged below the middle, the feed stays at its usual height and does not print over the panel',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof netFeedDraw!=='function') return 'SKIP: no kill feed here';
     var bad=[], g, NK={}, k, oFT=ctx.fillText, line=null, oC=HUDBOX.cond, fp=0, d=(typeof DPR==='number'&&DPR>0)?DPR:1;
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=false;
       NET.on=true; NET.feed=[{txt:'ZQ killed a sentry',at:Date.now(),me:0}];
       HUDBOX.cond={x:Math.round(W*0.78),y:Math.round(H*0.62),w:Math.round(W*0.2),h:Math.round(H*0.12)};
       ctx.fillText=function(s,x,y){ var m=ctx.getTransform(), fm=(/([\d.]+)px/).exec(String(ctx.font)); if(String(s)==='ZQ killed a sentry'&&!line){ line={y:(m.b*x+m.d*y+m.f)/d}; fp=(fm?parseFloat(fm[1]):12)*m.d/d; } return oFT.apply(this,arguments); };
       ctx.save(); try{ netFeedDraw(); } finally { ctx.restore(); }
       if(!line) return 'SKIP: the feed line was not drawn';
       if(line.y>H*0.55) bad.push('the feed was pulled down to y '+Math.round(line.y)+' by a panel that sits below it');
       if(line.y+fp*0.3>HUDBOX.cond.y&&line.y-fp<HUDBOX.cond.y+HUDBOX.cond.h) bad.push('the feed prints over the CONDITIONS panel');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; HUDBOX.cond=oC; for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
