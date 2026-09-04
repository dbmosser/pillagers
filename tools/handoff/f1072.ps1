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
  {v:'10.71',what:'the safe pocket says when it is naming something that is not going up, the ascent check names it, and the loadout total counts it once or not at all',
'@ @'
  {v:'10.72',what:'the death screen counts the gun it says you lost, in the number and in the money, and still leaves an issued loaner out of both',
   run:function(){
     var bad=[];
     if(!(window.__deploy&&window.__endRaid&&window.__P&&window.__state)) return 'SKIP: this build cannot deploy and die';
     if(typeof ival!=='function') return 'SKIP: no item values in this build';
     var P2=__P();
     var keep={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),weapons:(P2.weapons||[]).slice(),
               eq:P2.equipped,sec:P2.equippedSec,safe:P2.safe,hot:P2.hotAssign,free:P2.freeKit,auto:P2.autoExport};
     var GUN='pistol', ITEM='medkit';
     if(!(WEAPONS[GUN]&&ITEMS['gun_'+GUN]&&ITEMS[ITEM])) return 'SKIP: this build lacks the gun or item this uses';
     var gunVal=ival('gun_'+GUN);
     if(!(gunVal>0)) return 'SKIP: the '+GUN+' is worth nothing, so leaving it out could not be seen';
     // One death. equipped decides whether he is holding HIS gun or a loaner.
     function die(equipped, weapons){
       if(window.__cleanProfile) __cleanProfile();
       P2.freeKit=0; P2.hotAssign={}; P2.autoExport=false; P2.safe=null;
       P2.stash=[ITEM]; P2.kit=[ITEM];
       P2.weapons=weapons.slice(); P2.equipped=equipped; P2.equippedSec='none';
       try{ saveProfile(); }catch(_s){}
       __deploy({kit:[ITEM],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       var held={id:p.wep&&p.wep.id, issued:!!p.wepIssued};
       // What is actually in the bag decides the honest total, so it is read
       // from the game rather than assumed from what was packed.
       var bagVal=0, bagN=g.bag.length;
       for(var i=0;i<g.bag.length;i++) bagVal+=ival(g.bag[i]);
       __endRaid('dead');
       var oc=document.getElementById('outcome');
       var t=(oc?(oc.innerText||''):'').replace(/\s+/g,' ');
       if(oc) oc.classList.remove('on');
       var lostLines=(t.match(/\bLOST\b/g)||[]).length;
       var m=/([0-9]+) items? (?:and ([0-9]+) guns? )?lost, \$([0-9,]+) gone/.exec(t);
       return {held:held, bagN:bagN, bagVal:bagVal, lostLines:lostLines,
               said:m?m[0]:null, nItems:m?+m[1]:null, nGuns:m&&m[2]?+m[2]:0,
               money:m?+String(m[3]).replace(/,/g,''):null};
     }
     try{
       // 1. HIS OWN GUN. It is listed as LOST, so it must be in the count and
       //    in the money underneath it.
       var own=die(GUN,[GUN]);
       if(!own.said) return 'SKIP: could not read the lost line off the death screen';
       if(own.held.id!==GUN||own.held.issued) return 'SKIP: he did not deploy holding his own '+GUN+' (held '+own.held.id+', issued '+own.held.issued+')';
       if(own.nGuns!==1) bad.push('he died holding his own '+GUN+' and the line says '+own.nGuns+' guns lost: '+own.said);
       if(own.nItems+own.nGuns!==own.lostLines) bad.push('the screen printed '+own.lostLines+' LOST lines and then said '+(own.nItems+own.nGuns)+' lost: '+own.said);
       if(own.money!==own.bagVal+gunVal) bad.push('the '+GUN+' is worth '+gunVal+' and the bag '+own.bagVal+', and the screen says $'+own.money+' gone');
       // 2. AN ISSUED LOANER is not his and must stay out of both.
       var loan=die('fists',[]);
       if(!loan.said) bad.push('control: could not read the lost line on the loaner death');
       else{
         if(!loan.held.issued) bad.push('control: he was meant to go up with a loaner and did not (held '+loan.held.id+')');
         if(loan.nGuns!==0) bad.push('an issued loaner was counted as a gun lost: '+loan.said);
         if(loan.money!==loan.bagVal) bad.push('an issued loaner put '+(loan.money-loan.bagVal)+' into the money lost, and he never owned it');
         if(loan.nItems!==loan.lostLines) bad.push('control: the loaner death printed '+loan.lostLines+' LOST lines against '+loan.nItems+' counted');
       }
       // 3. CONTROL, so this cannot pass on a screen that counts nothing: the
       //    two deaths must differ by exactly the gun.
       if(own.money!==null&&loan.money!==null&&own.bagVal===loan.bagVal&&(own.money-loan.money)!==gunVal)
         bad.push('control: the same bag with and without his own gun differs by '+(own.money-loan.money)+', not the '+gunVal+' the gun is worth');
     } finally {
       P2.stash=keep.stash; P2.kit=keep.kit; P2.weapons=keep.weapons; P2.equipped=keep.eq;
       P2.equippedSec=keep.sec; P2.safe=keep.safe; P2.hotAssign=keep.hot; P2.freeKit=keep.free; P2.autoExport=keep.auto;
       try{ saveProfile(); }catch(_s2){}
       var o2=document.getElementById('outcome'); if(o2) o2.classList.remove('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.71',what:'the safe pocket says when it is naming something that is not going up, the ascent check names it, and the loadout total counts it once or not at all',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
