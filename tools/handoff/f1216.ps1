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

# v12.16 CHECK, inserted before the v12.15 entry. The real button, pressed
# through its own onclick, twice; then again with an item sold in between.
SubRx @'
  {v:'12.15',what:'the safe pocket refuses a grenade and an ammo box, which cannot come home from it, still takes a medkit, and a saved pocket on a grenade is cleared on load (2026-09-06 menu audit)',
'@ @'
  {v:'12.16',what:'taking the freebie kit keeps what was packed aside and USE MY OWN GEAR puts the packing and the belt plan back, minus anything sold in between (2026-09-06 menu audit)',
   run:function(){
     if(typeof renderFreeKit!=='function'||!window.__P||!window.__hubEnter) return 'SKIP: this fixture cannot reach the freebie kit';
     var bad=[];
     function btn(){ return document.querySelector('.fkbtn'); }
     function press(){ var b=btn(); if(!b||!b.onclick) return 'no button'; try{ b.onclick(); }catch(e){ return 'threw '+(e&&e.message||e); } return null; }
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       var P=__P();
       P.stash=['medkit','plate','frag']; P.kit=['medkit','plate']; P.hotAssign={2:'medkit'}; P.freeKit=0; P.kitSaved=null;
       renderFreeKit();
       if(!btn()) return 'SKIP: the freebie kit button was not drawn';
       var e1=press(); if(e1) bad.push('control: the first press failed ('+e1+')');
       if(!P.freeKit) bad.push('control: the first press did not take the kit');
       if((P.kit||[]).length) bad.push('control: the kit was not emptied while the free kit is taken (his rule)');
       var e2=press(); if(e2) bad.push('control: the second press failed ('+e2+')');
       if(P.freeKit) bad.push('control: the second press did not switch back');
       if((P.kit||[]).join(',')!=='medkit,plate') bad.push('switching back did not restore the packing (kit '+(P.kit||[]).join(',')+')');
       if(!P.hotAssign||P.hotAssign[2]!=='medkit') bad.push('switching back did not restore the belt plan');
       // SOLD IN BETWEEN: only what is still in the stash comes back.
       press(); P.stash=['medkit','frag']; press();
       if((P.kit||[]).join(',')!=='medkit') bad.push('with the plate sold in between, switching back restored '+(P.kit||[]).join(',')+' and not medkit alone');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.15',what:'the safe pocket refuses a grenade and an ammo box, which cannot come home from it, still takes a medkit, and a saved pocket on a grenade is cleared on load (2026-09-06 menu audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
