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

# v13.22 CHECK, inserted before the v13.21 entry.
#
# IT READS THE LIST, NOT THE PAGE. A check that searches the page source finds
# its own needles; the WHATSNEW array is data, so the phrases below are safe here.
#
# THE STAMP IS CHECKED AGAINST WHAT THE LIST CLAIMS, NOT PINNED TO ONE NUMBER. A
# check pinned to 13.22 would break the next time the list legitimately moves.
# The rule that stays true is that the card cannot be older than the oldest
# change it names, which is v13.16, the plate.
#
# POSITION MATTERS AS MUCH AS PRESENCE. The card draws only the top entries that
# fit and cuts at the last whole one, so an entry below the fold is on the list
# and never on the screen.
SubRx @'
  {v:'13.21',what:'the Recorder Copy button, where a failed Copy report sends the player, says whether the copy worked: Copied when it did, and when every copy route is refused it keeps the report selected and says press Ctrl+C (the only feedback path on itch)',
'@ @'
  {v:'13.22',what:'the what-is-new card names what changed how you play since v13.10, high enough to be drawn: B backs out of menus and a found armour plate goes to the backpack; the stamp is not older than what it lists; and no entry still claims the X key is gone',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined') return 'SKIP: this build has no what-is-new card';
     var bad=[];
     var ver=parseFloat(WHATSNEW_VER);
     if(!(ver>=13.16))
       bad.push('the card still says NEW IN v'+WHATSNEW_VER+', so a player coming back is told nothing about B backing out of menus or a found armour plate going to the backpack, both of which change how he plays');
     var idxB=-1, idxP=-1, idxX=-1, stale=false;
     for(var i=0;i<WHATSNEW.length;i++){
       var t=String(WHATSNEW[i]);
       if(idxB<0&&t.indexOf('PRESS B TO BACK OUT')===0) idxB=i;
       if(idxP<0&&t.indexOf('AN ARMOUR PLATE YOU FIND')===0) idxP=i;
       if(idxX<0&&t.indexOf('X SEARCHES WHAT YOU ARE STANDING ON')===0) idxX=i;
       if(t.indexOf('key is gone')>=0) stale=true;
     }
     if(idxB<0)
       bad.push('the card never tells a player that B backs out of menus, which is the key he was given because Escape is not working for him, and a key nobody is told about does not exist');
     else if(idxB>2)
       bad.push('B backing out is entry '+(idxB+1)+' on the card, low enough to fall below where the card stops drawing, so it is on the list and never on the screen');
     if(idxP<0)
       bad.push('the card never says a found armour plate now goes to the backpack, so the first plate he loots looks like it vanished');
     else if(idxP>3)
       bad.push('the armour plate line is entry '+(idxP+1)+', low enough to fall below where the card stops drawing');
     if(idxX<0)
       bad.push('the card never says X searches what you stand on, so the key for a body on the extraction point is one nobody is told about');
     if(stale)
       bad.push('an entry still says the X key is gone, while X is the search key, so the card contradicts the controls it describes');
     return bad.length?bad.join('; '):null; }},
  {v:'13.21',what:'the Recorder Copy button, where a failed Copy report sends the player, says whether the copy worked: Copied when it did, and when every copy route is refused it keeps the report selected and says press Ctrl+C (the only feedback path on itch)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
