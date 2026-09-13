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

# v13.23 CHECK, inserted before the v13.22 entry.
#
# THE SAME INSTRUMENT AS CHECK 8192: deploy at 1920x1080, draw the full panel,
# and read what was actually painted through __textTrace.
#
# BUT NOT THE SAME NEEDLE. Check 8192 looks for each label on the drawn panel,
# and a single B is already painted inside BKSP, so a B row that never drew would
# pass it. This check looks for the row description, which appears nowhere else.
#
# TWO HALVES, because a row in the table that is not drawn helps nobody, and a
# drawn line with no table row would mean the text came from somewhere that can
# drift away from the bindings.
SubRx @'
  {v:'13.22',what:'the what-is-new card names what changed how you play since v13.10, high enough to be drawn: B backs out of menus and a found armour plate goes to the backpack; the stamp is not older than what it lists; and no entry still claims the X key is gone',
'@ @'
  {v:'13.23',what:'the full key list behind H names B, and actually draws the row, so the key he was given because Escape is not working is on the reference he opens to look keys up',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__textTrace&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and read the drawn text';
     if(typeof LEGEND==='undefined') return 'SKIP: this build has no key table';
     if(typeof PAD!=='undefined'&&PAD&&PAD.on) return 'SKIP: a controller is connected, so the keyboard list is not the one drawn';
     var bad=[];
     var row=null, i, j;
     for(i=0;i<LEGEND.length;i++) for(j=0;j<LEGEND[i][1].length;j++){
       var r=LEGEND[i][1][j];
       if(r&&r[0]==='B') row=r;
     }
     if(!row)
       bad.push('the full key list has no B row, so the key he was given because Escape is not working for him is on no list a player can look up, and the hire orders B has given since v3.73 never have been either');
     else if(String(row[1]).indexOf('back out')<0)
       bad.push('the B row on the key list reads ['+row[1]+'], which does not say B backs out of a menu');
     var keep=null, g=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_f){}
       if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be drawn';
       __deploy({kit:[],mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid to open the key list in';
       keep=g.legendOn; g.legendOn=2;
       var lines=[]; try{ lines=__textTrace(function(){ __frame(0.016); }); }catch(_t){}
       var full=''; for(i=0;i<lines.length;i++) full+=' | '+lines[i].t;
       if(!full) return 'SKIP: the full key list drew no text at all';
       // THE DESCRIPTION, not the letter: a lone B is already painted inside BKSP.
       if(full.indexOf('back out of a menu')<0)
         bad.push('the full key list does not draw a line saying B backs out of a menu, so even with the row in the table nothing on the screen tells him');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g) g.legendOn=keep; }catch(_k){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.22',what:'the what-is-new card names what changed how you play since v13.10, high enough to be drawn: B backs out of menus and a found armour plate goes to the backpack; the stamp is not older than what it lists; and no entry still claims the X key is gone',
'@

# HARNESS REPAIR, MINE, FROM v13.18. P.wirtLotBought is a profile field v13.18
# added, and __cleanProfile resets only a fixed list, so it never cleared it.
# Every check that presses Wirt's Buy (v9.11, and v11.61 itself) left the counter
# reading Bought in the saved profile, and the next check to open that counter
# inside the same five-minute window found no button: the v13.22 corpus came back
# with THREE skips instead of two, the third being v11.61, "no Buy button on the
# counter". A skipped check is a guard that silently stopped guarding.
#
# REPRODUCED, NOT ARGUED: with the flag set to the current window, v11.61 returns
# SKIP no Buy button; with it cleared, the same check runs and passes.
#
# AND A SECOND PATH: v11.61 moves the clock forward before it presses Buy, so the
# purchase is recorded against a FUTURE window, which springs on whatever check
# runs once real time reaches it. Clearing the field at the baseline covers both.
#
# The same class as the v10.48 night and v10.54 outfit leaks: a new profile field
# needs a line here, or a later check inherits it.
SubRx @'
  P.cond='day';   // v10.48: a night a check left in the SAVED profile ran every fingerprint after it after dark
  P.cosOutfit='outnone';   // v10.54: a suit left on by a check would overrule every sprite check after it
'@ @'
  P.cond='day';   // v10.48: a night a check left in the SAVED profile ran every fingerprint after it after dark
  P.cosOutfit='outnone';   // v10.54: a suit left on by a check would overrule every sprite check after it
  delete P.wirtLotBought;   // v13.23: a Limited Time Offer one check bought left the counter reading Bought for the next, and v11.61 skipped
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
