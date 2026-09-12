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

# v13.08 CHECK, inserted before the v13.07 entry.
#
# IT WATCHES WHAT THE FIGURE IS HANDED, by wrapping the one routine that draws an
# operator and recording the weapon and the stance it is called with. That is the only
# way to see this from a check: the gun is a few pixels in a hand and reading the
# canvas for it would be measuring the art rather than the decision.
#
# AND IT READS THE CAPTION OFF THE FRAME, through the recorder that keeps every string
# painted.
#
# THE RAID ARM IS THE CONTROL AND IT IS NOT DECORATION. Both of these could have been
# fixed by deleting them everywhere, which would pass any check that only looked at
# the floor and would quietly take two things he uses in a raid.
SubRx @'
  {v:'13.07',what:'a brand-new player is not left stranded
'@ @'
  {v:'13.08',what:'the Undercroft is not a raid: the operator walks the floor with empty hands and the belt caption offering FIRE and SIGNAL is not drawn down there, while both are still exactly as they were in a raid (his notes of 2026-09-12)',
   run:function(){
     if(!(window.__loop&&window.__showScreen&&window.__hubEnter&&window.__P)) return 'SKIP: this fixture cannot draw the Undercroft floor';
     if(typeof drawOp!=='function') return 'SKIP: this build has no operator routine to watch';
     if(!(window.__tx&&window.__tx.record)) return 'SKIP: this fixture cannot record what is painted';
     var bad=[], P2=__P(), oDraw=drawOp;
     var keep={eq:P2.equipped,eq2:P2.equippedSec,w:(P2.weapons||[]).slice()};
     var seen=[];
     function watch(){
       seen=[];
       drawOp=function(x,y,face,bob,col,load,a7,pose,a9,o){
         if(o&&o.hero) seen.push({pose:String(pose||''),wep:(o.own&&o.own.wep)?(o.own.wep.id||'yes'):null});
         return oDraw.apply(null,arguments);
       };
     }
     function stop(){ drawOp=oDraw; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // A gun he owns and is holding, so there is something to wrongly draw.
       var gun=null,wk;
       for(wk in WEAPONS) if(WEAPONS[wk]&&wk!=='fists'&&WEAPONS[wk].mag){ gun=wk; break; }
       if(!gun) return 'SKIP: this build has no gun to hold';
       P2.weapons=[gun]; P2.equipped=gun; P2.equippedSec='none'; saveProfile();

       // THE FLOOR.
       __showScreen('hub'); __hubEnter();
       watch();
       var painted=[];
       // A REAL FLOOR FRAME, not just the world draw. The belt and the bag are painted
       // on the HUD canvas by the loop, so __hubFrame alone never draws the caption and
       // an arm written against it would assert nothing at all. Measured on the v13.06
       // fixture: 36 strings and no caption from __hubFrame, 165 strings and the caption
       // from three loop frames.
       var _t0=performance.now();
       try{ painted=__tx.record(function(){ for(var _lf=0;_lf<3;_lf++) __loop(_t0+_lf*16.7); })||[]; }catch(_r){}
       stop();
       if(!seen.length){
         bad.push('control: the floor drew no operator at all, so there is nothing here to look at');
       } else {
         var armed=0, posed=0, i;
         for(i=0;i<seen.length;i++){
           if(seen[i].wep) armed++;
           if(seen[i].pose!=='none'&&seen[i].pose!=='roll') posed++;
         }
         if(armed)
           bad.push('the operator is handed a gun to hold while he walks around the Undercroft: he is at home, there is nothing to shoot, and he is carrying his raid weapon around it');
         if(posed)
           bad.push('the operator stands in the Undercroft in a gun stance rather than empty-handed');
       }
       var floorText=painted.map(function(d){ return String(d.t); }).join(' | ');
       if(floorText.indexOf('signal')>=0||floorText.indexOf('SIGNAL')>=0)
         bad.push('the belt caption on the Undercroft floor still offers FIRE and SIGNAL, and there is nothing down there to fire at and nobody to signal');

       // THE RAID, which is the control: neither of these may have been fixed by
       // deleting it everywhere.
       if(window.__deploy&&window.__frame&&window.__state){
         try{
           __deploy({kit:[],safe:null,mapIx:0,seed:4242});
           watch();
           var rp=[];
           try{ rp=__tx.record(function(){ __frame(0.016); })||[]; }catch(_r2){}
           stop();
           var rArmed=0,j;
           for(j=0;j<seen.length;j++) if(seen[j].wep) rArmed++;
           if(seen.length&&!rArmed)
             bad.push('control: in a RAID the operator is handed no weapon either, so the gun was taken off him everywhere rather than only in the Undercroft');
           var raidText=rp.map(function(d){ return String(d.t); }).join(' | ');
           if(raidText.indexOf('[V] signal')<0)
             bad.push('control: the belt caption is gone from the RAID as well, where FIRE and SIGNAL are real actions he uses, so it was deleted rather than moved out of the Undercroft');
         }catch(_d){ bad.push('the raid control threw: '+(_d&&_d.message||_d)); }
         try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
         try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ stop(); }catch(_s){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q2){}
       try{ P2.equipped=keep.eq; P2.equippedSec=keep.eq2; P2.weapons=keep.w; saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.07',what:'a brand-new player is not left stranded
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
