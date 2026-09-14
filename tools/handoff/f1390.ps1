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
  {v:'13.89',what:
'@ @'
  {v:'13.90',what:'an issued Bandage picked back up is still issued: dropping both issued Bandages and searching both piles back up leaves the issued count at two, while a found Bandage dropped and picked up stays found (searching and loot audit 2026-09-14, finding 6)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof dropItem!=='function'||typeof openContainer!=='function'||typeof trackIssuedBandages!=='function') return 'SKIP: no issued Bandage count in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.hotZone=null; g.hotAssign={}; g.hotAuto={};
       p.downed=false; p.iv=99;
       // THE FINDING: both issued Bandages dropped and searched back up.
       g.bag=['bandage','bandage']; g.issuedBandages=2; g.bandSeen=2;
       dropItem(0); trackIssuedBandages(); var pile1=g.containers[g.containers.length-1];
       dropItem(0); trackIssuedBandages(); var pile2=g.containers[g.containers.length-1];
       openContainer(pile1); openContainer(pile2); trackIssuedBandages();
       if(g.bag.length!==2) return 'SKIP: searching the two piles back up did not return both Bandages';
       if(g.issuedBandages!==2) bad.push('the two issued Bandages dropped and searched back up now count as '+(2-g.issuedBandages)+' found (issued '+g.issuedBandages+')');
       // GUARD: a found Bandage dropped and picked up stays found.
       g.bag=['bandage']; g.issuedBandages=0; g.bandSeen=1;
       dropItem(0); trackIssuedBandages(); var pile3=g.containers[g.containers.length-1];
       openContainer(pile3); trackIssuedBandages();
       if(g.issuedBandages!==0) bad.push('a found Bandage dropped and picked up became issued ('+g.issuedBandages+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
