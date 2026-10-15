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

if ($s.Contains("  {v:'27.30',what:")) { throw "check 27.30 is in the fixture already" }

SubRx @'
  {v:'27.29',what:
'@ @'
  {v:'27.30',what:'his playtest answer on the elites, tint and/or outline: an elite machine with an affix is drawn through the outline pass, once a frame and in its own colour, a plain machine is not, and a throw while the body is drawn puts the world canvas and the ground shadow back',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof render2D!=='function'||typeof mkSentry!=='function'||typeof affixApply!=='function'||typeof spotFree!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, e, i, k, aa=0, sx=0, sy=0, ks=['shield','boom','fast','mend'], cols=[[79,214,255],[255,138,60],[242,232,74],[92,255,138]], n0, id, d, hit, wc0=null, sh0=null, oS=null;
     function inW(x,y){ return x>60&&y>60&&x<WORLD_W-60&&y<WORLD_H-60; }
     try{
       if(typeof RIM==='undefined'||typeof rimOpen!=='function') return 'an elite machine has no outline pass';
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100000; p.downed=false; all=g.ents.slice();
       for(k=0;k<24;k++){ aa=k/24*6.2832; sx=p.x+Math.cos(aa)*120; sy=p.y+Math.sin(aa)*120; if(inW(sx,sy)&&spotFree(g.map,sx,sy,30)&&losClear(p.x,p.y,sx,sy,G.vseg)) break; }
       if(k>=24) return 'SKIP: no open ground beside the player';
       p.face=Math.atan2(sy-p.y,sx-p.x);
       wc0=wc; sh0=shadowE;
       for(i=0;i<4;i++){
         e=mkSentry(sx,sy); e.elite=1; e.hp=e.maxhp; e.state='patrol'; e.alert=0; e.affix=null; affixApply(e,i); g.ents=[e];
         n0=RIM.n; render2D(0.016);
         if(RIM.n!==n0+1) bad.push('an elite '+ks[i]+' machine in view was drawn through the outline pass '+(RIM.n-n0)+' times, not once');
         id=RIM.xb.getImageData(0,0,RIM.cb.width,RIM.cb.height).data; hit=0;
         for(d=0;d<id.length;d+=4) if(id[d+3]>=170&&Math.abs(id[d]-cols[i][0])<30&&Math.abs(id[d+1]-cols[i][1])<30&&Math.abs(id[d+2]-cols[i][2])<30) hit++;
         if(hit<60) bad.push('the '+ks[i]+' outline holds only '+hit+' pixels of its colour');
       }
       e=mkSentry(sx,sy); e.elite=0; e.affix=null; e.state='patrol'; e.alert=0; g.ents=[e]; n0=RIM.n; render2D(0.016);
       if(RIM.n!==n0) bad.push('a plain machine was drawn through the outline pass');
       e=mkSentry(sx,sy); e.elite=1; e.hp=e.maxhp; e.state='patrol'; e.alert=0; e.affix=null; affixApply(e,0); g.ents=[e];
       oS=drawSentryS; drawSentryS=function(){ throw new Error('aip1 probe'); };
       try{ render2D(0.016); } finally { drawSentryS=oS; }
       g.drawErr=null; if(g.tel) g.tel.drawErr=null;
       if(wc!==wc0) bad.push('after a throw in the body draw the world canvas is not back');
       if(shadowE!==sh0) bad.push('after a throw in the body draw the ground shadow is not back');
       if(RIM.on) bad.push('the outline pass is left open after a throw');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(oS) drawSentryS=oS; }catch(_e9){}
       try{ if(wc0) wc=wc0; if(sh0) shadowE=sh0; if(typeof RIM!=='undefined') RIM.on=0; }catch(_e0){}
       try{ if(g&&all) g.ents=all; if(g){ g.drawErr=null; if(g.tel) g.tel.drawErr=null; } var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
