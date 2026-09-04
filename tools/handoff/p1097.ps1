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

# ============ HIS NOTE 12: A CONTRACT TARGET IS NOT SALVAGE.
# ============
# ============ "anything that can be used to craft or for a contract, etc.
# ============ should not be classified as salvage", 2026-09-04.
# ============
# ============ REPRODUCED BY ENUMERATION, against the tables that do the wanting
# ============ rather than by reading the label. Three items are wanted by
# ============ something in this game and are called SALVAGE, SELL IT by the
# ============ stash and cleared by SELL JUNK AND LOOSE SALVAGE:
# ============
# ============   servo   repairs a badly worn gun, and the contract board asks
# ============           for it by name
# ============   optic   the contract board asks for it by name
# ============   core    the contract board asks for it by name, AND the
# ============           mainframe eats one to send you up with intel
# ============
# ============ The classification is a hard-coded list of five ids. It is correct
# ============ about recipes and racks and knows nothing about the other three
# ============ things in the game that consume an item. So SELL JUNK AND LOOSE
# ============ SALVAGE can sell the very item a live contract is asking him to
# ============ carry out, and the stash tells him to do it.
# ============
# ============ THE SERVO IS THE SHARPEST CASE and it is my own regression. v9.43
# ============ demoted it to salvage on the grounds that "the one thing it was
# ============ for was repairing guns that have not worn since v9.01". Guns wear
# ============ again, on his own answer that kills wear a gun, and addWear runs
# ============ on every shot. The premise expired and the demotion did not.
# ============
# ============ THE FIX IS THAT NOTHING KEEPS A LIST. One function answers what
# ============ wants an item, and it answers by ASKING the recipe table, the rack
# ============ costs, the repair parts, the mainframe and the contract board.
# ============ Where those were literals inside the code that used them, they are
# ============ named now, so the next thing that wants an item cannot be added
# ============ without this answer changing with it.

# ---- 1. the repair parts, named rather than spelled inside the cost function
SubRx @'
  var cap=Math.round(replaceCost(id)*0.6);
  return {credits:Math.min(raw,cap),
          part:(w>=950?'servo':'comp'),
          parts:(w>=1600?2:1)};
'@ @'
  var cap=Math.round(replaceCost(id)*0.6);
  return {credits:Math.min(raw,cap),
          part:(w>=950?REPAIR_PARTS.heavy:REPAIR_PARTS.light),   // v10.97: named, so itemWanted can ask
          parts:(w>=1600?2:1)};
'@
SubRx @'
function craftPart(k){
'@ @'
// v10.97, HIS NOTE 12: the two parts a gun repair eats, named here so the thing
// that decides what is salvage can ask rather than carry its own copy.
var REPAIR_PARTS={light:'comp',heavy:'servo'};
function craftPart(k){
'@

# ---- 2. the contract board's shopping list, named
SubRx @'
    var it=pick(['board','optic','servo','core']);
'@ @'
    var it=pick(CON_ITEMS);
'@
SubRx @'
var THROWKEYS=['smoke','decoy','frag'];
'@ @'
var THROWKEYS=['smoke','decoy','frag'];
// v10.97, HIS NOTE 12: THE CONTRACT BOARD'S SHOPPING LIST. It used to be a
// literal inside the contract generator, which is how three of these ended up
// classified as salvage: nothing else in the file could see what the board asks
// for. Add an item here and it stops being sellable in the same breath.
var CON_ITEMS=['board','optic','servo','core'];
// WHAT WANTS THIS ITEM, and why, in words he can read. Answered by asking the
// tables that do the wanting, never by a second list kept beside them.
// Returns null for genuine salvage: nothing in the game has any use for it and
// selling it is the whole point of picking it up.
function itemWanted(k){
  var i;
  if(typeof RECIPES!=='undefined')
    for(i=0;i<RECIPES.length;i++)
      if(RECIPES[i].need&&RECIPES[i].need[k]!==undefined) return craftUse(k);
  if(typeof RACK_COST!=='undefined'&&RACK_COST[k]!==undefined) return 'mainframe racks';
  if(k===REPAIR_PARTS.heavy||k===REPAIR_PARTS.light) return 'gun repairs';
  if(k==='core') return 'contracts, and the mainframe burns one for intel';
  for(i=0;i<CON_ITEMS.length;i++) if(CON_ITEMS[i]===k) return 'contracts';
  return null;
}
'@

# ---- 3. what the sell button will not touch
SubRx @'
function sellable(k){
  var it=ITEMS[k]; if(!it) return true;          // unknown keys are junk
  if((P.junk||{})[k]) return true;               // tagged junk always goes
  return !(it.use||craftPart(k));                // usable kit and parts are kept
}
'@ @'
function sellable(k){
  var it=ITEMS[k]; if(!it) return true;          // unknown keys are junk
  if((P.junk||{})[k]) return true;               // tagged junk always goes
  // v10.97, HIS NOTE 12: and anything the game wants, which is wider than the
  // recipe list craftPart knows about. Tagging it junk still overrides this,
  // above, so he is never stuck holding something he has decided to be rid of.
  return !(it.use||craftPart(k)||itemWanted(k));
}
'@

# ---- 4. the stash tab, hoisted out of the render so one function answers
# ---- "what is this" for the stash and for anything that asks
SubRx @'
  function tabOf(k){
    var t=ITEMS[k]; if(!t) return 'other';
    if(t.use==='gun') return 'gun';
    if(t.use==='armor') return 'use';     // v10.11: armour plates are consumables, his answer 2
    if(t.use==='key') return 'key';                      // v6.39, his note: keys are their own class
    if(craftPart(k)) return 'part';            // recipes and racks eat these
    if(t.use) return 'use';
    return 'salvage';                          // no use, nothing wants it: sell it
  }
'@ @'
  function tabOf(k){ return stashTabOf(k); }
'@
SubRx @'
function sellable(k){
'@ @'
// v10.97, HIS NOTE 12: WHAT SHELF AN ITEM LIVES ON. This was written inside the
// stash renderer, where it was the only copy but also unreachable, so nothing
// else could ask and nothing could check it. It is one function now.
function stashTabOf(k){
  var t=ITEMS[k]; if(!t) return 'other';
  if(t.use==='gun') return 'gun';
  if(t.use==='armor') return 'use';     // v10.11: armour plates are consumables, his answer 2
  if(t.use==='key') return 'key';                      // v6.39, his note: keys are their own class
  if(craftPart(k)) return 'part';            // recipes and racks eat these
  if(t.use) return 'use';
  // v10.97, his note: a contract target, a repair part or the mainframe core is
  // a PART. It was salvage, so the sell button cleared the exact item a live
  // contract was asking him to carry out.
  if(itemWanted(k)) return 'part';
  return 'salvage';                          // nothing in the game wants it: sell it
}
function sellable(k){
'@

# ---- 5. and the stash says what wants it, instead of telling him to sell it
SubRx @'
      var what=craftPart(k)
        ? '<span style="color:var(--gain)">KEEP &mdash; '+escHtml(craftUse(k))+'</span>'
        : (it.use ? '<span style="color:var(--coolant)">'+escHtml(String(it.use).toUpperCase())+'</span>'
                  : '<span style="color:var(--ash)">salvage, sell it</span>');
'@ @'
      // v10.97, HIS NOTE 12: ask what wants it, rather than asking whether it is
      // one of the five things a recipe eats. Three items were being told to
      // sell themselves while a contract was asking for them by name. Its own
      // USE still comes first, because a bandage is a bandage before it is an
      // ingredient.
      var _wnt=itemWanted(k);
      var what=it.use
        ? '<span style="color:var(--coolant)">'+escHtml(String(it.use).toUpperCase())+'</span>'
        : (_wnt ? '<span style="color:var(--gain)">KEEP &mdash; '+escHtml(_wnt)+'</span>'
                : '<span style="color:var(--ash)">salvage, sell it</span>');
'@

SubRx @'
var VER='10.96';
'@ @'
var VER='10.97';
'@
SubRx @'
  now:'v10.96: your two choices on the Undercroft pause screen. It had one button, Back to the Undercroft, and no route back to the character screen at all short of reloading the tab. It now reads RETURN TO THE UNDERCROFT and RETURN TO CHARACTER SELECTION, and the second one puts the character screen back up over the room with the name line and the save list brought up to date.',
'@ @'
  now:'v10.97: a contract target is not salvage, your note. Three items were wanted by something and called salvage anyway: the servo repairs a worn gun and the board asks for it, the optic the board asks for, and the data core the board asks for AND the mainframe burns for intel. SELL JUNK AND LOOSE SALVAGE was clearing the exact item a live contract wanted. Nothing keeps a list now: one function asks the recipes, the rack costs, the repair parts, the mainframe and the contract board.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE SELL BUTTON WILL NOT SELL WHAT SOMETHING WANTS. Servo Actuators, Optics Lenses and Data Cores were classified as salvage, so SELL JUNK AND LOOSE SALVAGE cleared them, while the contract board was asking for them by name, a worn gun needed a servo to repair, and the mainframe burns a core for intel. All three sit under PARTS now and the stash says what wants them. Tag a thing junk and it still sells.',
'@
SubRx @'
var WHATSNEW_VER='10.96';
'@ @'
var WHATSNEW_VER='10.97';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
