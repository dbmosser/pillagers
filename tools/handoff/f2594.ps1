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

if ($s.Contains("  {v:'25.94',what:")) { throw "check 25.94 is in the fixture already" }

SubRx @'
  {v:'25.93',what:
'@ @'
  {v:'25.94',what:'his decision (U picks what G throws): with Frag on key 5 and Smoke on key 6 and the highlight on the gun, U switches which one G throws and says SMOKE CANISTER READY, the highlight stays on the gun, U again goes back to the Frag, G throws the kind U chose, G with the hand left on a kind that is on no key throws a kind that is, and U with no grenade on a key says so',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof cycleThrow!=='function') return 'SKIP: no belt here';
     if(!ITEMS.frag||!ITEMS.smoke||!ITEMS.decoy||typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: no grenades here, or a raid or a sim is live';
     var bad=[], s0=say, said=[], g=null, p=null, FX=THROWKEYS.indexOf('frag'), SX=THROWKEYS.indexOf('smoke'), DX=THROWKEYS.indexOf('decoy'), f0, sm0;
     function press(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; p.downed=false; p.roll=0; p.cooking=0; keys={}; g.paused=false;
       say=function(m){ said.push(String(m)); };
       g.bag=[]; g.pouch.frag=3; g.pouch.smoke=3; g.pouch.decoy=0; g.pouch.trip=0; g.hotAssign={4:'frag',5:'smoke'}; g.hotAuto={}; g.hotPruned={};
       g.hot=0; g.tsel=FX; said.length=0;
       press('KeyU');
       if(g.tsel!==SX) bad.push('ONE: U from the Frag left the throw kind on '+THROWKEYS[g.tsel]+', not smoke');
       if(g.hot!==0) bad.push('ONE: U moved the highlight to cell '+(g.hot+1)+', it stays on the gun (cell 1)');
       if(said.indexOf(ITEMS.smoke.name.toUpperCase()+' READY')<0) bad.push('ONE: U said '+JSON.stringify(said)+', not '+ITEMS.smoke.name.toUpperCase()+' READY');
       press('KeyU');
       if(g.tsel!==FX||g.hot!==0) bad.push('TWO: U again left the kind on '+THROWKEYS[g.tsel]+' and the highlight on cell '+(g.hot+1)+', not frag and cell 1');
       // THREE: G throws the kind U chose
       press('KeyU'); f0=g.pouch.frag; sm0=g.pouch.smoke; p.cooking=0; p.fired=false;
       press('KeyG');
       if(g.pouch.smoke!==sm0-1||g.pouch.frag!==f0) bad.push('THREE: G after U to smoke threw smoke '+(sm0-g.pouch.smoke)+' and frag '+(f0-g.pouch.frag)+' (one smoke wanted)');
       // FOUR: the hand is left on a kind that is on no key (decoy): G throws a kind that is
       p.cooking=0; g.throws.length=0; g.pouch.decoy=0; g.bag=['decoy']; g.tsel=DX; f0=g.pouch.frag; sm0=g.pouch.smoke; p.fired=false;
       press('KeyG');
       if((g.bag.indexOf('decoy')<0)) bad.push('FOUR: G with the hand on a Decoy that is on no key threw the Decoy');
       if(!(g.pouch.frag===f0-1||g.pouch.smoke===sm0-1)) bad.push('FOUR: G threw nothing from the keys (frag '+f0+' to '+g.pouch.frag+', smoke '+sm0+' to '+g.pouch.smoke+')');
       // FIVE: no grenade on a key
       g.pouch.frag=0; g.pouch.smoke=0; g.bag=[]; g.hotAssign={}; said.length=0; g.hot=0;
       press('KeyU');
       if(!said.some(function(m){ return /^NO THROWABLE/.test(m); })) bad.push('FIVE: U with no grenade on a key said '+JSON.stringify(said));
       if(g.hot!==0) bad.push('FIVE: U moved the highlight');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; g2.player.cooking=0; } if(g2.throws) g2.throws.length=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
