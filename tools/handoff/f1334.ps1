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

# v13.34 CHECK, inserted before the v13.33 entry.
#
# It reads the list the card draws from and the stamp that decides whether the card is
# shown, the way check 13.22 does. Thirteen is the measured draw budget at the default
# text size (START-HERE, v13.22's not-verified line, measured through __textTrace).
SubRx @'
  {v:'13.33',what:'a line that must not be lost waits its turn: with a message showing, two more queued behind it are each shown when the one before runs out, in order and none written over, which is how the rival warning and the loaner line reach the player',
'@ @'
  {v:'13.34',what:'the what-is-new card tells a player coming back that the welcome pack now goes to the stash and how to take a gun from it, Equip as your gun, within the entries the card draws, and its stamp is not older than the stash ruling',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined') return 'SKIP: this build has no what-is-new card';
     var bad=[];
     var ver=parseFloat(WHATSNEW_VER);
     if(!(ver>=13.29))
       bad.push('the card still says NEW IN v'+WHATSNEW_VER+', older than his ruling that sends the welcome pack to the stash, so a friend coming back is shown nothing about it');
     var lead=['THE','WELCOME','PACK','GOES','TO','YOUR','STASH'].join(' ');
     var needle=['Equip','as','your','gun'].join(' ');
     var idx=-1;
     for(var i=0;i<WHATSNEW.length;i++){ if(String(WHATSNEW[i]).indexOf(lead)===0){ idx=i; break; } }
     if(idx<0)
       bad.push('no entry on the card says the welcome pack now goes to the stash, so a player who took it before expects its guns in his hands');
     else {
       if(idx>12) bad.push('the stash entry is entry '+(idx+1)+', below the thirteen the card draws, so it is on the list and never on the screen');
       if(String(WHATSNEW[idx]).indexOf(needle)<0) bad.push('the stash entry does not say how to take a gun from the stash');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.33',what:'a line that must not be lost waits its turn: with a message showing, two more queued behind it are each shown when the one before runs out, in order and none written over, which is how the rival warning and the loaner line reach the player',
'@

# r1334, carried by this build: CHECK 13.32 THREW ON A PANE WITH NO LAYOUT.
# It steps the real frame loop, which draws; on a 0x0 pane render2D throws in
# drawImage, so the check reported the pane as a failure. Measured on the v13.32 gate:
# three throws at innerWidth 0, three passes at 1920x1080. 13.33 already asks
# __vpAlive first; 13.32 now does too. A skip is not a pass, and the corpus of record
# still runs at 1920x1080.
SubRx @'
     if(!ITEMS.gun_smg||!WEAPONS.smg||!WEAPONS.pistol) return 'SKIP: this build has no stash gun item to stage';
     var bad=[], P2=__P();
'@ @'
     if(!ITEMS.gun_smg||!WEAPONS.smg||!WEAPONS.pistol) return 'SKIP: this build has no stash gun item to stage';
     // r1334: the frame loop draws, and a pane with no layout throws in drawImage.
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     var bad=[], P2=__P();
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
