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

# v13.29 CHECK, inserted before the v13.28 entry, plus three repairs.
#
# HIS RULING OF 2026-09-13 REVERSES v10.67: the welcome pack goes to the stash and
# equips nothing. The new check presses the real TAKE on a brand-new player and reads
# the profile it wrote, so it measures what the button did rather than what a row
# said. It restores the profile, because every later check runs on it.
SubRx @'
  {v:'13.28',what:'the save you are on is tagged NEW until it has a raid and CONTINUING after, instead of telling a player on his first ever launch that he is continuing something',
'@ @'
  {v:'13.29',what:'the welcome pack goes to the stash: both guns land there as gun items, nothing is added to the armoury, nothing is equipped for him, and every row in the window says to your stash (his ruling of 2026-09-13)',
   run:function(){
     if(typeof maybeWelcome!=='function'||typeof WELCOME_PACK==='undefined') return 'SKIP: this fixture cannot open the welcome pack';
     var md=document.getElementById('welcomemodal'), box=document.getElementById('welcomelist');
     if(!md||!box) return 'SKIP: this build has no welcome pack window';
     var bad=[];
     var keep={runs:P.runs,welcomed:P.welcomed,stash:(P.stash||[]).slice(),weapons:(P.weapons||[]).slice(),equipped:P.equipped,equippedSec:P.equippedSec};
     try{
       var guns=WELCOME_PACK.guns||[];
       if(guns.length<2) return 'SKIP: the pack carries fewer than two guns';
       P.runs=0; P.welcomed=0; P.stash=[]; P.weapons=['pistol']; P.equipped='fists'; P.equippedSec='none';
       maybeWelcome();
       if(!md.classList.contains('on')) return 'SKIP: the welcome pack did not open for a brand-new player';
       box.querySelectorAll('.row').forEach(function(r){
         var t=String(r.textContent||'').replace(/\s+/g,' ');
         if(t.indexOf('to your stash')<0) bad.push('a row in the pack window does not say it goes to the stash: ['+t+']');
       });
       var take=document.getElementById('welcometake');
       if(!take) return 'SKIP: this build has no TAKE button';
       take.click();
       for(var i=0;i<guns.length;i++){
         var gi='gun_'+guns[i];
         if((P.stash||[]).indexOf(gi)<0)
           bad.push('taking the pack did not put the '+guns[i]+' in the stash as an item, so the pack did not go to the stash');
         if((P.weapons||[]).indexOf(guns[i])>=0)
           bad.push('taking the pack added the '+guns[i]+' to the armoury, which his ruling moved to the stash');
       }
       if(P.equipped!=='fists')
         bad.push('taking the pack equipped '+String(P.equipped)+' for him, when his ruling is that the pack goes to the stash and he packs on purpose');
       if(P.equippedSec!=='none')
         bad.push('taking the pack filled his second slot with '+String(P.equippedSec)+' for him');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ md.classList.remove('on'); }catch(_m){}
       try{ P.runs=keep.runs; P.welcomed=keep.welcomed; P.stash=keep.stash; P.weapons=keep.weapons; P.equipped=keep.equipped; P.equippedSec=keep.equippedSec; saveProfile(); }catch(_r){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.28',what:'the save you are on is tagged NEW until it has a raid and CONTINUING after, instead of telling a player on his first ever launch that he is continuing something',
'@

# REPAIR 13.07: its two hands assertions encoded v10.67, which his ruling reverses.
# The stash assertion beside them, the declining arm and the consent arm all stand.
SubRx @'
  {v:'13.07',what:'a brand-new player is not left stranded: the welcome pack puts a gun in his hands and not only in his armoury, declining it still deploys him with a working weapon, and with no upload address he is never asked for permission to send something the game cannot send (written the day it first went in front of strangers)',
'@ @'
  {v:'13.07',what:'a brand-new player is not left stranded: taking the welcome pack fills his stash, declining it still deploys him with a working weapon, and with no upload address he is never asked for permission to send something the game cannot send (written the day it first went in front of strangers; the hands arm retired by his ruling of 2026-09-13)',
'@

SubRx @'
           if(!(P2.weapons||[]).length)
             bad.push('taking the welcome pack put no gun in his armoury at all');
           if(!P2.equipped||P2.equipped==='fists')
             bad.push('taking the welcome pack left him holding nothing: the guns went to the armoury and his hands stayed empty, so his first raid issues him something else and the pack he just accepted sits at home');
'@ @'
           // r1329: the armoury and hands assertions retired. His ruling of 2026-09-13
           // sends the whole pack to the stash and equips nothing for him.
'@

# REPAIR 10.67: the whole check was the hands rule. It now guards the part that
# survives his ruling, that TAKE never touches a gun slot, for a fresh player and
# for one who already chose. The deploy arm asked for the pack gun in his hands on
# the first raid without his equipping it, which is the retired rule itself.
SubRx @'
  {v:'10.67',what:'the welcome pack guns go into his hands, so a new character deploys with what he was just given, and a player who already chose keeps his choice',
'@ @'
  {v:'10.67',what:'taking the welcome pack never touches a gun slot: a new character keeps empty hands and finds the guns in his stash, and a player who already chose keeps his choice (rewritten at r1329 for his ruling of 2026-09-13, which retired the hands rule)',
'@

SubRx @'
       if(P2.equipped!==packGuns[0]) bad.push('after taking the pack his first slot holds '+P2.equipped+', not the '+packGuns[0]+' he was given');
       if(P2.equippedSec!==packGuns[1]) bad.push('after taking the pack his second slot holds '+P2.equippedSec+', not the '+packGuns[1]+' he was given');
       if((P2.weapons||[]).indexOf(packGuns[0])<0) bad.push('the pack gun is not in the armoury either');
'@ @'
       if(P2.equipped!=='fists') bad.push('after taking the pack his first slot holds '+P2.equipped+', and the pack equips nothing for him');
       if(P2.equippedSec!=='none') bad.push('after taking the pack his second slot holds '+P2.equippedSec+', and the pack equips nothing for him');
       if((P2.stash||[]).indexOf('gun_'+packGuns[0])<0) bad.push('the pack gun is not in his stash, where the pack goes');
'@

SubRx @'
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
'@ @'
       // 2. r1329: the deploy arm is retired. It required the pack gun in his hands
       //    on the first raid without his equipping it, which is the rule his ruling
       //    of 2026-09-13 reversed.
'@

SubRx @'
       if(P2.equippedSec!==packGuns[1]) bad.push('the empty second slot was not filled by the pack (it holds '+P2.equippedSec+')');
'@ @'
       if(P2.equippedSec!=='none') bad.push('taking the pack filled his empty second slot with '+P2.equippedSec+', and the pack equips nothing for him');
'@

# REPAIR 10.29: the guns reach the stash, not the armoury.
SubRx @'
     if(P2.weapons.indexOf('smg')<0||P2.weapons.indexOf('carbine')<0) bad.push('the guns did not reach the armoury: '+P2.weapons.join(','));
'@ @'
     if(P2.stash.indexOf('gun_smg')<0||P2.stash.indexOf('gun_carbine')<0) bad.push('the guns did not reach the stash: '+P2.stash.join(','));   // r1329: his ruling, the pack goes to the stash
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
