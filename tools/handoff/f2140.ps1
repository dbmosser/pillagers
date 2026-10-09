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

if ($s.Contains("  {v:'21.40',what:")) { throw "check 21.40 is in the fixture already" }

SubRx @'
  {v:'21.39',what:
'@ @'
  {v:'21.40',what:'the gun card fits its words and stays off the screen edge: its right edge lines up 8 pixels in, with the hidden chip above it, it starts no further left than the box the mouse moves it by, and every line on it is inside it',
   run:function(){
     if(typeof hudPanel!=='function') return 'SKIP: no HUD panel';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, oHP=hudPanel, oFT=ctx.fillText, seen=[], txt=[], d=(typeof DPR==='number'&&DPR>0)?DPR:1, br, GB, t, i, hud0=P.hud;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.hud={};   // the corner where it was built, not where a profile dragged it
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       keys={}; g.mapOpen=false; g.bagOpen=false;
       __frame(0.016);
       hudPanel=function(x,y,w,h,a){ var m=ctx.getTransform(); seen.push({x:(m.a*x+m.c*y+m.e)/d,y:(m.b*x+m.d*y+m.f)/d,w:w*m.a/d,h:h*m.d/d,a:a}); return oHP.apply(this,arguments); };   // screen space: the corner is drawn scaled
       ctx.fillText=function(s,x,y){ if(ctx.textAlign==='right'){ var m=ctx.getTransform(), w=CanvasRenderingContext2D.prototype.measureText.call(ctx,String(s)).width; txt.push({s:String(s),l:(m.a*(x-w)+m.e)/d,r:(m.a*x+m.e)/d,y:(m.d*y+m.f)/d}); } return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { hudPanel=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       br=seen.filter(function(r){ return r.a===0.62&&r.x+r.w>=W-40&&r.y>H*0.5; })[0];
       GB=HUDBOX.gear;
       if(!br||!GB) return 'SKIP: no gun card or no corner box was drawn';
       if(Math.abs((br.x+br.w)-(W-8))>2) bad.push('the gun card ends '+(W-(br.x+br.w)).toFixed(1)+' pixels from the screen edge, not 8 as the chip above it does');
       if(br.x<GB.x-2) bad.push('the gun card starts '+Math.round(GB.x-br.x)+' pixels left of its own box, '+Math.round(br.w)+' wide for its short lines');
       t=txt.filter(function(q){ return q.r>=br.x+br.w-60&&q.r<=W&&q.y>br.y&&q.y<br.y+br.h+4; });
       if(!t.length) bad.push('control: no line of the gun card was seen');
       for(i=0;i<t.length;i++) if(t[i].l<br.x+1||t[i].r>br.x+br.w) bad.push('control: the line '+t[i].s+' runs out of the gun card');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hudPanel=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} P.hud=hud0; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
