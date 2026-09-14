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
  {v:'13.75',what:
'@ @'
  {v:'13.76',what:'backing out at once does not delete a gun you bagged: the armoury carbine dragged into the backpack and the raid abandoned inside a second is back in the armoury, as it is when the same abandon comes five seconds in (downed and extraction audit 2026-09-14, finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(typeof bagHeldGun!=='function'||!WEAPONS.carbine) return 'SKIP: no gun bagging in this build';
     var bad=[], P2=__P();
     var keep={w:(P2.weapons||[]).slice(),st:(P2.stash||[]).slice(),eq:P2.equipped,es:P2.equippedSec};
     function run(later){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player, w={}, k;
       for(k in WEAPONS.carbine) w[k]=WEAPONS.carbine[k];
       g.ents.length=0; p.downed=false; g.spliced=null;
       P2.weapons=['carbine']; P2.equipped='carbine'; P2.equippedSec='none';
       p.wep=w; p.ammo=w.mag; p.wepIssued=false; p.wepFromArmory=true; p.swapped=false;
       p.sec=WEAPONS.fists; p.secIssued=true; p.secFromArmory=false;
       if(!bagHeldGun('gunA')) return {skip:'the belt would not bag the carbine'};
       if(P2.weapons.indexOf('carbine')>=0) return {skip:'bagging did not take the carbine off the armoury list'};
       if(later){ g.timeLeft=(g.raidLen===undefined?CFG.raidSec:g.raidLen)-5; g.t=5; }
       __endRaid('abandon');
       return {owned:P2.weapons.indexOf('carbine')>=0};
     }
     try{
       // THE FINDING: bag it and back out at once.
       var A=run(false);
       if(A===null) return 'SKIP: no live raid';
       if(A.skip) return 'SKIP: '+A.skip;
       if(!A.owned) bad.push('bagging the armoury carbine and abandoning inside a second deleted it from the armoury');
       // CONTROL: the same abandon five seconds in puts it back.
       var B=run(true);
       if(B&&!B.skip&&!B.owned) bad.push('control: an abandon five seconds in did not put the bagged carbine back, so this check cannot see a restore');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.weapons=keep.w; P2.stash=keep.st; P2.equipped=keep.eq; P2.equippedSec=keep.es; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
