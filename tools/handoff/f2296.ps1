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

if ($s.Contains("  {v:'22.96',what:")) { throw "check 22.96 is in the fixture already" }

SubRx @'
  {v:'22.95',what:
'@ @'
  {v:'22.96',what:'world text draws over the dark and the fog: on a night raid, in one drawn frame, a loot label beside him and the nameplate of a Sentry in view are filled after the fog of war sheet is laid over the world',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof render2D!=='function'||typeof label!=='function'||typeof fogC==='undefined'||!fogC||typeof mkSentry!=='function'||typeof canSee!=='function') return 'SKIP: no world draw, labels or fog of war sheet here';
     var bad=[], g=null, p=null, OWN=Object.prototype.hasOwnProperty, ownD=OWN.call(wc,'drawImage'), ownF=OWN.call(wc,'fillText'), oD=wc.drawImage, oF=wc.fillText, n=0, LB='ZQX '+'LOOT LABEL', s=null, k, ok=false, fog=-1, lab=-1, nmI=-1, nm='';
     function unspy(){ if(ownD) wc.drawImage=oD; else delete wc.drawImage; if(ownF) wc.fillText=oF; else delete wc.fillText; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.bagOpen=false; g.mapOpen=false; p.iv=99;
       P.cond='night';
       if(isDay()) return 'SKIP: staging: the raid would not go dark';
       if(typeof refreshVseg==='function') refreshVseg();
       var OFS=[[0,-110],[0,110],[110,0],[-110,0],[0,-70],[0,70],[70,0],[-70,0]];
       for(k=0;k<OFS.length&&!ok;k++){ var ax=p.x+OFS[k][0], ay=p.y+OFS[k][1]; p.face=Math.atan2(OFS[k][1],OFS[k][0]); if(canSee(p.x,p.y,p.face,ax,ay,g.vseg)){ ok=true; s=mkSentry(ax,ay); } }
       g.ents.length=0; if(s){ s.state='patrol'; g.ents.push(s); nm=String(s.name||''); }
       g.labels.length=0; label(p.x,p.y-20,LB,'#ffc04a',0,true);
       render2D(0);
       wc.drawImage=function(img){ if(img===fogC&&fog<0) fog=n; n++; return oD.apply(this,arguments); };
       wc.fillText=function(t){ var q=String(t); if(q===LB&&lab<0) lab=n; if(nm&&q.indexOf(nm)===0&&nmI<0) nmI=n; n++; return oF.apply(this,arguments); };
       try{ render2D(0); } finally { unspy(); }
       if(fog<0) return 'SKIP: the drawn frame laid no fog of war sheet here';
       if(lab<0) return 'SKIP: staging: the loot label was not drawn';
       if(lab<fog) bad.push('on a night raid the loot label was filled before the fog of war sheet was laid over it');
       if(s&&VIS.indexOf(s)>=0&&nmI>=0&&nmI<fog) bad.push('on a night raid the Sentry nameplate was filled before the fog of war sheet was laid over it');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); keys={};
       try{ var g2=__state(); if(g2){ g2.labels.length=0; g2.ents.length=0; if(!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
