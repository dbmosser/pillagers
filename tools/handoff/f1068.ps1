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
  {v:'10.67',what:'the welcome pack guns go into his hands, so a new character deploys with what he was just given, and a player who already chose keeps his choice',
'@ @'
  {v:'10.68',what:'a gun found in a raid fills the empty second slot instead of shoving the gun out of his hands, and with both slots full it still replaces the gun in his hands',
   run:function(){
     var bad=[];
     if(!(window.__startRaid&&window.__state&&window.__keysRef&&window.__loop&&window.__P))
       return 'SKIP: this build cannot drive a raid on the play path';
     var P2=__P();
     var keep={eq:P2.equipped,sec:P2.equippedSec,wpn:(P2.weapons||[]).slice()};
     function keysOff(){ var K=__keysRef(); for(var k in K) K[k]=false; return K; }
     var floor=(WTIER['pistol']||0);
     // The container has to hold a gun that BEATS what is in his hands, because
     // the pickup only equips an upgrade. Nearest such container wins.
     function findBox(g){
       var p=g.player, best=null, bd=1e9, want=null;
       for(var i=0;i<g.containers.length;i++){
         var c=g.containers[i]; if(!c.loot||!c.loot.length) continue;
         var gk=null;
         for(var j=0;j<c.loot.length;j++){
           var it=c.loot[j];
           if(it.indexOf('gun_')!==0) continue;
           var k2=it.slice(4);
           if((WTIER[k2]||0)>floor) gk=k2;
         }
         if(!gk) continue;
         var d=Math.hypot(c.x-p.x,c.y-p.y);
         if(d<bd){ bd=d; best=c; want=gk; }
       }
       return best?{box:best,want:want}:null;
     }
     // One arm: deploy with the pistol in hand and secKey in the second slot,
     // stand on the container and HOLD E through the real frame loop. This is
     // the play path on purpose; the bot never runs this code.
     function drive(secKey){
       P2.equipped='pistol'; P2.equippedSec=secKey;
       P2.weapons=(secKey==='none')?['pistol']:['pistol',secKey];
       try{ saveProfile(); }catch(_s){}
       __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       var f=findBox(g);
       if(!f) return {skip:'no container near him holds a gun better than the Scav Pistol'};
       if(p.wep.id!=='pistol') return {skip:'he did not deploy holding the Scav Pistol, he holds '+p.wep.id};
       p.x=f.box.x; p.y=f.box.y+4;
       var K=keysOff(); K['KeyE']=true;
       var err=null;
       try{ for(var i=0;i<420;i++) __loop(performance.now()+i*16.7); }catch(e){ err=String(e); }
       keysOff();
       var g2=__state(), p2=g2.player;
       return {err:err, want:f.want, wep:p2.wep.id, sec:p2.sec?p2.sec.id:'(nothing)',
               bag:g2.bag.slice(), searched:g2.tel.containers};
     }
     try{
       if(window.__cleanProfile) __cleanProfile();
       // 1. HIS NOTE: the empty slot takes it and his hands are left alone.
       var a=drive('none');
       if(a.skip) return 'SKIP: '+a.skip;
       if(a.err) bad.push('looting threw: '+a.err);
       else if(!a.searched) bad.push('he held E for 420 frames and searched nothing, so no gun was found to place');
       else{
         if(a.wep!=='pistol') bad.push('the '+a.want+' he found pushed the Scav Pistol out of his hands (he now holds '+a.wep+')');
         if(a.sec!==a.want) bad.push('the '+a.want+' he found did not go to his empty second slot (it holds '+a.sec+')');
         if(a.bag.indexOf('gun_pistol')>=0) bad.push('his Scav Pistol went in the bag even though the second slot was standing empty');
       }
       // 2. BOTH SLOTS FULL is unchanged, and a rifle in the second slot is
       //    nothing the pickup could have produced by accident.
       var b=drive('rifle');
       if(b.skip) bad.push('the both-full arm could not run: '+b.skip);
       else if(b.err) bad.push('looting threw with both slots full: '+b.err);
       else if(!b.searched) bad.push('the both-full arm searched nothing');
       else{
         if(b.wep!==b.want) bad.push('with both slots full the '+b.want+' did not go into his hands (he holds '+b.wep+')');
         if(b.sec!=='rifle') bad.push('with both slots full his second slot was disturbed (it holds '+b.sec+' instead of the rifle)');
         if(b.bag.indexOf('gun_pistol')<0) bad.push('with both slots full the Scav Pistol he was holding did not go to the bag');
       }
     } finally {
       keysOff();
       P2.equipped=keep.eq; P2.equippedSec=keep.sec; P2.weapons=keep.wpn;
       try{ saveProfile(); }catch(_s2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.67',what:'the welcome pack guns go into his hands, so a new character deploys with what he was just given, and a player who already chose keeps his choice',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
