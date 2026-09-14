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
  {v:'13.99',what:
'@ @'
  {v:'14.00',what:'key 1 picks up the gun bound to it: going up with an SMG in the backpack bound to key 1, pressing 1 puts the SMG in a hand, as pressing 2 does when it is bound to key 2 (deploy and loadout audit 2026-09-15, finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof raidKey!=='function'||!ITEMS.gun_smg||!WEAPONS.smg) return 'SKIP: no belt keys or SMG in this build';
     var bad=[], P2=__P();
     var keep={ha:JSON.stringify(P2.hotAssign||{}),w:(P2.weapons||[]).slice(),eq:P2.equipped,es:P2.equippedSec,st:(P2.stash||[]).slice()};
     function go(slot){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.weapons=[]; P2.equipped='fists'; P2.equippedSec='none';
       P2.hotAssign={}; P2.hotAssign[slot]='gun_smg';
       __deploy({kit:['gun_smg'],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player;
       if(g.bag.indexOf('gun_smg')<0&&!(p.wep&&p.wep.id==='smg')&&!(p.sec&&p.sec.id==='smg')) return {skip:'the SMG did not come up'};
       if((p.wep&&p.wep.id==='smg')||(p.sec&&p.sec.id==='smg')) return {skip:'the SMG was already in a hand at the start'};
       var K=__keysRef(); for(var k0 in K) K[k0]=false;
       raidKey('Digit'+(slot+1),false,null); K['Digit'+(slot+1)]=false;
       var r={up:!!((p.wep&&p.wep.id==='smg')||(p.sec&&p.sec.id==='smg'))};
       if(!g.over) __endRaid('abandon');
       return r;
     }
     try{
       // CONTROL: bound to key 2, pressing 2 equips it.
       var C=go(1);
       if(C===null) return 'SKIP: no live raid';
       if(C.skip) return 'SKIP: '+C.skip;
       if(!C.up) return 'SKIP: pressing the key of a backpack gun on key 2 did not equip it, so nothing here can be measured';
       // THE FINDING: bound to key 1, pressing 1.
       var A=go(0);
       if(A&&!A.skip&&!A.up) bad.push('an SMG in the backpack bound to key 1 stayed in the backpack when 1 was pressed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ P2.hotAssign=JSON.parse(keep.ha); P2.weapons=keep.w; P2.equipped=keep.eq; P2.equippedSec=keep.es; P2.stash=keep.st; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
