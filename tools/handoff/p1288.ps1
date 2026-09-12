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

# FINDING 3 OF THE 2026-09-11 AUDIT. It is the only one in that file where the
# game states a FACT ABOUT A REAL PERSON and the fact is false.
#
# WHAT HAPPENS. A friend plays the alpha, exports their run report and sends him
# the file. He names them at the Mainframe, picks the file, and the game says
# "<NAME> imported: 17 runs, 29% extract, favours the Auto Rifle." The Mainframe
# hint repeats it for as long as that ghost is installed. The friend never touched
# an Auto Rifle. Their report said Scav Pistol on every line.
#
# WHY. The export writes the weapon as its DISPLAY name, "wep:Scav Pistol(owned)".
# The capture group is lazy and terminates on whitespace OR the bracket, so it
# stops at the first SPACE and yields "Scav". The lookup against the weapon table
# then finds nothing, and favKey is left sitting on its initialiser, 'rifle',
# whose display name is Auto Rifle. Nine of the sixteen weapons have a space in
# the name, so nine of sixteen break.
#
# TWO THINGS ARE WRONG AND BOTH ARE FIXED. The parse stops at the bracket or at
# the next field rather than the first space, so the whole display name reaches
# the lookup. And a lookup that still fails no longer states a favourite at all:
# an unreadable report gets a ghost with no favourite-gun sentence rather than a
# confident wrong one. The gun they are armed with is unchanged in that case, so
# nothing about the raid moves; only the claim goes away.
SubRx @'
    var wm=L2.match(/wep:([^(]+?)[\s(]/);
'@ @'
    // v12.88: to the bracket or to the next field, never to the first space. The
    // export writes the DISPLAY name, so "wep:Scav Pistol(owned) dur:31s" has to
    // yield "Scav Pistol" and not "Scav". The source bracket is optional in the
    // format, so " dur:" is the other terminator.
    var wm=L2.match(/wep:(.*?)(?:\s*\([^)]*\))?\s+dur:/);
'@

SubRx @'
  var favKey='rifle';
  for(var wk in WEAPONS) if(WEAPONS[wk].name===favName){ favKey=wk; break; }
  return {tag:String(name||'THE GHOST').slice(0,18),
    wep:favKey, wepName:WEAPONS[favKey].name,
'@ @'
  // v12.88: A FAILED LOOKUP USED TO BE A CONFIDENT WRONG ANSWER. favKey sat on
  // its initialiser and the game told him his friend favours the Auto Rifle,
  // which is a statement about a real person that the report does not support.
  // The ghost is still armed with the same default, so nothing about the raid
  // moves; what goes away is the claim. wepName null means the two sentences
  // that name a favourite leave that clause out.
  var favKey='rifle', favKnown=false;
  for(var wk in WEAPONS) if(WEAPONS[wk].name===favName){ favKey=wk; favKnown=true; break; }
  return {tag:String(name||'THE GHOST').slice(0,18),
    wep:favKey, wepName:favKnown?WEAPONS[favKey].name:null,
'@

SubRx @'
      say(g.tag+' imported: '+g.runs+' runs, '+g.rate+'% extract, favours the '+g.wepName+'. They walk your raids now.');
'@ @'
      say(g.tag+' imported: '+g.runs+' runs, '+g.rate+'% extract'+(g.wepName?(', favours the '+g.wepName):'')+'. They walk your raids now.');
'@

SubRx @'
    ?(P.ghost.tag+' walks your raids: '+P.ghost.rate+'% extract over '+P.ghost.runs+' runs, favours the '+P.ghost.wepName+'. Import another file to replace them.')
'@ @'
    ?(P.ghost.tag+' walks your raids: '+P.ghost.rate+'% extract over '+P.ghost.runs+' runs'+(P.ghost.wepName?(', favours the '+P.ghost.wepName):'')+'. Import another file to replace them.')
'@

# NEW IN.
SubRx @'
  'YOU COME BACK DOWN WITH AN EMPTY BACKPACK AND BELT.
'@ @'
  'A FRIEND YOU IMPORT CARRIES THE GUN THEY ACTUALLY CARRIED. Their weapon name was cut at the first space, so anyone whose favourite had two words in it came back as an Auto Rifle, which is nine of the sixteen guns. If their report still cannot be read, the game no longer claims a favourite it cannot support.',
  'YOU COME BACK DOWN WITH AN EMPTY BACKPACK AND BELT.
'@

# STAMPS.
SubRx @'
var VER='12.87';
'@ @'
var VER='12.88';
'@
SubRx @'
var WHATSNEW_VER='12.87';
'@ @'
var WHATSNEW_VER='12.88';
'@
$cnt=([regex]::Matches($s,"now:'v12\.87:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.87 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.87:[^']*'",{ param($m) "now:'v12.88: finding 3 of the 2026-09-11 audit, and the only one in that file where the game states a fact about a real person and the fact is false. A friend plays the alpha, exports their run report and sends him the file; he names them at the Mainframe, picks the file, and the game says NAME imported, 17 runs, 29 percent extract, favours the Auto Rifle, and the Mainframe hint repeats it for as long as that ghost is installed. The friend never touched an Auto Rifle: their report said Scav Pistol on every line. The export writes the weapon as its DISPLAY name, wep colon Scav Pistol bracket owned, and the capture group is lazy and terminates on whitespace or the bracket, so it stops at the first SPACE and yields Scav; the lookup against the weapon table then finds nothing and favKey is left sitting on its initialiser rifle, whose display name is Auto Rifle. Nine of the sixteen weapons have a space in the name, so nine of sixteen break, and by coincidence Auto Rifle itself truncates to Auto, fails the lookup and lands on rifle, so it reports correctly by accident. Two things were wrong and both are fixed: the parse stops at the bracket or at the next field rather than the first space, so the whole display name reaches the lookup, and a lookup that still fails no longer states a favourite at all, because an unreadable report should get a ghost with no favourite-gun sentence rather than a confident wrong one. The gun the ghost is armed with is unchanged in that case, so nothing about the raid moves; only the claim goes away. Check 12.88 parses a report whose every run says a two-word gun and requires the ghost to come back carrying that gun and naming it, parses one naming a gun this build does not have and requires no favourite to be claimed, and controls that a one-word gun still reads correctly; fails on v12.87 where the two-word report comes back as an Auto Rifle.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
