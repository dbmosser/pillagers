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

if ($s.Contains("  {v:'27.50',what:")) { throw "check 27.50 is in the fixture already" }

SubRx @'
  {v:'27.49',what:
'@ @'
  {v:'27.50',what:'his answer: the alert headline is the L size, the plate drops in as it fades in, and a time bar along its foot runs down with the alert life',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame||!window.__textTrace||typeof alertDraw!=='function') return 'SKIP: no raid here';
     var bad=[], g, a, tr, i, ref, hd, zm, thin=[], oFR=ctx.fillRect, full, half, mx;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={};
       g.alert=null; g.alertQ=[]; say('SIEGE INCOMING','warn',{sub:'6 MACHINES'});
       a=g.alert; if(!a) return 'SKIP: the alert did not take the lane';
       if(!(a.T0>0)||Math.abs(a.T0-a.T)>0.01) bad.push('the alert has no life to draw its time bar from (T0 '+a.T0+')');
       a.at=(g.t||0)-1;
       zm=(HUDZ.msg||1)*hudRes()*hudUserZ('msg');
       tr=__textTrace(function(){ ctx.save(); ctx.font=FS(TYPE.head); ctx.fillStyle='#fff'; ctx.textAlign='left'; ctx.fillText('REFHEAD',2,2); ctx.restore(); __frame(0.016); });
       ref=tr.filter(function(t){ return t.t==='REFHEAD'; })[0];
       hd=tr.filter(function(t){ return t.t==='SIEGE INCOMING'; })[0];
       if(!ref||!hd) return 'SKIP: the alert headline was not traced';
       i=(hd.px/ref.px)/zm;
       if(i<1.2||i>1.5) bad.push('the alert headline is '+i.toFixed(2)+' of the old head size, not the L step (about 1.33)');
       // the time bar: thin plate wide rects drawn under the headline, full and then at half life
       function bar(T){ a=g.alert; a.T=T; thin.length=0; ctx.fillRect=function(x,y,w,h){ if(h>0&&h<=6&&w>20&&y>=LH(90)&&y<=LH(96)+300) thin.push({w:w}); return oFR.apply(this,arguments); }; try{ __frame(0.016); } finally { delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; } var best=0, k; for(k=0;k<thin.length;k++) best=Math.max(best,thin[k].w); return best; }
       full=bar(a.T0); half=bar(a.T0/2);
       if(!(full>0)) bad.push('no time bar is drawn along the foot of the plate');
       else if(!(half>0.3*full&&half<0.7*full)) bad.push('the time bar at half life is '+Math.round(half)+' wide against '+Math.round(full)+' at full life');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; }catch(_f){} try{ var g2=__state(); if(g2){ g2.alert=null; g2.alertQ=[]; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
