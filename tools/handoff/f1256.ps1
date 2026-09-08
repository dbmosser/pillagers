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

# v12.56 CHECK, inserted before the v12.55 entry. Two kinds of grenade and no
# third, so the cycle has exactly one place to go and the answer cannot be a
# coincidence. The key is the real key on the real window. The controls are the
# two ways a fix could cheat: a man carrying one kind only must be left where he
# was, and the cell the highlight lands on must be the cell that actually holds
# what he chose rather than any cell at all.
SubRx @'
  {v:'12.55',what:'an imported ghost carries his engagement range and his damage with the gun he is handed, instead of keeping the range of the body he arrived in; a ghost handed the gun that body already carries is left exactly as he was (2026-09-07 audit)',
'@ @'
  {v:'12.56',what:'Q moves the tactical belt as well as the hand: after choosing a different grenade the highlight, the caption and the hidden selector all name the same one, and a man carrying only one kind is left exactly where he was (2026-09-06 in-raid audit, the half v12.41 left)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__keys)) return 'SKIP: this fixture cannot deploy a raid and press a key';
     if(typeof hotbarSlots!=='function'||typeof hotSel!=='function'||typeof cycleThrow!=='function') return 'SKIP: this build has no tactical belt or no cycle to press';
     if(!(THROWKEYS&&THROWKEYS.length===3&&ITEMS&&ITEMS.smoke&&ITEMS.frag)) return 'SKIP: this build does not carry three throwables';
     var bad=[];
     function press(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); }
     function release(code,key){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true,cancelable:true})); }
     function cellOf(k){ var sl=hotbarSlots(), i; for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].k===k) return i; return -1; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid to press a key in';
       var p=g.player, K=__keys(), k;
       for(k in K) delete K[k];
       p.downed=false; p.roll=0; p.iv=99;
       // TWO KINDS AND NO THIRD, so the cycle has exactly one place to go.
       g.pouch={smoke:2,decoy:0,frag:2}; g.hotAssign={};
       var smokeCell=cellOf('throw:smoke'), fragCell=cellOf('throw:frag');
       if(smokeCell<0||fragCell<0) return 'SKIP: this build has no derived Smoke and Frag cells to point at';
       g.hot=-1; setHot(smokeCell);
       if(g.tsel!==THROWKEYS.indexOf('smoke')) return 'staging: pointing the belt at the Smoke cell did not point the selector at the Smoke';
       g.msg='';
       press('KeyQ','q'); release('KeyQ','q');
       var want=THROWKEYS.indexOf('frag');
       if(g.tsel!==want) return 'SKIP: the key did not move the selector at all, so there is no choice here to follow';
       // THE FINDING: everything he can see must now name the same grenade.
       var sl=hotbarSlots(), hi=hotSel(), cell=sl[hi];
       if(hi!==fragCell)
         bad.push('choosing the Frag left the belt highlighting cell '+(hi+1)+' and not the Frag cell '+(fragCell+1)+', so the highlight is on a grenade he is no longer holding while the trigger throws the one he chose');
       if(cell&&cell.k!=='throw:frag')
         bad.push('the highlighted cell is '+cell.k+' after choosing the Frag, so the belt and the hand name different things');
       if(String(g.msg||'').indexOf(ITEMS.frag.name)<0)
         bad.push('choosing the Frag did not say so; the line reads "'+(g.msg||'')+'"');
       // CONTROL ONE: with only one kind carried there is nowhere to go, and the
       // highlight must be left exactly where it was.
       g.pouch={smoke:2,decoy:0,frag:0};
       g.hot=-1; setHot(smokeCell);
       var hot0=hotSel(), tsel0=g.tsel;
       press('KeyQ','q'); release('KeyQ','q');
       if(hotSel()!==hot0) bad.push('control: with only one kind of grenade carried the key still moved the highlight, from cell '+(hot0+1)+' to cell '+(hotSel()+1)+', so it is moving on nothing');
       if(g.tsel!==tsel0) bad.push('control: with only one kind carried the key still moved the selector');
       // CONTROL TWO: the highlight lands on the cell that HOLDS it, even when
       // that cell is one he dragged the grenade onto himself.
       g.pouch={smoke:2,decoy:0,frag:2}; g.hotAssign={}; g.hotAssign[1]='frag';
       g.hot=-1; setHot(smokeCell);
       press('KeyQ','q'); release('KeyQ','q');
       var sl2=hotbarSlots(), hi2=hotSel(), c2=sl2[hi2];
       if(!(c2&&(c2.k==='throw:frag'||c2.itemKey==='frag')))
         bad.push('with the Frag dragged onto a key of his own, choosing it highlighted '+((c2&&c2.k)||'nothing')+' instead of the cell that holds it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ release('KeyQ','q'); var K3=__keys(); for(var k3 in K3) delete K3[k3]; }catch(_k){}
       try{ var gz=__state(); if(gz){ gz.hotAssign={}; if(gz.player) gz.player.iv=0; } }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.55',what:'an imported ghost carries his engagement range and his damage with the gun he is handed, instead of keeping the range of the body he arrived in; a ghost handed the gun that body already carries is left exactly as he was (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
