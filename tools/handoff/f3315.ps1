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

if ($s.Contains("  {v:'33.15',what:")) { throw "check 33.15 is in the fixture already" }

SubRx @'
  {v:'33.14',what:
'@ @'
  {v:'33.15',what:'cw-handclear, the o-02 alarm (10-20): with an item in hand the compact controls list and the item-in-hand panel never overlap, at 1080p and 4K, in a career raid and in the demo',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__forceSize&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof handPlateBox!=='function'||typeof drawLegend!=='function'||typeof HUDBOX!=='object') return 'SKIP: no hand panel or controls list here';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], sw=cv.style.width, sh=cv.style.height, hw=hcv.style.width, hh=hcv.style.height, sizes=[[1920,1080],[3840,2160]], n=0;
     function hit(a,b){ return !!a&&!!b&&a.x<b.x+b.w&&a.x+a.w>b.x&&a.y<b.y+b.h&&a.y+a.h>b.y; }
     function scene(tag){
       var si, i, g, p, hb, lb, t;
       for(si=0;si<sizes.length;si++){
         __forceSize(sizes[si][0],sizes[si][1]); t=tag+' '+sizes[si][0]+'x'+sizes[si][1]+': ';
         g=__state(); if(!g||g.over||!g.player){ bad.push(t+'staging: no live raid'); return; }
         p=g.player; keys={};
         for(i=0;i<5;i++){ g.bagOpen=false; g.mapOpen=false; g.wheel=null; g.legendOn=1; p.hand={k:'bandage',t:0.4,len:1.2}; __frame(0.016); }
         hb=handPlateBox(); lb=HUDBOX.legend;
         if(!hb){ bad.push(t+'staging: no item-in-hand panel'); continue; }
         if(!lb){ bad.push(t+'staging: no controls list drawn'); continue; }
         n++;
         if(hit(lb,hb)) bad.push(t+'the controls list (x '+Math.round(lb.x)+' to '+Math.round(lb.x+lb.w)+', y '+Math.round(lb.y)+' to '+Math.round(lb.y+lb.h)+') covers the item-in-hand panel (x '+hb.x+' to '+(hb.x+hb.w)+', y '+hb.y+' to '+(hb.y+hb.h)+')');
         p.hand=null; g.legendOn=1; for(i=0;i<3;i++) __frame(0.016);
         lb=HUDBOX.legend;
         if(lb&&HUDBOX.body&&Math.abs((lb.y+lb.h)-(HUDBOX.body.y-LH(8)))>LH(4)+2) bad.push(t+'with the item put away the list does not stand back on the vitals (bottom '+Math.round(lb.y+lb.h)+', vitals top '+Math.round(HUDBOX.body.y)+')');
       }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       scene('career');
       __endRaid('abandon'); __topClear();
       if(typeof arcadeDeploy==='function'&&typeof ARCADE==='object'&&ARCADE){
         if(arcadeDeploy({mapIx:0,seed:4242})){ ARCADE.holdT=0; scene('the demo'); }
         else bad.push('staging: arcadeDeploy built no demo raid');
       }
       if(!n) return 'SKIP: no scene drew both the list and the panel';
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ var gq=__state(); if(gq&&gq.player) gq.player.hand=null; }catch(_h){}
       try{ if(typeof ARCADE==='object'&&ARCADE){ ARCADE.team=null; ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'&&ARCADE){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_a){}
       try{ cv.style.width=sw; cv.style.height=sh; hcv.style.width=hw; hcv.style.height=hh; resize(); }catch(_z){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
