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
  {v:'13.63',what:
'@ @'
  {v:'13.64',what:'a Medkit is not spent at full health after a Bandage ran into its ceiling: the stored ceiling clears with the queue, so the Medkit is refused and kept, while at 50 health it is still used (in-raid audit 2026-09-14, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof useMedical!=='function'||typeof tickHeal!=='function'||!ITEMS.medkit) return 'SKIP: no medical verbs in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.ents.length=0; p.iv=99; p.prep=null; p.downed=false;
       // A Bandage heal that has reached its 85 with some of its queue undelivered.
       p.hp=85; p.healQ=15; p.healRate=10; p.healCap=85;
       tickHeal(0.05);
       // Health back at full by another route, then the Medkit.
       p.hp=p.maxhp; p.healQ=0; p.prep=null; g.bag=['medkit'];
       useMedical();
       if(g.bag.indexOf('medkit')<0) bad.push('at full health after a Bandage ran into its ceiling, the Medkit was used (stored ceiling '+p.healCap+')');
       // CONTROL: at 50 health with nothing running, the Medkit is used.
       p.hp=50; p.healQ=0; p.healRate=0; p.healCap=undefined; p.prep=null; g.bag=['medkit'];
       useMedical();
       if(g.bag.indexOf('medkit')>=0) bad.push('control: at 50 health the Medkit was not used, so this check cannot see a use');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.prep=null; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
