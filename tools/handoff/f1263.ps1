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

# v12.63 CHECK, inserted before the v12.62 entry. It pays the gear through the
# real payout with the gun already in the armoury, which is the state the card
# cannot see because it was written before he had it. The gun and its value both
# come off the game's own tables rather than out of this check. The control is
# the same payout with the gun NOT owned: it has to hand the gun over and say
# the armoury, or the fix would have turned every gun payout into cash.
SubRx @'
  {v:'12.62',what:'the Undercroft counter says what it did with his money, and a gun bought as a spare goes to the armoury instead of taking the slot off the gun in his hands; with empty hands a bought gun still arrives in them (2026-09-08 audit)',
'@ @'
  {v:'12.63',what:'a contract paying a gun he already owns pays what the gun is worth and says so, instead of handing over nothing and printing a receipt saying it paid; the same payout on a gun he does not own still hands over the gun (2026-09-08 audit)',
   run:function(){
     if(!window.__P) return 'SKIP: this fixture cannot read the profile';
     if(typeof payGear!=='function'||typeof WEAPONS==='undefined'||typeof ITEMS==='undefined') return 'SKIP: this build has no contract payout';
     // A gun the contract board can actually pay, that also has a value the
     // armoury knows, taken off the game own tables rather than named here.
     var GUN=null, k;
     for(k in WEAPONS){ if(ITEMS['gun_'+k]&&ITEMS['gun_'+k].val>0){ GUN=k; break; } }
     if(!GUN) return 'SKIP: no gun in this build carries a value the armoury knows';
     var VAL=ITEMS['gun_'+GUN].val;
     var bad=[], P2=__P();
     var keep={credits:P2.credits,weapons:(P2.weapons||[]).slice(),equipped:P2.equipped};
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       // THE FINDING: the card was written before he had this gun, and he has it now.
       P2.weapons=[GUN]; P2.equipped=GUN; P2.credits=0;
       var line1=String(payGear({kind:'wep',k:GUN})||'');
       if((P2.credits|0)!==VAL)
         bad.push('a contract paying the '+WEAPONS[GUN].name+' he already owns handed over nothing at all: the credits went from 0 to '+(P2.credits|0)+' against a gun worth '+VAL+', and the receipt still names the gun');
       if(P2.weapons.length!==1)
         bad.push('the armoury changed size on a payout of a gun he already had, so something was added twice');
       if(line1.indexOf(String(VAL))<0)
         bad.push('the receipt for a gun he already owns reads "'+line1+'" and does not say what he was actually paid');
       // CONTROL: the same payout on a gun he does NOT own must still be the gun.
       P2.weapons=[]; P2.equipped='fists'; P2.credits=0;
       var line2=String(payGear({kind:'wep',k:GUN})||'');
       if(P2.weapons.indexOf(GUN)<0)
         bad.push('control: a gun he does not own no longer reaches the armoury at all, so this build has turned every gun payout into cash');
       if((P2.credits|0)!==0)
         bad.push('control: a gun he does not own paid '+(P2.credits|0)+' credits as well as the gun');
       if(line2.indexOf('armoury')<0)
         bad.push('control: the receipt for a gun he did not own reads "'+line2+'" and no longer says where it went');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.credits=keep.credits; P2.weapons=keep.weapons; P2.equipped=keep.equipped; saveProfile(); }catch(_p){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.62',what:'the Undercroft counter says what it did with his money, and a gun bought as a spare goes to the armoury instead of taking the slot off the gun in his hands; with empty hands a bought gun still arrives in them (2026-09-08 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
