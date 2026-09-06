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

# v11.96 CHECK, inserted before the v11.95 entry. The profile is set to own
# one Scav Pistol with the free kit chosen, a raid is deployed and ended by
# death; the pistol must still be owned and the card must count no gun lost.
SubRx @'
  {v:'11.95',what:'a load with no save sets the menu zoom to 1.3 and runs the Settings pass that arms the wording watcher, the same as a load with a save (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'11.96',what:'dying with the free kit does not delete the Scav Pistol you own, and the loaner is not counted as a gun you lost (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], P2=__P(), keepW=(P2.weapons||[]).slice(), keepEq=P2.equipped, keepFree=P2.freeKit, keepKit=(P2.kit||[]).slice(), keepChosen=P2.kitChosen;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.weapons=['pistol']; P2.equipped='fists'; P2.freeKit=1; P2.kit=[]; P2.kitChosen=1; saveProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g.freeKit) return 'SKIP: the deploy did not take the free kit';
       if(!p.wep||p.wep.id!=='pistol') bad.push('control: the free kit did not issue a Scav Pistol (holding '+(p.wep&&p.wep.id)+')');
       p.downed=false; __endRaid('dead');
       if(P2.weapons.indexOf('pistol')<0) bad.push('dying with the free kit deleted the Scav Pistol you own');
       var txt=''; try{ txt=((document.getElementById('outcome')||{}).innerText||'').replace(/\s+/g,' '); }catch(_t){}
       if(/and 1 gun/.test(txt)) bad.push('the card counts the loaner as a gun you lost');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ P2.weapons=keepW; P2.equipped=keepEq; P2.freeKit=keepFree; P2.kit=keepKit; P2.kitChosen=keepChosen; try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.95',what:'a load with no save sets the menu zoom to 1.3 and runs the Settings pass that arms the wording watcher, the same as a load with a save (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
