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

if ($s.Contains("  {v:'23.76',what:")) { throw "check 23.76 is in the fixture already" }

SubRx @'
  {v:'23.75',what:
'@ @'
  {v:'23.76',what:'his #6: a strung Tripwire Mine is drawn as a red wire, the mine has a belt icon, and holding one says RELEASE TO SET',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof render2D!=='function'||typeof drawHUD!=='function'||typeof tripArm!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, OWN=Object.prototype.hasOwnProperty, NM=['moveTo','lineTo','stroke'], sv={}, seq=[], hud=[], oT=ctx.fillText, ownT=OWN.call(ctx,'fillText'), T, i, j, hit=false, cv2, ok;
     function unspy(){ for(var q=0;q<NM.length;q++){ if(sv[NM[q]].own) wc[NM[q]]=sv[NM[q]].f; else delete wc[NM[q]]; } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.bagOpen=false; g.mapOpen=false;
       g.trips=[];
       T=tripArm({sx:p.x,sy:p.y,tx:p.x+40,ty:p.y+30}); T.arm=0;
       for(i=0;i<NM.length;i++){ (function(nm){ sv[nm]={own:OWN.call(wc,nm),f:wc[nm]}; var of=wc[nm]; wc[nm]=function(){ seq.push({n:nm,a:[].slice.call(arguments),s:String(wc.strokeStyle)}); return of.apply(this,arguments); }; })(NM[i]); }
       try{ render2D(0); } finally { unspy(); }
       for(i=1;i<seq.length&&!hit;i++){
         if(seq[i].n!=='lineTo'||Math.abs(seq[i].a[0]-T.bx)>0.5||Math.abs(seq[i].a[1]-T.by)>0.5) continue;
         if(seq[i-1].n!=='moveTo'||Math.abs(seq[i-1].a[0]-T.ax)>0.5||Math.abs(seq[i-1].a[1]-T.ay)>0.5) continue;
         for(j=i+1;j<seq.length&&j<i+4;j++) if(seq[j].n==='stroke'&&(/255,\s*74,\s*74/).test(seq[j].s)) hit=true;
       }
       if(!hit) bad.push('render2D drew no red line from one end of the strung wire to the other');
       cv2=document.createElement('canvas'); cv2.width=cv2.height=64;
       ok=keyIcon(cv2.getContext('2d'),'trip',64,ITEMS.trip&&ITEMS.trip.c);
       if(ok!==true) bad.push('the Tripwire Mine has no icon of its own');
       g.trips=[]; g.pouch.trip=1; p.cooking=1; p.cookT=0.2; p.cookKind='trip';
       ctx.fillText=function(t){ hud.push(String(t)); return oT.apply(this,arguments); };
       try{ drawHUD(); } finally { if(ownT) ctx.fillText=oT; else delete ctx.fillText; }
       if(hud.join('|').indexOf('RELEASE TO '+'SET')<0) bad.push('holding a Tripwire Mine does not say RELEASE TO SET (drew: '+hud.slice(0,12).join(' / ')+')');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ if(OWN.call(ctx,'fillText')&&!ownT) delete ctx.fillText; }catch(_u){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.trips=[]; g2.player.cooking=0; g2.player.cookT=0; g2.player.cookKind=null; __endRaid('abandon'); } }catch(_e){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
