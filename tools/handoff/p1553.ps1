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

SubRx @'
  var ix=P.stash.indexOf('core');
  if(ix<0){ say('No Data Core in the stash. They come off rare shelves and elite pillagers.'); return; }
  P.stash.splice(ix,1);
  P.intel=1;
  saveProfile();
  blip('pick');
  say('Core slotted. Your next ascent carries intel.');
'@ @'
  var ix=P.stash.indexOf('core');
  if(ix<0){ say('No Data Core in the stash. They come off rare shelves and elite pillagers.'); return; }
  // v15.53, rack audit finding: SLOT A DATA CORE SAYS WHEN IT TAKES A PACKED CORE OUT OF THE BACKPACK. Packing leaves an item
  // in the stash, so a core packed for the next ascent still lit this button, and a bare splice took a core out of the stash
  // whether or not a loose one was left. With every core he held packed, the backpack lost its core with no word: the kit was
  // only trimmed when stageKitLive next read it, and a belt key bound to the core was left pointing at nothing. BUILD A RACK,
  // two buttons up, has spent through spendHeld and named what it took out of the backpack since v15.18. The core now goes
  // the same way: a loose core first (v13.59), else the packed one is unpacked properly, which lets its belt key go, and one
  // sentence naming it is added after the core line, which is unchanged. No number moved.
  var _cp=spendHeld('core',1);   // v13.59: loose copies first, a packed one unpacked properly (kit and belt key)
  P.intel=1;
  saveProfile();
  blip('pick');
  say('Core slotted. Your next ascent carries intel.'+(_cp?' Used '+_cp+' packed Data Core out of your backpack.':''));
'@
SubRx @'
  L.appendChild(stageRow('Intel',
    P.intel?'A Data Core is armed. Keys and elites show on the map.':'No core armed.',
    (!P.intel&&P.stash.indexOf('core')>=0)?'Arm':null,
    function(){ var ix=P.stash.indexOf('core');
      if(ix<0) return; P.stash.splice(ix,1); P.intel=1; saveProfile(); renderStage(); },'var(--coolant)'));
'@ @'
  // v15.53, rack audit finding: ARM ON THE ASCENT CHECK SAYS WHEN IT TAKES A PACKED CORE OUT OF THE BACKPACK. The Intel row
  // had the same bare splice as SLOT A DATA CORE, so with every core packed it emptied the backpack of its core in silence and
  // left the belt key on nothing. It spends through spendHeld the same way now, and names a packed core it had to take.
  L.appendChild(stageRow('Intel',
    P.intel?'A Data Core is armed. Keys and elites show on the map.':'No core armed.',
    (!P.intel&&P.stash.indexOf('core')>=0)?'Arm':null,
    function(){ var ix=P.stash.indexOf('core');
      if(ix<0) return; var _cp=spendHeld('core',1); P.intel=1; saveProfile();
      if(_cp) say2('Used '+_cp+' packed Data Core out of your backpack.'); renderStage(); },'var(--coolant)'));
'@
SubRx @'
var VER='15.52';
'@ @'
var VER='15.53';
'@

$pat = "(?m)^  now:'v15\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.53: SLOT A DATA CORE SAYS WHEN IT TAKES A PACKED CORE OUT OF THE BACKPACK. With every Data Core you held packed for the next ascent, SLOT A DATA CORE took one out of the backpack without a word and left its belt key pointing at nothing. A loose core still goes first; a packed one is now unpacked properly, its belt key let go, and the core line adds Used 1 packed Data Core out of your backpack, the way BUILD A RACK does. Check 15.53 slots a core with one loose and one packed, then with only a packed one, and arms one on the ascent check; it fails on v15.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
