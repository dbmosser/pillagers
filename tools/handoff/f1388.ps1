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
  {v:'13.87',what:
'@ @'
  {v:'13.88',what:'a revived pillager pays his gun once: reviving the same empty-bagged pillager holding an SMG twice leaves one SMG in the backpack, the one the first revive paid (searching and loot audit 2026-09-14, finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkRaider!=='function'||typeof updatePlayer!=='function'||!WEAPONS.smg||!ITEMS.gun_smg) return 'SKIP: no pillagers or SMG in this build';
     var bad=[];
     function copyW(id){ var w={},k; for(k in WEAPONS[id]) w[k]=WEAPONS[id][k]; return w; }
     function smgs(b){ var c=0; for(var i=0;i<b.length;i++) if(b[i]==='gun_smg') c++; return c; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.containers.length=0; g.bag=[]; g.hotAssign={}; g.hotAuto={}; g.trade=null;
       p.downed=false; p.iv=99;
       var R=mkRaider(p.x+30,p.y,null,false);
       R.bag=[]; R.wep=copyW('smg'); R.hp=0; R.downed=1; R.state='down';
       g.ents.length=0; g.ents.push(R);
       var K=__keysRef(); for(var k0 in K) K[k0]=false;
       function revive(){
         R.x=p.x+30; R.y=p.y; R.downed=1; R.state='down'; R.hp=0;
         K['KeyE']=false; g.revLock=0; updatePlayer(0.016);
         K['KeyE']=true; updatePlayer(0.016); K['KeyE']=false; updatePlayer(0.016);
       }
       // CONTROL: the first revive pays the gun in his hands.
       revive();
       if(R.downed) return 'SKIP: E beside the downed pillager did not revive him';
       if(smgs(g.bag)!==1) return 'SKIP: the first revive paid '+smgs(g.bag)+' SMGs, so the payout is not reached here';
       // THE FINDING: down him again and revive him again.
       revive();
       if(R.downed) return 'SKIP: the second E did not revive him';
       if(smgs(g.bag)!==1) bad.push('reviving the same pillager a second time paid another SMG from his hands ('+smgs(g.bag)+' in the backpack)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ var g2=__state(); if(g2){ if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
