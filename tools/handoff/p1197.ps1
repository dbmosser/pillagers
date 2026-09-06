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

# TWO AUDITS, 2026-09-06. First ten minutes: with only Bandages and health at
# their ceiling the heal verb said No medical supplies while the belt cell
# beside it read Medical x2, because the sentence written for that case sat
# behind a guard that had already returned. Shipped-builds review: v11.82 let
# heals stack, and the ceiling tests still read health alone, so a second
# Bandage above the first one's reach was spent for nothing. And the named
# belt slot for a heal had no ceiling test at all.
SubRx @'
function useMedical(){
  var p=G.player;
  var idx=findHeal();
  if(idx<0){ say('No medical supplies'); return false; }
  // What is already on its way counts as health you have. v11.82, HIS NOTE: a
  // heal already running no longer refuses the next one, and the countdown
  // that refusal printed (which was wrong) is gone with it.
  if(p.hp+(p.healQ||0)>=p.maxhp){
    say((p.healQ>0)?'Already healing.':'Already at full');
    return false;
  }
  // v9.62: and the item he is actually about to use. findHeal has already
  // skipped anything that cannot help, so reaching here with nothing usable
  // means only capped items are left and he deserves to be told which.
  if(idx<0||G.player.hp>=healCeil(ITEMS[G.bag[idx]])){
    var _anyHeal=false;
    for(var _h=0;_h<G.bag.length;_h++){ var _hi=ITEMS[G.bag[_h]]; if(_hi&&_hi.use==='heal'){ _anyHeal=true; break; } }
    say(_anyHeal?'Only bandages left, and they will not take you past '+
                 Math.round(healCeil(ITEMS.bandage))+'. You need a Medkit.'
               :'No medical supplies');
    return false;
  }
'@ @'
function useMedical(){
  var p=G.player;
  // v11.97: THE VERB TELLS THE TRUTH. Three faults in one function. The
  // full-health test came after the picker, so at full health with a Medkit
  // in the bag the picker found nothing usable and the verb said No medical
  // supplies. The sentence for "only Bandages, and you are above their reach"
  // sat behind idx<0 twelve lines down, which the first line had already
  // returned on, so with two Bandages at 85 health the verb said No medical
  // supplies while the belt cell beside it read Medical x2. And the ceiling
  // tests read health alone: v11.82 let heals stack, so a second Bandage
  // started above the first one's reach was spent for nothing.
  // What is already on its way counts as health you have (v11.82, HIS NOTE: a
  // heal already running no longer refuses the next one).
  if(p.hp+(p.healQ||0)>=p.maxhp){
    say((p.healQ>0)?'Already healing.':'Already at full');
    return false;
  }
  var idx=findHeal();   // skips anything that cannot raise him past what is inbound
  if(idx<0){
    var _anyHeal=false;
    for(var _h=0;_h<G.bag.length;_h++){ var _hi=ITEMS[G.bag[_h]]; if(_hi&&_hi.use==='heal'){ _anyHeal=true; break; } }
    say(_anyHeal?'Only bandages left, and they will not take you past '+
                 Math.round(healCeil(ITEMS.bandage))+'. You need a Medkit.'
               :'No medical supplies');
    return false;
  }
'@
SubRx @'
    if(G.player&&G.player.hp>=healCeil(it)) continue;
'@ @'
    if(G.player&&G.player.hp+(G.player.healQ||0)>=healCeil(it)) continue;   // v11.97: what is inbound counts
'@
SubRx @'
      if(_pp.hp+(_pp.healQ||0)>=_pp.maxhp){
        say((_pp.healQ>0)?'Already healing.':'Already at full'); return;
      }
      if(_pp.prep){ say('Already applying '+(ITEMS[_pp.prep.key]?ITEMS[_pp.prep.key].name:'something')+'.'); return; }
'@ @'
      if(_pp.hp+(_pp.healQ||0)>=_pp.maxhp){
        say((_pp.healQ>0)?'Already healing.':'Already at full'); return;
      }
      // v11.97: and the item's own ceiling, counting what is inbound. The
      // generic verb has had this since v9.62; a named Bandage above 85 was
      // spent for nothing while the toast said it was healing you.
      if(_pp.hp+(_pp.healQ||0)>=healCeil(ait)){ say(ait.name+' will not take you past '+Math.round(healCeil(ait))+'.'); return; }
      if(_pp.prep){ say('Already applying '+(ITEMS[_pp.prep.key]?ITEMS[_pp.prep.key].name:'something')+'.'); return; }
'@

# STAMPS.
SubRx @'
var VER='11.96';
'@ @'
var VER='11.97';
'@
$cnt=([regex]::Matches($s,"now:'v11\.96:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.96 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.96:[^']*'",{ param($m) "now:'v11.97: from the two 2026-09-06 reviews, the heal verb said No medical supplies with two Bandages at their ceiling (the sentence for that case sat behind a guard that had already returned) and at full health with a Medkit; and since v11.82 let heals stack, the ceiling tests read health alone, so a second Bandage above the first one''s reach was spent for nothing, and the named belt slot had no ceiling at all. The full-health test comes first, the picker counts what is inbound, and the belt slot has the ceiling. Check 11.97 drives four cases through the real verb; fails on v11.96.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
