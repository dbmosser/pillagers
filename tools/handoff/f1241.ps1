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

# v12.41 CHECK, inserted before the v12.40 entry. Two Smoke and nothing else,
# which is the pouch the finding names: the cell he presses is empty and the
# cell the old code walked to is not. It drives the derived cell, the assigned
# cell and the cook, and a control requires a cell that DOES hold a grenade to
# still throw it, so a fix that simply broke throwing would not read green.
SubRx @'
  {v:'12.40',what:'a merc told to loot on his own does not pick up a downed HOSTILE pillager who happens to share his crew number; he still picks up one who has thrown in with you, and an ordinary crew still picks its own up (2026-09-07 audit, merc-loots-hostiles)',
'@ @'
  {v:'12.41',what:'the key on an empty throwable cell spends nothing from another cell: it names what is missing and puts the gun up instead of quietly walking the hidden selector on and throwing the grenade you did have, on the derived cell, the assigned cell and the cook alike, while a cell that does hold one still throws it (closes the not-verified line on v12.08)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__P&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof useHot!=='function'||typeof setHot!=='function'||typeof hotbarSlots!=='function'||typeof doThrow!=='function'||typeof startCook!=='function') return 'SKIP: this build has no belt use path';
     if(!(THROWKEYS&&THROWKEYS.length===3&&ITEMS&&ITEMS.frag&&ITEMS.smoke)) return 'SKIP: this build does not carry three throwables';
     var bad=[];
     function cellOf(k){ var sl=hotbarSlots(); for(var i=0;i<sl.length;i++) if(sl[i]&&sl[i].k===k) return i; return -1; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid to throw in';
       var p=g.player;
       // TWO SMOKE AND NOTHING ELSE: the cell he presses is empty, and the cell
       // the old code walked to is not, which is the whole of the finding.
       g.pouch={smoke:2,decoy:0,frag:0};
       p.downed=false; p.roll=0; p.cooking=0; p.cookT=0; p.cookKind=null;
       var fragCell=cellOf('throw:frag'), smokeCell=cellOf('throw:smoke');
       if(fragCell<0||smokeCell<0) return 'SKIP: this build has no derived Frag and Smoke cells to press';
       // THE FINDING, the derived cell reached by the key.
       g.hot=-1; setHot(fragCell);
       if(g.tsel!==THROWKEYS.indexOf('frag')) return 'staging: pressing the Frag cell did not point the selector at the Frag';
       var thr0=g.throws.length, sm0=g.pouch.smoke, tsel0=g.tsel;
       g.msg=''; useHot();
       if(g.pouch.smoke!==sm0) bad.push('the key on the empty Frag cell spent a Smoke Canister: the pouch went from '+sm0+' to '+g.pouch.smoke);
       if(g.throws.length!==thr0) bad.push('the key on the empty Frag cell put '+(g.throws.length-thr0)+' throwable(s) in the air from a cell he did not press');
       if(g.tsel!==tsel0) bad.push('the key on the empty Frag cell walked the hidden selector from '+THROWKEYS[tsel0]+' to '+THROWKEYS[g.tsel]+', so the belt and the hand no longer agree');
       if(String(g.msg||'').indexOf(ITEMS.frag.name)<0) bad.push('the key on the empty Frag cell did not name what is missing; it said "'+(g.msg||'')+'"');
       // THE SAME THING BY THE ASSIGNED CELL, which is a second door to doThrow.
       g.pouch={smoke:2,decoy:0,frag:0}; g.hotAssign={}; g.hotAssign[1]='frag';
       g.hot=-1; setHot(1);
       var thr1=g.throws.length, sm1=g.pouch.smoke;
       g.msg=''; useHot();
       if(g.pouch.smoke!==sm1||g.throws.length!==thr1) bad.push('the assigned Frag cell spent a Smoke Canister: the pouch went from '+sm1+' to '+g.pouch.smoke+' and '+(g.throws.length-thr1)+' went in the air');
       g.hotAssign={};
       // AND THE COOK, which took the same branch.
       g.pouch={smoke:2,decoy:0,frag:0}; p.cooking=0; p.cookT=0; p.cookKind=null;
       g.hot=-1; setHot(fragCell);
       var sm2=g.pouch.smoke;
       g.msg=''; var ck=startCook();
       if(ck) bad.push('cooking an empty Frag cell reported that a grenade was in his hand');
       if(g.pouch.smoke!==sm2) bad.push('cooking the empty Frag cell pulled the pin on a Smoke Canister: the pouch went from '+sm2+' to '+g.pouch.smoke);
       if(p.cooking) bad.push('cooking the empty Frag cell left a live grenade in his hand, kind '+p.cookKind);
       p.cooking=0; p.cookT=0; p.cookKind=null;
       // CONTROL: a cell that DOES hold one still throws it, so a fix that simply
       // stopped throwing altogether cannot read green here.
       g.pouch={smoke:2,decoy:0,frag:0};
       g.hot=-1; setHot(smokeCell);
       var thr3=g.throws.length, sm3=g.pouch.smoke;
       useHot();
       if(g.pouch.smoke!==sm3-1) bad.push('control: the key on a Smoke cell holding two did not spend one (pouch '+sm3+' to '+g.pouch.smoke+')');
       if(g.throws.length!==thr3+1) bad.push('control: the key on a Smoke cell holding two put nothing in the air');
       else if(g.throws[g.throws.length-1].kind!=='smoke') bad.push('control: the Smoke cell threw a '+g.throws[g.throws.length-1].kind);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz){ gz.hotAssign={}; if(gz.throws) gz.throws.length=0;
         if(gz.player){ gz.player.cooking=0; gz.player.cookT=0; gz.player.cookKind=null; } } }catch(_e){}
       try{ var g4=__state(); if(g4&&!g4.over){ g4.player.downed=false; __endRaid('abandon'); } }catch(_e2){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.40',what:'a merc told to loot on his own does not pick up a downed HOSTILE pillager who happens to share his crew number; he still picks up one who has thrown in with you, and an ordinary crew still picks its own up (2026-09-07 audit, merc-loots-hostiles)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
