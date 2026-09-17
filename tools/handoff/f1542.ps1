$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.41',what:
'@ @'
  {v:'15.42',what:'crouched beside your hire or a downed pillager, the readout says hidden: crouched with every other body lifted, a hire 60 units away and then a downed pillager 60 units away each draw the plate HIDDEN, CROUCHED and never the too close warning, while the same pillager standing 60 away draws the warning, the hire 400 away draws HIDDEN, CROUCHED and the hire at 60 beside a pillager standing at 100 still draws the warning (hud audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||typeof ctx==='undefined'||typeof mkRaider!=='function') return 'SKIP: no HUD draw or pillagers in this build';
     if(typeof raiderDownHp!=='function'||typeof RAIDER_DOWN_T==='undefined') return 'SKIP: no downed pillagers in this build';
     var bad=[], g=null, p=null, keep=null, keepEnts=null, texts=[], realFT=null, ownFT=false, R=null, M=null;
     var OWN=Object.prototype.hasOwnProperty;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // Assembled, never written whole, so only the drawn plate can hold them.
     var DOT='  \u00b7  ', HID='HIDDEN'+DOT+'CROUCHED', NEAR='PARTLY HIDDEN'+DOT+'TOO'+' CLOSE';
     // Every string one drawn HUD hands to fillText, before any text edit; null on a throw.
     function drawn(){ texts.length=0; try{ drawHUD(); }catch(_h){ return null; } return texts.slice(); }
     function has(d,t){ for(var i=0;i<d.length;i++) if(d[i]===t) return true; return false; }
     function plate(d){ for(var i=0;i<d.length;i++) if(d[i]===HID||d[i]===NEAR||d[i].indexOf('PARTLY HIDDEN')===0) return d[i]; return 'no crouch plate'; }
     // Only the bodies named, each put dx units east of him; the draw with them.
     function crouchBy(list){
       g.ents.length=0;
       for(var i=0;i<list.length;i++){ list[i].e.x=p.x+list[i].dx; list[i].e.y=p.y; g.ents.push(list[i].e); }
       g.pCrouch=true; g.pBush=false;
       return drawn();
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.sim||!g.ents) return 'SKIP: no live raid';
       p=g.player;
       var chid=(CFG.crouchHide===undefined?170:CFG.crouchHide);
       if(!(chid>100&&chid<400)) return 'SKIP: the crouch hide range is '+chid+' here, not between the 100 and 400 units this check stands bodies at';
       keep={pCrouch:g.pCrouch,pBush:g.pBush,bagOpen:g.bagOpen,mapOpen:g.mapOpen,downed:p.downed};
       keepEnts=g.ents.slice();
       g.bagOpen=false; g.mapOpen=false; p.downed=false;
       // A standing pillager, and a hire built the way buildRaid builds one.
       R=mkRaider(p.x+60,p.y,null,false); R.merc=0; R.hostile=true; R.downed=0; R.finished=0;
       M=mkRaider(p.x+60,p.y,null,false); M.merc=1; M.hostile=false; M.grudge=false; M.friendly=1; M.downed=0; M.finished=0;
       ownFT=OWN.call(ctx,'fillText'); realFT=ctx.fillText;
       ctx.fillText=function(t){ texts.push(String(t)); return realFT.apply(this,arguments); };
       // CONTROL: crouched with nobody near, the drawn plate reads HIDDEN, CROUCHED, so the plate can be read.
       var d0=crouchBy([]);
       if(d0===null) return 'SKIP: drawing the HUD threw here';
       if(!has(d0,HID)) return 'SKIP: crouched with nobody near, the drawn plate read ['+plate(d0)+'], not '+HID+', so the plate cannot be read here';
       // CONTROL: the same pillager standing 60 away draws the too close warning, so the warning can be read.
       var d1=crouchBy([{e:R,dx:60}]);
       if(d1===null||!has(d1,NEAR)) return 'SKIP: crouched with a standing pillager 60 units away, the drawn plate read ['+(d1===null?'a throw':plate(d1))+'], not the too close warning, so the warning cannot be read here';
       // CONTROL: the hire 400 away draws HIDDEN, CROUCHED, so the hire alone is what moves the plate.
       var d2=crouchBy([{e:M,dx:400}]);
       if(d2===null||!has(d2,HID)) return 'SKIP: crouched with the hire 400 units away, the drawn plate read ['+(d2===null?'a throw':plate(d2))+'], not '+HID+' here';
       // THE FIX: the hire 60 away, following as he does, is nobody to hide from.
       var d3=crouchBy([{e:M,dx:60}]);
       if(d3===null) return skip('drawing the HUD with the hire 60 units away threw here');
       if(has(d3,NEAR)||!has(d3,HID)) bad.push('crouched with his own hire 60 units away and nobody else on the raid, the drawn plate read ['+plate(d3)+'] and not '+HID+', though a hire never hunts him');
       // THE FIX: a pillager lying downed 60 away cannot see him either.
       var rState=R.state, rHp=R.hp, rDownT=R.downT;
       R.downed=1; R.state='down'; R.downT=RAIDER_DOWN_T; R.hp=raiderDownHp();
       var d4=crouchBy([{e:R,dx:60}]);
       R.downed=0; R.state=rState; R.hp=rHp; R.downT=rDownT;
       if(d4===null) return skip('drawing the HUD with a downed pillager 60 units away threw here');
       if(has(d4,NEAR)||!has(d4,HID)) bad.push('crouched with a pillager lying downed 60 units away and nobody else on the raid, the drawn plate read ['+plate(d4)+'] and not '+HID+', though a downed pillager sees nothing');
       // CONTROL: the hire at 60 beside a pillager standing at 100 still draws the warning, so the hire does not hide a real one.
       var d5=crouchBy([{e:M,dx:60},{e:R,dx:100}]);
       if(d5===null) return skip('drawing the HUD with the hire and a standing pillager near threw here');
       if(!has(d5,NEAR)) bad.push('crouched with the hire 60 units away and a standing pillager 100 units away, the drawn plate read ['+plate(d5)+'] and lost the too close warning');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFT){ if(ownFT) ctx.fillText=realFT; else delete ctx.fillText; } }catch(_t){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(g&&keep){ g.pCrouch=keep.pCrouch; g.pBush=keep.pBush; g.bagOpen=keep.bagOpen; g.mapOpen=keep.mapOpen; if(p) p.downed=keep.downed; } }catch(_p){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
