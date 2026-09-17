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
  {v:'15.22',what:
'@ @'
  {v:'15.23',what:'only a Medkit gets him back to 100: out of combat, regen from 80 stops at 85 with the heal ceilings on, and runs to 100 with them off (his ruling of 2026-09-16)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof tickRegen!=='function'||typeof healCeil!=='function'||!ITEMS.bandage) return 'SKIP: no regen or heal ceiling in this build';
     var bad=[], g=null, keepCaps=CFG.healCaps, p=null, keep=null;
     function regenFrom(hp){ p.hp=hp; p.combatT=999; p.regenAcc=0; p.downed=false; for(var i=0;i<240;i++) tickRegen(0.5); return p.hp; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       p=g.player; keep={hp:p.hp,combatT:p.combatT,regenAcc:p.regenAcc};
       // CONTROL: with the ceilings off, regen from 80 runs to full, so a rise is visible.
       CFG.healCaps=0;
       var free=regenFrom(80);
       if(free<p.maxhp) return 'SKIP: regen from 80 reached only '+free+' with the ceilings off here';
       CFG.healCaps=keepCaps;
       var top=healCeil(ITEMS.bandage);
       var capped=regenFrom(80);
       if(capped>top) bad.push('out of combat, regen from 80 reached '+capped+', past the '+top+' only a Medkit may go beyond');
       if(capped<top) bad.push('out of combat, regen from 80 stopped at '+capped+', short of '+top);
       var high=regenFrom(92);
       if(high!==92) bad.push('regen moved health that was already at 92 to '+high);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       CFG.healCaps=keepCaps;
       try{ if(p&&keep){ p.hp=keep.hp; p.combatT=keep.combatT; p.regenAcc=keep.regenAcc; } }catch(_k){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
