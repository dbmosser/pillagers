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

# ============ HIS NOTE 14, THE FIRST HALF: A CHARACTER YOU CAN GIVE BACK.
# ============
# ============ "when friends give feedback the game should also log their
# ============ character info -- that way if they lose their character
# ============ accidentally, we can give them a code to restore it", 2026-09-04.
# ============
# ============ REPRODUCED by reading what a report actually carries: one summary
# ============ line, "Profile: 2 runs, 1 extracted, 0 died, best haul 2685c,
# ============ credits 395700, XP 343, racks 0, pack T1, notoriety 0, stash 4".
# ============ That is a description, not a character. Nothing in it says what
# ============ they were wearing, what is in the stash, what they have unlocked
# ============ or what their contracts standing is, so nothing in a report can
# ============ rebuild anybody.
# ============
# ============ WHY THE CODE IS SMALL. Cosmetics are not stored as an owned list;
# ============ cosOwned DERIVES them from runs, extracts, level, warden kills and
# ============ the season board, so the code only has to carry those numbers and
# ============ the ids actually worn, plus anything bought outright. The stash
# ============ goes in as counts by key rather than a list, and the run log stays
# ============ out entirely: it is the biggest thing in a profile and it is
# ============ history, not identity.
# ============
# ============ THIS BUILD MAKES AND READS THE CODE AND PUTS IT IN EVERY REPORT.
# ============ Applying it is the next build, behind a typed confirmation, because
# ============ an import that overwrites a save without asking is a worse bug than
# ============ the one it fixes.
SubRx @'
function buildExport(){
'@ @'
// v11.03, HIS NOTE 14: THE CHARACTER, SMALL ENOUGH TO PASTE. Short keys on
// purpose: this ends up in a report a friend sends by hand.
function restoreMake(){
  var o={v:1,n:P.pname||'PILLAGER',c:P.credits||0,x:P.xp||0,l:P.xpLevel||1,
         r:P.runs||0,e:P.ext||0,d:P.died||0,b:P.best||0,no:P.notoriety||0,
         pk:P.pack||0,ra:P.racks||0,ar:P.arrays||0,cs:P.cstand||0,
         sc:(P.spClaimed||[]).slice(),ki:P.kills||{},cb:P.cosBought||{},
         j:P.junk||{},mi:P.mapIx||0,cd:P.cond||'day',wq:P.wxPick||'any',
         w:{},s:{}};
  // What they are wearing. The RACKS themselves are derived from the numbers
  // above by cosOwned, so nothing here has to list what they have unlocked.
  for(var k in COSKEY) o.w[k]=P[COSKEY[k]]||null;
  // The stash as counts, which is a third of the size of the list and says the
  // same thing.
  var st=P.stash||[];
  for(var i=0;i<st.length;i++) o.s[st[i]]=(o.s[st[i]]||0)+1;
  return o;
}
function restoreCode(){
  try{ return 'PIL1'+btoa(JSON.stringify(restoreMake())).replace(/=+$/,''); }
  catch(e){ return ''; }
}
// The other direction, written in the same build as the maker so the two can
// never drift. Returns null for anything it does not recognise rather than
// throwing, because this will be fed by hand from a chat window.
function restoreRead(code){
  try{
    if(!code) return null;
    var b=String(code).replace(/\s+/g,'');
    if(b.slice(0,4)!=='PIL1') return null;
    b=b.slice(4);
    while(b.length%4) b+='=';
    var o=JSON.parse(atob(b));
    if(!o||typeof o.c!=='number'||typeof o.n!=='string') return null;
    return o;
  }catch(e){ return null; }
}
function buildExport(){
'@

SubRx @'
  L.push('');
  L.push('=== END RECORDER ===');
'@ @'
  // v11.03, HIS NOTE 14: the character itself, at the end where it is easy to
  // find, so a friend who loses a save can be handed one line and get it back.
  L.push('');
  L.push('--- RESTORE CODE ---');
  L.push('One line. Paste it into Settings to rebuild this character.');
  L.push(restoreCode());
  L.push('');
  L.push('=== END RECORDER ===');
'@

SubRx @'
var VER='11.02';
'@ @'
var VER='11.03';
'@
SubRx @'
  now:'v11.02: why changing save leaves fullscreen, your question. Because it reloads the game, and a browser always drops fullscreen on a reload; it cannot be put back without a click, because entering fullscreen needs a gesture and a gesture does not survive a page load. The saves panel says so now, and if you were in fullscreen when you switched, the title screen tells you and GO FULLSCREEN is right there.',
'@ @'
  now:'v11.03: every run report now ends with a RESTORE CODE, your note 14. One line that carries the character: name, credits, XP, the counters the racks are unlocked from, what they are wearing, the stash as counts, contracts standing and junk tags. The run log stays out, being history rather than identity. Pasting it back in is the next build, behind a typed confirmation.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'YOUR RUN REPORT NOW ENDS WITH A RESTORE CODE. It is one line that carries your character: name, credits, XP, what you are wearing, what is in your stash and what you have unlocked. If a save is ever lost, that line is how it comes back.',
'@
SubRx @'
var WHATSNEW_VER='11.02';
'@ @'
var WHATSNEW_VER='11.03';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
