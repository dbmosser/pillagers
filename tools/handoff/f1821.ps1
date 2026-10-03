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

if ($s.Contains("  {v:'18.21',what:")) { throw "check 18.21 is in the fixture already" }

SubRx @'
  {v:'18.20',what:
'@ @'
  {v:'18.21',what:'the offer line and the boss bar reach the screen: in a drawn raid frame with an offer waiting, the HUD canvas is painted where the offer line sits (it was wiped by the clear that follows every HUD frame), and with THE OVERSEER beside him the boss bar is painted too',
   run:function(){
     if(typeof drawGiftLine!=='function'||typeof drawBossBar!=='function') return 'SKIP: no offer line or boss bar here';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, p, i, e=null, keep={on:NET.on,roster:NET.roster}, seq=0, cl=-1, gl=-1, bl=-1, oCR=ctx.clearRect, oFT=ctx.fillText;
     // ORDER, not pixels: the message line and the extract label share that part of the screen, so a pixel proves nothing. The
     // offer line and the boss name must be painted AFTER the full-canvas clear of the HUD frame. Own-property wraps, deleted after.
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false;
       NET.on=true; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}];
       g.giftIn={id:'z1',k:'bandage',from:1,t:g.t};
       for(i=0;i<g.ents.length;i++){ if(g.ents[i]&&g.ents[i].name===BOSS_NAME&&g.ents[i].hp>0){ e=g.ents[i]; break; } }
       if(e){ e.x=p.x+120; e.y=p.y; g.bossRef=e; }
       __frame(0.016);
       ctx.clearRect=function(x,y,w,h){ seq++; if(w>=W-1&&h>=H-1) cl=seq; return oCR.apply(this,arguments); };
       ctx.fillText=function(s){ seq++; if(/offers you/.test(String(s))) gl=seq; if(e&&String(s)===String(e.name)) bl=seq; return oFT.apply(this,arguments); };
       __frame(0.016);
       delete ctx.clearRect; if(ctx.clearRect!==oCR) ctx.clearRect=oCR; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT;
       if(cl<0) bad.push('control: no full-canvas HUD clear was seen');
       if(gl<0) bad.push('the offer line was not drawn at all'); else if(gl<cl) bad.push('the offer line is painted before the HUD clear that wipes it');
       if(e){ if(bl<0) bad.push('the boss bar was not drawn at all'); else if(bl<cl) bad.push('the boss bar is painted before the HUD clear that wipes it'); }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ delete ctx.clearRect; if(ctx.clearRect!==oCR) ctx.clearRect=oCR; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }catch(_w){} NET.on=keep.on; NET.roster=keep.roster; keys={}; try{ var g2=__state(); if(g2){ g2.giftIn=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
