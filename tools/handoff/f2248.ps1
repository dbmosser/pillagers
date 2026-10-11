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

if ($s.Contains("  {v:'22.48',what:")) { throw "check 22.48 is in the fixture already" }

SubRx @'
  {v:'22.47',what:
'@ @'
  {v:'22.48',what:'decision D3 never unslots a gun he carried out (from the review of build 4): the SMG on key 1 and the Longshot moved to key 3, with key 2 vacant or a Medkit, come home as gun 1 the SMG and gun 2 the Longshot, and his key 3 for the Longshot is kept',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(typeof hotbarSlots!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4) return 'SKIP: no four gun keys here';
     if(!(WEAPONS.smg&&WEAPONS.sniper&&ITEMS.gun_smg&&ITEMS.gun_sniper&&ITEMS.medkit&&WTIER&&WTIER.sniper>WTIER.smg)) return 'SKIP: the Longshot no longer outranks the SMG here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], arms=[{n:'key 2 vacant',plan:{2:'gun_sniper'},kit:[]},{n:'a Medkit on key 2',plan:{1:'medkit',2:'gun_sniper'},kit:['medkit']}], ai, snap=null, g, p, sl, q, staged=0;
     function gid(c){ return (c&&c.kind==='gun'&&!c.vacant)?String(c.icon||'').replace(/^gun_/,''):''; }
     for(ai=0;ai<arms.length;ai++){
       var A=arms[ai];
       try{
         __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         snap=JSON.parse(JSON.stringify(__P()));
         q=__P(); q.weapons=['smg','sniper']; q.equipped='smg'; q.equippedSec='sniper'; q.freeKit=0; q.kitSaved=null; q.kitBeforeFree=null;
         q.stash=A.kit.slice(); q.hotAssign=JSON.parse(JSON.stringify(A.plan));
         __deploy({kit:A.kit.slice(),safe:null,mapIx:0,seed:4242});
         g=__state(); p=g&&g.player;
         if(!g||g.over||!p) continue;
         if(!(p.wep&&p.wep.id==='smg'&&p.sec&&p.sec.id==='sniper'&&!p.wepIssued&&!p.secIssued)) continue;
         sl=hotbarSlots();
         if(!(gid(sl[0])==='smg'&&gid(sl[1])===''&&gid(sl[2])==='sniper')) continue;
         staged++;
         g.ents.length=0; p.downed=false; p.hp=100; p.iv=99;
         __endRaid('extract');
         q=__P();
         if(q.equipped!=='smg') bad.push(A.n+': gun 1 at home is '+q.equipped+', not the SMG on key 1 (decision D3)');
         if(q.equippedSec!=='sniper') bad.push(A.n+': gun 2 at home is '+q.equippedSec+' after extracting with the SMG on key 1 and the Longshot on key 3, so the Longshot he carried out is in no slot');
         if(!q.hotAssign||q.hotAssign[2]!=='gun_sniper') bad.push(A.n+': his key 3 for the Longshot was deleted by the extraction (plan '+JSON.stringify(q.hotAssign)+')');
       }catch(e){ bad.push(A.n+' threw: '+(e&&e.message||e)); }
       finally{
         try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
         try{ if(snap) __applyLoaded(snap); }catch(_r){}
         try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
       }
     }
     if(!staged) return 'SKIP: staging: no raid started with the SMG on key 1, key 2 showing no gun and the Longshot on key 3';
     return bad.length?bad.join('; '):null; }},
  {v:'22.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
