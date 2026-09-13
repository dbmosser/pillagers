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

# THE QUICK ASCENT SENT HIM UP WITH A LOANER WITHOUT A WORD, WHILE HIS OWN GUN WAITED
# IN THE STASH.
#
# v13.31 put the stash-gun line on the sector page. The lift has a second door: the
# quick ascent key skips the sector page by design and starts the raid at once. Since
# his ruling a new player's pack guns wait in the stash with nothing equipped, so that
# door rolls him a random starter, and buildRaid issues it silently. The only message
# about issued guns fires when he tries to stow one.
#
# ONE LINE AT LANDING, only when the gun in his hands was issued and a usable gun of
# his own is in the stash. It is said at landing on every door, so a player who came
# through the sector page and still did not equip hears it once more, in the raid,
# where the loaner is actually in his hands.
#
# IT WAITS ITS TURN. say() holds one message for 3.2 seconds and a second say in the
# same frame overwrites the first, which is the fault his notes found twice. Landing
# already says the weather line. So when a message is showing, this line is kept in
# G.msgNext and shown by the frame loop the moment the current one runs out. Nothing
# else uses the slot.
SubRx @'
if(G.wx.id!=='clear'&&G.wx.line) say(G.wx.line);
'@ @'
if(G.wx.id!=='clear'&&G.wx.line) say(G.wx.line);
  // v13.32: a loaner in his hands while a gun of his own waits in the stash. Said
  // after the weather line, never over it.
  try{
    if(!G.sim&&G.player&&G.player.wepIssued&&(P.stash||[]).some(function(k){ var it=ITEMS[k]; return it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]; })){
      var _loanLn='You are carrying a loaner. Your own gun waits in your stash: choose Equip as your gun on it there before your next ascent.';
      if(G.msgT>0) G.msgNext=_loanLn; else say(_loanLn);
    }
  }catch(_loan0){}
'@

SubRx @'
      if(G.msgT>0) G.msgT-=dt;
'@ @'
      if(G.msgT>0) G.msgT-=dt;
      // v13.32: one waiting line, shown when the current message runs out rather than
      // written over it in the same frame.
      if(G.msgNext&&!(G.msgT>0)){ var _mNext=G.msgNext; G.msgNext=null; say(_mNext); }
'@

SubRx @'
var VER='13.31';
'@ @'
var VER='13.32';
'@

$pat = "(?m)^  now:'v13\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.32: THE QUICK ASCENT SENT HIM UP WITH A LOANER WITHOUT A WORD WHILE HIS OWN GUN WAITED IN THE STASH. v13.31 put the stash gun line on the sector page, and the lift has a second door: the quick ascent key skips that page by design and starts the raid at once. Since his ruling a new player pack guns wait in the stash with nothing equipped, so that door rolls him a random starter, and buildRaid issues it silently; the only message about issued guns fires when he tries to stow one. One line at landing now, only when the gun in his hands was issued and a usable gun of his own is in the stash, said on every door because the raid is where the loaner is actually in his hands. It waits its turn: say holds one message for 3.2 seconds and a second say in the same frame overwrites the first, which is the fault his notes found twice, and landing already says the weather line, so while a message is showing the line is kept in G.msgNext and shown by the frame loop the moment the current one runs out. Check 13.32 presses the quick ascent key at the lift with nothing equipped, steps the real frame loop past the weather line, requires the line to be shown with a gun in the stash, and not with none or with a gun of his own equipped, and fails on v13.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
