$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS NOTE (2026-09-07 morning): "inventorry still wonky -- if i run out of item,
# it should disappear from the tsa, right? I just tried to drag bandaids and
# they didn't come over". Traced by the 2026-09-07 read-only notes investigation
# and verified by reading at v12.26. Two mechanisms stack on the Stash screen.
# The belt plan outlives the raid (v8.64 dropDeadKeys keeps every key whose item
# is still in the stash or the kit) but the packing does not (commitKit empties
# P.kit at ascent), so after a raid a key can sit on Bandage with none packed.
# The backpack column hides one packed copy per key (v6.60, "what is on the
# belt is not in the backpack"), so the single copy a stash drop packs vanished
# into that hide: no cell, no count, no words. The plan cell drew the phantom
# key exactly like a packed one (v11.96 made x1 silent). And in a raid, a key
# on an item the bag has none of returned silently (useHot), so the dark cell
# v9.03 keeps on purpose read as a dead key.
#
# THREE EDITS. (A) A stash drop for an item bound to a key with nothing packed
# takes the belt-cell route: planPut packs half the stack (v11.96) and a line
# says which key took it. (B) A bound key with nothing packed shows a 0 on the
# plan. (C) A spent belt key in a raid says "No <item> left." The v9.03 dark
# cell itself is NOT changed here: his answer 16 asked for it to stay and go
# darker, and today's note asks for it to disappear; that is his call, in the
# report.
SubRx @'
    if(picked>=held){ say2('You only have '+held+' of those.'); return; }
    P.kit.push(key); saveProfile(); try{ sfx('pick'); }catch(e){} renderHub();
'@ @'
    if(picked>=held){ say2('You only have '+held+' of those.'); return; }
    // v12.27, HIS NOTE: "I just tried to drag bandaids and they didn't come over".
    // The belt plan outlives the raid (v8.64) but the packing does not (commitKit),
    // so a key can sit on an item with none packed; the backpack column hides one
    // copy per key (v6.60), and the single copy this drop packed vanished into
    // that hide: no cell, no count, no words. A drop for an item on an empty key
    // is putting it on that key, so it takes the belt-cell route: half the stack
    // (v11.96) and a line that says where it went.
    var _bk=-1; for(var _bq in (P.hotAssign||{})) if(P.hotAssign[_bq]===key) _bk=+_bq;
    if(_bk>=0&&packedCount(key)<1){
      var _bw=planPut(_bk,key);
      if(_bw){ say2(_bw); try{ sfx('clank'); }catch(e){} return; }
      var _bn=packedCount(key);
      say2(_bn+' '+ITEMS[key].name+(_bn>1?'s':'')+' packed, on key '+(_bk+1)+'.');
      try{ sfx('pick'); }catch(e){} renderHub(); return;
    }
    P.kit.push(key); saveProfile(); try{ sfx('pick'); }catch(e){} renderHub();
'@
SubRx @'
    if(picked>=held){ say2('You only have '+held+' of those.'); return; }
    P.kit.push(key); saveProfile(); renderHub();
'@ @'
    if(picked>=held){ say2('You only have '+held+' of those.'); return; }
    // v12.27: the same rule on the HTML5 twin of the drop above.
    var _bk2=-1; for(var _bq2 in (P.hotAssign||{})) if(P.hotAssign[_bq2]===key) _bk2=+_bq2;
    if(_bk2>=0&&packedCount(key)<1){
      var _bw2=planPut(_bk2,key);
      if(_bw2){ say2(_bw2); return; }
      var _bn2=packedCount(key);
      say2(_bn2+' '+ITEMS[key].name+(_bn2>1?'s':'')+' packed, on key '+(_bk2+1)+'.');
      renderHub(); return;
    }
    P.kit.push(key); saveProfile(); renderHub();
'@

# (B) the plan cell: a key on nothing packed says 0, the way the x-count says a stack.
SubRx @'
      ((it&&packedCount(k)>1)?'<span style="position:absolute;left:2px;top:0;font-size:10.5px;color:var(--amber)">x'+packedCount(k)+'</span>':'')+
'@ @'
      ((it&&packedCount(k)>1)?'<span style="position:absolute;left:2px;top:0;font-size:10.5px;color:var(--amber)">x'+packedCount(k)+'</span>':'')+
      // v12.27, HIS NOTE: a key on an item with none packed looked exactly like a
      // packed one; it says 0 now, so the drop above and this cell tell one story.
      ((it&&packedCount(k)<1)?'<span style="position:absolute;left:2px;top:0;font-size:10.5px;color:var(--rust)">0</span>':'')+
'@

# (C) a spent key in a raid says so instead of nothing.
SubRx @'
    if(ix<0&&!(ait.use==='gun')) return;
'@ @'
    // v12.27, HIS NOTE: the dark cell v9.03 keeps for a spent item answered its
    // key with silence, which read as a dead key. It says what is missing.
    if(ix<0&&!(ait.use==='gun')){ say('No '+ait.name+' left.'); return; }
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'DRAGGING AN ITEM FROM THE STASH TO THE BACKPACK WHEN ITS TACTICAL BELT KEY IS STILL SET FROM THE LAST RAID NOW LANDS ON THAT KEY, half the stack, and says so. A set key with nothing packed shows a 0. In a raid, pressing a key whose item you have used up says No <item> left.',
'@

# STAMPS.
SubRx @'
var VER='12.26';
'@ @'
var VER='12.27';
'@
SubRx @'
var WHATSNEW_VER='12.26';
'@ @'
var WHATSNEW_VER='12.27';
'@
$cnt=([regex]::Matches($s,"now:'v12\.26:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.26 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.26:[^']*'",{ param($m) "now:'v12.27: his note of 2026-09-07 (bandages did not come over): the belt plan outlives the raid but the packing does not, so a key can sit on an item with none packed; the backpack column hides one packed copy per key, so the single copy a stash drop packed vanished into that hide with no cell, no count and no words, and the plan cell drew the phantom key like a packed one. A drop for an item on an empty key now takes the belt-cell route (half the stack, a line naming the key), a set key with nothing packed shows a 0, and a spent belt key in a raid says No item left instead of nothing. The v9.03 dark cell is unchanged pending his ruling (answer 16 said stay dark; the note says disappear). Check 12.27 binds Bandage to key 3 with none packed, drops one from the stash onto the backpack and requires a visible count, the key named and the plan x-count; a drop with no key bound must still pack one; in a raid a spent Bandage key must say No Bandage left; fails on v12.26.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
