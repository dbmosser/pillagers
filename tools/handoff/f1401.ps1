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
  {v:'14.00',what:
'@ @'
  {v:'14.01',what:'the freebie pistol carries its own reserve: taking the free kit with a Support MG equipped at home gives the Scav Pistol a reserve of two pistol magazines, the same as with a Scav Pistol equipped (deploy and loadout audit 2026-09-15, finding 4)',
   run:function(){
     if(!(window.__startRaid&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot start a raid';
     if(typeof FREEKIT_GUN==='undefined'||!WEAPONS[FREEKIT_GUN]||!WEAPONS.lmg||!WEAPONS.pistol) return 'SKIP: no freebie kit in this build';
     var bad=[], P2=__P();
     var keep={w:(P2.weapons||[]).slice(),eq:P2.equipped,es:P2.equippedSec,fk:P2.freeKit,kit:(P2.kit||[]).slice(),kc:P2.kitChosen};
     var WANT=WEAPONS[FREEKIT_GUN].mag*2;
     function go(home){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.weapons=[home]; P2.equipped=home; P2.equippedSec='none'; P2.freeKit=1; P2.kit=[]; P2.kitChosen=1;
       __startRaid({mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var r={id:g.player.wep&&g.player.wep.id, reserve:g.player.reserve};
       if(!g.over) __endRaid('abandon');
       return r;
     }
     try{
       // CONTROL: a Scav Pistol at home.
       var C=go('pistol');
       if(C===null) return 'SKIP: no live raid';
       if(C.id!==FREEKIT_GUN) return 'SKIP: the free kit did not hand out its pistol ('+C.id+'), so nothing here can be measured';
       if(C.reserve!==WANT) bad.push('control: with a Scav Pistol at home the free pistol came up with '+C.reserve+' in reserve, not '+WANT);
       // THE FINDING: a Support MG at home.
       var A=go('lmg');
       if(A&&A.id===FREEKIT_GUN&&A.reserve!==WANT) bad.push('with a Support MG at home the free pistol came up with '+A.reserve+' rounds in reserve, not its own two magazines ('+WANT+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.weapons=keep.w; P2.equipped=keep.eq; P2.equippedSec=keep.es; P2.freeKit=keep.fk; P2.kit=keep.kit; P2.kitChosen=keep.kc; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
