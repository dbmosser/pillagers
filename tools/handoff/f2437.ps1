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

if ($s.Contains("  {v:'24.37',what:")) { throw "check 24.37 is in the fixture already" }

SubRx @'
  {v:'24.36',what:
'@ @'
  {v:'24.37',what:'graphics program gfxsil (his #24, silhouettes for readability): every body has inked shoulder caps standing out past its torso, wide on Broad and narrow on Curved; in a raid they wear the team colour (ally blue on you, danger red on a pillager) and a body with no side wears its coat; the gun has an ink rim and a lit top edge; the raid draws you as ally and a pillager as foe',
   run:function(){
     if(typeof drawOp!=='function') return 'SKIP: no painter here';
     var bad=[], w0=wc, cvs=document.createElement('canvas'), x2, od=drawOp, g, r=null, seenR=null, seenP=null, i;
     cvs.width=240; cvs.height=220; x2=cvs.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function paint(st,mode){ var b={hero:0,moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,own:{wep:null}}, k; for(k in st) b[k]=st[k];
       x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,240,220); x2.setTransform(4,0,0,4,120,190); wc=x2;
       try{ drawOp(0,0,0,0,'#242832',0,0,mode,0,b); } finally { wc=w0; x2.setTransform(1,0,0,1,0,0); } }
     function at(lx,ly){ return x2.getImageData(Math.round(120+lx*4),Math.round(190+ly*4),1,1).data; }
     function hue(x0,x1,kind){ var d=x2.getImageData(Math.round(120+x0*4),Math.round(190-24.5*4),Math.round((x1-x0)*4),Math.round(6.5*4)).data, n=0, q;
       for(q=0;q<d.length;q+=4){ if(d[q+3]<200) continue;
         if(kind==='foe'&&d[q]>180&&d[q+1]<120&&d[q+2]<100) n++;
         if(kind==='ally'&&d[q+2]>200&&d[q]<150&&d[q+1]>130) n++; }
       return n; }
     try{
       paint({team:'foe',build:'lean'},'none');
       if(hue(-11.5,-5.5,'foe')<30||hue(5.5,11.5,'foe')<30) bad.push('a foe has no danger red on both shoulders ('+hue(-11.5,-5.5,'foe')+', '+hue(5.5,11.5,'foe')+' px)');
       paint({team:'ally',build:'lean'},'none');
       if(hue(-11.5,-5.5,'ally')<30||hue(5.5,11.5,'ally')<30) bad.push('an ally has no ally blue on both shoulders ('+hue(-11.5,-5.5,'ally')+', '+hue(5.5,11.5,'ally')+' px)');
       paint({build:'lean'},'none');
       if(hue(5.5,11.5,'foe')+hue(5.5,11.5,'ally')>0) bad.push('a body with no side wears a team colour');
       if(!(at(9.6,-21)[3]>200)) bad.push('Lean: no shoulder stands out past the torso at 9.6');
       paint({build:'broad'},'none');
       if(!(at(11.5,-21)[3]>200)) bad.push('Broad: no wide shoulder at 11.5');
       paint({build:'curved'},'none');
       if(!(at(6.9,-21)[3]>200)) bad.push('Curved: no shoulder at 6.9');
       if(at(9.6,-21)[3]>40) bad.push('Curved: the shoulders are as wide as Lean, she lost her narrow shoulders');
       if(!(at(-4.5,-18.0)[3]>200)) bad.push('Curved: the chest is gone');
       paint({team:'foe',build:'lean',bulk:2},'none');
       if(hue(-14.5,-8.5,'foe')<8) bad.push('armour 2: no team stripe on the steel pauldron');
       paint({build:'lean'},'');
       var rim=at(13.5,-22.0), top=at(13.5,-21.2);
       if(!(rim[3]>200&&rim[0]+rim[1]+rim[2]<120)) bad.push('the gun has no ink rim above it ('+rim.join(',')+')');
       if(!(top[0]+top[1]+top[2]>330)) bad.push('the gun has no lit top edge ('+top.join(',')+')');
       if(window.__deploy&&window.__state&&window.__frame){
         __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         g=__state();
         if(g&&g.player&&!g.over){
           for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&g.ents[i].hp>0){ r=g.ents[i]; break; }
           if(r){ r.downed=false; g.player.x=r.x+40; g.player.y=r.y+40; g.player.iv=99;
             drawOp=function(x,y,f,ph,co,pk,mu,mode,iv,st){ if(st&&st.own===r) seenR=st; if(st&&st.hero&&st.own===g.player) seenP=st; return od.apply(this,arguments); };
             for(i=0;i<6&&!(seenR&&seenP);i++) __frame(0.05);
             drawOp=od;
             if(!seenP) bad.push('the player was not drawn in the raid');
             else if(seenP.team!=='ally') bad.push('the raid draws you with team '+seenP.team+', not ally');
             if(seenR&&seenR.team!=='foe') bad.push('the raid draws a pillager with team '+seenR.team+', not foe');
           }
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; drawOp=od; try{ var g2=__state&&__state(); if(g2&&!g2.over&&g2.player){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} try{ __topClear(); __cleanProfile(); }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
