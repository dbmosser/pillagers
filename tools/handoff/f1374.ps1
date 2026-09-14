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
  {v:'13.73',what:
'@ @'
  {v:'13.74',what:'a second copy of a gun you own is kept when you extract holding it: a found carbine in hand with a carbine in the armoury adds one to the stash, while the same carbine in the backpack still adds one and your own armoury carbine in hand adds none (downed and extraction audit 2026-09-14, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(typeof rollFieldGun!=='function'||!WEAPONS.carbine||!ITEMS.gun_carbine) return 'SKIP: no field carbine in this build';
     var bad=[], P2=__P();
     var keep={w:(P2.weapons||[]).slice(),st:(P2.stash||[]).slice(),eq:P2.equipped,es:P2.equippedSec};
     function copies(){ var c=0, st=P2.stash||[]; for(var i=0;i<st.length;i++) if(st[i]==='gun_carbine') c++; return c; }
     function run(hand,fromArm,inBag){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player;
       g.ents.length=0; p.downed=false; g.pedCarry=0; g.bag=[]; g.issuedBandages=0; g.spliced=null;
       P2.weapons=['carbine']; P2.equipped='carbine'; P2.equippedSec='none';
       p.sec=WEAPONS.fists; p.secIssued=true; p.secFromArmory=false;
       if(hand){ p.wep=rollFieldGun('carbine'); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=!!fromArm; }
       else { p.wep=WEAPONS.fists; p.wepIssued=true; p.wepFromArmory=false; }
       if(inBag) g.bag.push('gun_carbine');
       var before=copies();
       __endRaid('extract');
       return {added:copies()-before, owned:(P2.weapons||[]).indexOf('carbine')>=0};
     }
     try{
       // THE FINDING: a found carbine in hand, a carbine already in the armoury.
       var A=run(true,false,false);
       if(A===null) return 'SKIP: no live raid to extract from';
       if(A.added!==1) bad.push('extracting with a found carbine in hand while owning one added '+A.added+' to the stash; the found gun vanished');
       if(!A.owned) bad.push('and the armoury carbine was lost');
       // CONTROL: the same carbine carried in the backpack goes to the stash.
       var B=run(false,false,true);
       if(B&&B.added!==1) bad.push('control: a carbine in the backpack while owning one added '+B.added+' to the stash, so this check cannot see a stash copy');
       // CONTROL: your own armoury carbine in hand is not copied.
       var C=run(true,true,false);
       if(C&&C.added!==0) bad.push('your own armoury carbine carried home was copied into the stash ('+C.added+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.weapons=keep.w; P2.stash=keep.st; P2.equipped=keep.eq; P2.equippedSec=keep.es; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
