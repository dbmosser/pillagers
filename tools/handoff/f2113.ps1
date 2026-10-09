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

if ($s.Contains("  {v:'21.13',what:")) { throw "check 21.13 is in the fixture already" }

SubRx @'
  {v:'21.12',what:
'@ @'
  {v:'21.13',what:'RANDOM FROM STASH gives two different random guns he owns, hand and back, never the Scav Pistol while he owns another gun; with one other gun the back slot is empty',
   run:function(){
     if(typeof kitFill!=='function'||!WEAPONS.pistol) return 'SKIP: no random kit here';
     var bad=[], w0=P.weapons, e0=P.equipped, s0=P.equippedSec, k0=P.kit, i, seenA={}, seenB={}, nA=0, nB=0;
     try{
       P.weapons=['pistol','rifle','shotgun','smg'];
       for(i=0;i<60;i++){
         P.equipped='pistol'; P.equippedSec='pistol';
         kitFill(true);
         if(P.equipped==='pistol') bad.push('the hand gun was the Scav Pistol');
         if(P.equippedSec==='pistol') bad.push('the back gun was the Scav Pistol');
         if(!P.equippedSec||P.equippedSec==='none') bad.push('no second gun with three others owned');
         else if(P.equippedSec===P.equipped) bad.push('the same gun in both slots');
         seenA[P.equipped]=1; seenB[P.equippedSec]=1;
         if(bad.length) break;
       }
       nA=Object.keys(seenA).length; nB=Object.keys(seenB).length;
       if(!bad.length&&(nA<2||nB<2)) bad.push('the picks are not random ('+nA+' hand guns and '+nB+' back guns over 60 rolls)');
       P.weapons=['pistol','rifle']; P.equipped='pistol'; P.equippedSec='pistol';
       kitFill(true);
       if(P.equipped!=='rifle') bad.push('with the Scav Pistol and one rifle the hand gun was '+P.equipped);
       if(P.equippedSec!=='none') bad.push('with the Scav Pistol and one rifle the back gun was '+P.equippedSec+', not empty');
       P.weapons=['pistol']; P.equipped='fists'; P.equippedSec='none';
       kitFill(true);
       if(P.equipped!=='pistol') bad.push('with only the Scav Pistol owned it was not taken ('+P.equipped+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.weapons=w0; P.equipped=e0; P.equippedSec=s0; P.kit=k0; }
     return bad.length?bad.slice(0,3).join('; '):null; }},
  {v:'21.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
