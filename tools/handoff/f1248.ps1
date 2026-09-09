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

# v12.48 CHECK, inserted before the v12.47 entry. It reads the card back from
# the game rather than from the source, and every needle is assembled from
# pieces so this check cannot find itself, which has cost three builds before.
# The rule it enforces is the one his list actually states: the retired words
# are banned outright, except inside the very entry that announces the rename,
# which has to quote the old word to make sense. Two controls: the card must
# have lines at all, and the rename entries must still be present, so deleting
# them can never be the way this check goes green.
SubRx @'
  {v:'12.47',what:'a raised deck edge is painted where it is: no kerb on any deck on either sector is painted above the edge he collides with, so no part of the deck he can stand on is covered by a wall he can walk through, while ordinary building walls still stand proud of their colliders (his report of 2026-09-08, the long thin building)',
'@ @'
  {v:'12.48',what:'the what is new card obeys his vocabulary list: no entry names the extraction as a vehicle or uses the retired arrival word, and the old names for the tactical belt and the backpack appear only inside the entries that announce those renames, which still exist (his order of 2026-09-02, my slip of 2026-09-08)',
   run:function(){
     if(!window.__words||!__words.whatsnew) return 'SKIP: this build cannot report its own what is new card';
     var card=__words.whatsnew(), L=card&&card.lines, bad=[], i;
     if(!L||!L.length) return 'SKIP: the what is new card has no lines to check';
     // Assembled, never written whole. A check that greps the page for a word it
     // spells out finds itself; that has cost three builds already.
     var VEH='sh'+'ip', ARR='touch'+'down', BOARD='board'+'ing';
     var OLDBELT='hot'+'bar', NEWBELT='tactical belt';
     var OLDPACK='b'+'ag', NEWPACK='backpack';
     function has(s,w){ return s.toLowerCase().indexOf(w)>=0; }
     function word(s,w){ return new RegExp('\\b'+w+'\\b','i').test(s); }
     var renameBelt=0, renamePack=0;
     for(i=0;i<L.length;i++){
       var line=String(L[i]||''), tag='entry '+(i+1)+' ["'+line.slice(0,60)+'"]';
       if(word(line,VEH)) bad.push(tag+' names the extraction as a vehicle, which he retired on 2026-09-02');
       if(has(line,BOARD)) bad.push(tag+' still uses the retired word for the extraction window');
       if(word(line,ARR)) bad.push(tag+' still uses the retired word for the arrival');
       if(has(line,OLDBELT)){
         if(has(line,NEWBELT)) renameBelt++;
         else bad.push(tag+' calls the tactical belt by the name he retired at v10.26, and is not the entry that announces that rename');
       }
       if(word(line,OLDPACK)){
         if(has(line,NEWPACK)) renamePack++;
         else bad.push(tag+' calls the backpack by the name he retired at v9.90, and is not the entry that announces that rename');
       }
     }
     // CONTROL: the rename entries must still BE there. Deleting the history
     // would satisfy every line above and leave the card telling him nothing
     // about the two renames he asked for by name.
     if(!renameBelt) bad.push('control: no entry on the card announces the belt rename any more, so the history has been deleted rather than the wording corrected');
     if(!renamePack) bad.push('control: no entry on the card announces the backpack rename any more, so the history has been deleted rather than the wording corrected');
     if(L.length<40) bad.push('control: the card is down to '+L.length+' entries, so lines have been removed rather than reworded');
     return bad.length?bad.join('; '):null; }},
  {v:'12.47',what:'a raised deck edge is painted where it is: no kerb on any deck on either sector is painted above the edge he collides with, so no part of the deck he can stand on is covered by a wall he can walk through, while ordinary building walls still stand proud of their colliders (his report of 2026-09-08, the long thin building)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
