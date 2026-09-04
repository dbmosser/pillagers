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
  {v:'10.66',what:'a brand new character meets the welcome pack and then the primer, one at a time, and the primer is still owed after a first raid instead of being stamped away unread',
'@ @'
  {v:'10.67',what:'the welcome pack guns go into his hands, so a new character deploys with what he was just given, and a player who already chose keeps his choice',
   run:function(){
     var bad=[];
     if(!(window.__hubEnter&&window.__P&&window.__deploy&&window.__state)) return 'SKIP: this build cannot arrive and deploy';
     if(typeof WELCOME_PACK==='undefined') return 'SKIP: no welcome pack in this build';
     var P2=__P();
     function shut(){ Array.prototype.forEach.call(document.querySelectorAll('.modal.on'),function(e){ e.classList.remove('on'); }); }
     var keep={welcomed:P2.welcomed,runs:P2.runs,stash:(P2.stash||[]).slice(),weapons:(P2.weapons||[]).slice(),
               equipped:P2.equipped,equippedSec:P2.equippedSec,primerSeen:P2.primerSeen,credits:P2.credits};
     function fresh(){
       shut();
       P2.welcomed=0; P2.runs=0; P2.stash=[]; P2.weapons=[]; P2.credits=0;
       P2.equipped='fists'; P2.equippedSec='none'; P2.primerSeen=1; P2.primerOff=true;
       try{ saveProfile(); }catch(_s){}
     }
     var packGuns=(WELCOME_PACK.guns||[]).slice();
     if(packGuns.length<2) return 'SKIP: the pack no longer carries two guns';
     try{
       // 1. TAKING THE PACK puts its guns in his hands, not only in the armoury.
       fresh();
       __hubEnter();
       var take=document.getElementById('welcometake');
       if(!take) return 'SKIP: this build has no welcome pack button';
       take.onclick(); shut();
       if(P2.equipped!==packGuns[0]) bad.push('after taking the pack his first slot holds '+P2.equipped+', not the '+packGuns[0]+' he was given');
       if(P2.equippedSec!==packGuns[1]) bad.push('after taking the pack his second slot holds '+P2.equippedSec+', not the '+packGuns[1]+' he was given');
       if((P2.weapons||[]).indexOf(packGuns[0])<0) bad.push('the pack gun is not in the armoury either');
       // 2. AND HE DEPLOYS WITH IT. The issued starter is rolled fresh per raid,
       //    so this asks what is in his hands rather than what is not.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player) bad.push('the raid did not build');
       else {
         var W=__weapons(), want=W[packGuns[0]]&&W[packGuns[0]].name;
         var inHand=g.player.wep&&g.player.wep.name;
         if(!inHand||inHand.indexOf(want)<0) bad.push('he went up holding '+inHand+' instead of the '+want+' from his welcome pack');
         if(g.player.wepIssued) bad.push('he went up with an issued loaner even though the pack gave him a gun');
       }
       // 3. A PLAYER WHO ALREADY CHOSE KEEPS HIS CHOICE: this fills empty hands,
       //    it is not the auto-equip he refused.
       fresh();
       P2.weapons=['rifle']; P2.equipped='rifle'; P2.equippedSec='none';
       try{ saveProfile(); }catch(_s2){}
       __hubEnter();
       var take2=document.getElementById('welcometake');
       if(take2){ take2.onclick(); shut(); }
       if(P2.equipped!=='rifle') bad.push('taking the pack pushed his own rifle out of his hands (it now holds '+P2.equipped+')');
       if(P2.equippedSec!==packGuns[1]) bad.push('the empty second slot was not filled by the pack (it holds '+P2.equippedSec+')');
     } finally {
       shut();
       P2.welcomed=keep.welcomed; P2.runs=keep.runs; P2.stash=keep.stash; P2.weapons=keep.weapons;
       P2.equipped=keep.equipped; P2.equippedSec=keep.equippedSec; P2.primerSeen=keep.primerSeen; P2.credits=keep.credits;
       P2.primerOff=false;
       try{ saveProfile(); }catch(_s3){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.66',what:'a brand new character meets the welcome pack and then the primer, one at a time, and the primer is still owed after a first raid instead of being stamped away unread',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
