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

if ($s.Contains("  {v:'22.14',what:")) { throw "check 22.14 is in the fixture already" }

SubRx @'
  {v:'22.13',what:
'@ @'
  {v:'22.14',what:'the emote strip (V) sits above the belt and its caption at this screen size, never over the belt keys, and a wind-up bar stays above the strip',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function'||typeof beltCapFS!=='function'||typeof LH!=='function'||typeof EMOTES==='undefined'||!EMOTES.length) return 'SKIP: no raid or HUD here';
     var bad=[], g, p=null, rects=[], hadR=Object.prototype.hasOwnProperty.call(ctx,'fillRect'), oFR=ctx.fillRect, pc=document.createElement('canvas').getContext('2d'), sCol, tCol, c, cap, capTop, strip, top, bot, i, eb0, pr0, tr0, ub, uw, ux, hr, ebw=LH(112), ebh=LH(30);
     pc.fillStyle='rgba(6,9,13,.90)'; sCol=String(pc.fillStyle); pc.fillStyle='rgba(255,255,255,.12)'; tCol=String(pc.fillStyle);
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; eb0=g.emoteBar; pr0=p.prep; tr0=g.trade;
       g.trade=null; g.bagOpen=false; g.mapOpen=false; g.emoteBar=true;
       p.prep={key:'bandage',kind:'med',t:0.4,max:1.5};
       try{ drawHUD(); }catch(_h0){}
       ctx.fillRect=function(x,y,w,h){ rects.push({x:x,y:y,w:w,h:h,fs:String(ctx.fillStyle)}); return oFR.apply(this,arguments); };
       try{ drawHUD(); }catch(_h1){}
       c=(g.hotCells&&g.hotCells.length)?g.hotCells[0]:null;
       if(!c) return 'SKIP: staging: no belt drawn';
       cap=parseFloat(((/([\d.]+)px/).exec(String(beltCapFS(c.w)))||[0,11])[1])||11;
       capTop=c.y-LH(6)-cap*0.95;
       strip=rects.filter(function(r){ return r.fs===sCol&&Math.abs(r.w-ebw)<1.5&&Math.abs(r.h-ebh)<1.5; });
       if(strip.length<EMOTES.length) return 'SKIP: staging: the emote strip was not drawn ('+strip.length+' boxes)';
       top=1e9; bot=-1e9; for(i=0;i<strip.length;i++){ top=Math.min(top,strip[i].y); bot=Math.max(bot,strip[i].y+strip[i].h); }
       if(bot>c.y+0.5) bad.push('the emote strip runs '+Math.round(bot-c.y)+' px down over the belt keys (strip '+Math.round(top)+' to '+Math.round(bot)+', keys from '+Math.round(c.y)+')');
       else if(bot>capTop+0.5) bad.push('the emote strip covers the belt caption (strip bottom '+Math.round(bot)+', caption from '+Math.round(capTop)+')');
       hr=(typeof hudRes==='function')?hudRes():1;
       uw=Math.round(Math.min(LH(300)*hr,W*0.34)); ux=Math.round(W/2-uw/2);
       ub=rects.filter(function(r){ return r.fs===tCol&&Math.abs(r.x-ux)<1.5&&Math.abs(r.w-uw)<1.5; })[0];
       if(ub&&ub.y+ub.h>top+0.5) bad.push('the bandage bar (bottom '+Math.round(ub.y+ub.h)+') runs into the emote strip (top '+Math.round(top)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(hadR) ctx.fillRect=oFR; else delete ctx.fillRect;
       try{ if(g){ g.emoteBar=eb0||false; g.trade=tr0||null; } if(p) p.prep=pr0; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
