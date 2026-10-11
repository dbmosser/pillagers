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

if ($s.Contains("  {v:'22.97',what:")) { throw "check 22.97 is in the fixture already" }

SubRx @'
  {v:'22.96',what:
'@ @'
  {v:'22.97',what:'WEAK SPOT once per target and loot names kept: eight weak point hits on one Sentry in one frame push exactly one WEAK SPOT label, another 0.6 s later pushes a second, and 40 more callouts after three loot labels leave all three loot labels up',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof updateBullets!=='function'||typeof weakOf!=='function'||typeof weakPos!=='function'||typeof mkSentry!=='function'||typeof label!=='function') return 'SKIP: no weak points or labels here';
     var bad=[], g=null, p=null, e, L, W=null, i, pt, ux, uy, n, WS='WEAK '+'SPOT', LT='ZQX '+'LOOT ', w1, w2, left;
     function weakN(){ var c=0; for(var j=0;j<g.labels.length;j++) if(g.labels[j].txt===WS) c++; return c; }
     function volley(k){
       g.bullets.length=0;
       for(var j=0;j<k;j++){ var bx=e.x+ux*(e.r+2.5), by=e.y+uy*(e.r+2.5); g.bullets.push({x:bx,y:by,vx:-ux*1180,vy:-uy*1180,dmg:1,life:0.5,player:true,owner:p,tint:'#ffd48a',thru:0}); }
       updateBullets(0.01);
       g.bullets.length=0;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; keys={};
       e=mkSentry(p.x+260,p.y); e.hp=e.maxhp=1e6; e.roll=0; e.state='patrol';
       L=weakOf(e); if(!L||!L.length) return 'SKIP: a Sentry has no weak point here';
       for(i=0;i<L.length;i++) if(!W||L[i].rf*e.r+L[i].rad>W.rf*e.r+W.rad) W=L[i];
       pt=weakPos(e,W); ux=pt.x-e.x; uy=pt.y-e.y; n=Math.sqrt(ux*ux+uy*uy)||1; ux/=n; uy/=n;
       g.ents.length=0; g.ents.push(e);
       g.labels.length=0;
       label(p.x-400,p.y-200,LT+'A','#cdd6dd',0,true,'bandage');
       label(p.x,p.y-200,LT+'B','#cdd6dd',0,true,'bandage');
       label(p.x+400,p.y-200,LT+'C','#cdd6dd',0,true,'bandage');
       volley(8);
       w1=weakN();
       if(!w1) return 'SKIP: staging: eight rounds at the '+W.name+' pushed no WEAK SPOT label';
       if(w1!==1) bad.push('eight weak point hits on one Sentry in one frame pushed '+w1+' WEAK SPOT labels, not one');
       g.t=(g.t||0)+0.6;
       volley(1);
       w2=weakN();
       if(w2!==w1+1) bad.push('a weak point hit 0.6 s later pushed '+(w2-w1)+' more WEAK SPOT labels, not one');
       for(i=0;i<40;i++) label(p.x+((i%8)-4)*120,p.y+60+Math.floor(i/8)*30,'ZQX CALL '+i,'#ff5a4a',0,false);
       left=0; for(i=0;i<g.labels.length;i++) if(String(g.labels[i].txt).indexOf(LT)===0) left++;
       if(left!==3) bad.push('after 40 more callouts '+left+' of the 3 loot labels were left');
       if(g.labels.length>40) bad.push('the label list grew to '+g.labels.length+', past its cap of 40');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       try{ var g2=__state(); if(g2){ g2.labels.length=0; g2.bullets.length=0; g2.ents.length=0; if(!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
