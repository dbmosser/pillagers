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

if ($s.Contains("  {v:'22.98',what:")) { throw "check 22.98 is in the fixture already" }

SubRx @'
  {v:'22.97',what:
'@ @'
  {v:'22.98',what:'label plates fit their text: a big loot label is drawn on a plate at least 1.15 times its font size tall that covers its letters, and a second label pushed at the same spot stacks at least that far above it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof render2D!=='function'||typeof label!=='function') return 'SKIP: no world labels here';
     var bad=[], g=null, p=null, OWN=Object.prototype.hasOwnProperty, ownR=OWN.call(wc,'fillRect'), ownF=OWN.call(wc,'fillText'), oR=wc.fillRect, oF=wc.fillText, last=null, got=null, LB='ZQX '+'BIG LOOT', a, b, fp;
     function unspy(){ if(ownR) wc.fillRect=oR; else delete wc.fillRect; if(ownF) wc.fillText=oF; else delete wc.fillText; }
     function px(f){ var m=(/([\d.]+)px/).exec(String(f)); return m?parseFloat(m[1]):0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.bagOpen=false; g.mapOpen=false; g.ents.length=0;
       g.labels.length=0;
       label(p.x,p.y-30,LB,'#ffc04a',0,true,'bandage');
       a=g.labels[g.labels.length-1];
       wc.fillRect=function(x,y,w,h){ var s=String(wc.fillStyle).replace(/\s/g,''); if(s==='rgba(6,9,13,0.55)'||s==='rgba(6,9,13,.55)') last={y:y,h:h}; return oR.apply(this,arguments); };
       wc.fillText=function(t,x,y){ if(String(t)===LB&&!got&&last) got={y:y,px:px(wc.font),plate:last}; return oF.apply(this,arguments); };
       try{ render2D(0); } finally { unspy(); }
       if(!got) return 'SKIP: staging: the loot label was not drawn on a plate';
       fp=got.px;
       if(!(fp>0)) return 'SKIP: staging: no font size on the label';
       if(got.plate.h<fp*1.15) bad.push('the loot label plate is '+got.plate.h.toFixed(1)+' units tall for a '+fp.toFixed(1)+' unit font');
       if(got.plate.y>got.y-fp*0.7) bad.push('the loot label plate starts at '+(got.y-got.plate.y).toFixed(1)+' units above the baseline, below the top of its '+fp.toFixed(1)+' unit caps');
       label(p.x,p.y-30,LB+' TWO','#ffc04a',0,true,'bandage');
       b=g.labels[g.labels.length-1];
       if(!a||!b||b===a) bad.push('control: the second label was not pushed');
       else if(a.y-b.y<fp*1.15) bad.push('a second label at the same spot stacks only '+(a.y-b.y)+' units above the first, inside its '+fp.toFixed(1)+' unit font plate');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); keys={};
       try{ var g2=__state(); if(g2){ g2.labels.length=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
