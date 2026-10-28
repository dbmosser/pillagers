$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# MELEE ON Z, DROP ON V (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(P.keymapV!==2){ P.keymap={}; P.keymapV=2; }
'@ @'
keysMig(P); /* v35.xx (cw-meleez), his order 10-28 "can we move melee to z as default?": a save from before the Z melee swap keeps any key it moved; the save key is unchanged */
'@

SubRx @'
var KEYS_V=2, KEYS_FIXED={Escape:1,Tab:1,KeyP:1,Backspace:1,Backquote:1,F9:1,F11:1};
'@ @'
var KEYS_V=3, KEYS_FIXED={Escape:1,Tab:1,KeyP:1,Backspace:1,Backquote:1,F9:1,F11:1}; var KEYS_DEF={KeyV:'KeyZ',KeyZ:'KeyV'};   /* v35.xx (cw-meleez), his order 10-28 ("can we move melee to z as default?"): the game still reads melee as KeyV and drop for a teammate as KeyZ (so the pad, the finisher hold and every reader are unchanged), but by default melee sits on the Z key and drop on V. Map version 3. */
'@

SubRx @'
function keysInv(){ var m=keysMap(), k, inv={}; for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)&&typeof m[k]==='string'&&m[k]!==k&&KEYS_ACTS.some(function(a){ return a[0]===k; })) inv[m[k]]=k;
'@ @'
function keysInv(){ var k, i, q, inv={}; for(i=0;i<KEYS_ACTS.length;i++){ k=KEYS_ACTS[i][0]; q=keysOf(k); if(typeof q==='string'&&q&&q!==k) inv[q]=k; } for(k in KEYS_DEF) if(Object.prototype.hasOwnProperty.call(KEYS_DEF,k)&&keysOf(k)!==k&&!inv[k]) inv[k]='KeyNone';   /* v35.xx (cw-meleez): from the actions and their keys as set, so the Z melee and V drop defaults translate too; with melee moved to K, the Z key no longer falls through to drop */
'@

SubRx @'
function keysOf(logical){ var m=keysMap(); return (typeof m[logical]==='string')?m[logical]:logical; }
'@ @'
function keysOf(logical){ var m=keysMap(); return (typeof m[logical]==='string')?m[logical]:keysDef(logical); }   /* v35.xx (cw-meleez): an action not in the map is on its default key (Z for melee, V for drop) */ function keysDef(k){ return (typeof KEYS_DEF==='object'&&KEYS_DEF&&typeof KEYS_DEF[k]==='string')?KEYS_DEF[k]:k; }   /* v35.xx (cw-meleez), his order 10-28 ("can we move melee to z as default?"): THE KEY MAP MIGRATION, run by the loader. A version 2 save that never touched V or Z takes the new defaults (melee Z, drop V); one that moved melee or drop, or put another action on V or Z, keeps both where they were. A save from before version 2 starts on the defaults, as it always did. The storage key is unchanged. */ function keysMig(q){ var m, k, t=0; if(!q||typeof q!=='object') return q; if(q.keymapV===2){ m=(q.keymap&&typeof q.keymap==='object')?q.keymap:{}; for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)&&(k==='KeyV'||k==='KeyZ'||m[k]==='KeyV'||m[k]==='KeyZ')) t=1; if(t){ if(typeof m.KeyV!=='string') m.KeyV='KeyV'; if(typeof m.KeyZ!=='string') m.KeyZ='KeyZ'; } q.keymap=m; q.keymapV=3; } else if(q.keymapV!==3){ q.keymap={}; q.keymapV=3; } return q; }
'@

SubRx @'
for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)&&m[k]===k) delete m[k];
'@ @'
for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)&&m[k]===keysDef(k)) delete m[k];   /* v35.xx (cw-meleez): back on its default, not its name */
'@

SubRx @'
ch=(keysOf(k)!==k);
'@ @'
ch=(keysOf(k)!==keysDef(k));   /* v35.xx (cw-meleez) */
'@

SubRx @'
if(!c.some(function(k){ return keysOf(k)!==k; })) return s;
'@ @'
if(!c.some(function(k){ return keysOf(k)!==keysDef(k); })) return s;   /* v35.xx (cw-meleez) */
'@

SubRx @'
['V','melee, swing the crowbar']
'@ @'
['Z','melee, swing the crowbar']
'@

SubRx @'
['TEAM',[['Z','drop an item for a teammate'],
'@ @'
['TEAM',[['V','drop an item for a teammate'],
'@

SubRx @'
  ['V','melee'],['F','next gun'],['Q','item wheel'],
'@ @'
  ['Z','melee'],['F','next gun'],['Q','item wheel'],   /* v35.xx (cw-meleez): Z melee */
'@

SubRx @'
'Z':['KeyZ']
'@ @'
'Z':['KeyV']
'@

SubRx @'
'V':['KeyV']
'@ @'
'V':['KeyZ']
'@

SubRx @'
else MN.push(['Z','drop to trade'],['N','ping']); }
'@ @'
else MN.push(['V','drop to trade'],['N','ping']); }   /* v35.xx (cw-meleez): drop is on V */
'@

SubRx @'
_bo=(padOn()?padB('Y'):'Z')+' drop for teammate   ';
'@ @'
_bo=(padOn()?padB('Y'):keyName(keysOf('KeyZ')))+' drop for teammate   ';   /* v35.xx (cw-meleez): the drop key as set, V by default */
'@

SubRx @'
_bh=(padOn()?padB('Y'):'Z')+' drop   '+_bh.slice(_bo.length);
'@ @'
_bh=(padOn()?padB('Y'):keyName(keysOf('KeyZ')))+' drop   '+_bh.slice(_bo.length);
'@

SubRx @'
:('ARROWS move   Z drop one   drag to tactical belt'
'@ @'
:('ARROWS move   '+keyName(keysOf('KeyZ'))+' drop one   drag to tactical belt'
'@

SubRx @'
keymap:{},keymapV:2,
'@ @'
keymap:{},keymapV:3,
'@

SubRx @'
var VER='35.73';
'@ @'
var VER='35.74';
'@

$pat = "(?m)^  now:'v35\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.74: melee swings on Z and drop for a teammate is on V by default; a save that moved either key keeps it; every key list says so; middle mouse pings as before Check 35.74 fails on v35.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
