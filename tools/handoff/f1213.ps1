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

# v12.13 CHECK, inserted before the v12.12 entry. The lift question is asked
# with a belt key bound to a stash item, the FREEBIE KIT answer is taken, and
# the plan must be empty with a free-kit raid started.
SubRx @'
  {v:'12.12',what:'the going-down toast tells the truth on the second down: it no longer sends you to F once the one self-revive is spent, and still does on the first (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'12.13',what:'taking the freebie kit at the lift clears the tactical belt plan the same as the stash screen button does, so no key points at an item left in the stash (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__P&&window.__showScreen)) return 'SKIP: this fixture cannot drive the lift';
     if(typeof askKit!=='function') return 'SKIP: no lift question in this build';
     var bad=[], P2=__P(), keepKit=(P2.kit||[]).slice(), keepHot=P2.hotAssign, keepGun=P2._gunSlot, keepFree=P2.freeKit, keepKBF=P2.kitBeforeFree, keepStash=(P2.stash||[]).slice(), keepChosen=P2.kitChosen, keepEq=P2.equipped, keepSec=P2.equippedSec, keepW=(P2.weapons||[]).slice(), keepKS=P2.kitSaved;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       G=null; keys={}; __showScreen('hub');
       P2.stash=['medkit','plate']; P2.kit=['medkit']; P2.hotAssign={4:'medkit'}; P2._gunSlot=null; P2.freeKit=0; P2.kitChosen=0; saveProfile();
       askKit();
       if(typeof ASKALT!=='function') bad.push('control: the lift question set no freebie answer');
       else ASKALT();
       var g=__state();
       if(!g||!g.freeKit) bad.push('control: the freebie answer did not start a free-kit raid');
       var ks=Object.keys(P2.hotAssign||{});
       if(ks.length) bad.push('the belt plan still holds '+ks.length+' key'+(ks.length===1?'':'s')+' ('+ks.map(function(k){ return k+':'+P2.hotAssign[k]; }).join(',')+') after the freebie kit was taken at the lift');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var m=document.getElementById('askmodal'); if(m) m.classList.remove('on'); }catch(_m){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){}
       P2.kit=keepKit; P2.hotAssign=keepHot||{}; P2._gunSlot=keepGun; P2.freeKit=keepFree; P2.kitBeforeFree=keepKBF; P2.stash=keepStash; P2.kitChosen=keepChosen; P2.equipped=keepEq; P2.equippedSec=keepSec; P2.weapons=keepW; P2.kitSaved=keepKS;
       try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.12',what:'the going-down toast tells the truth on the second down: it no longer sends you to F once the one self-revive is spent, and still does on the first (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
