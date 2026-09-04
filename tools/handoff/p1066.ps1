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

# ============ THE ALPHA, and the first thing a friend meets on Saturday.
# ============
# ============ Arriving in the Undercroft on a brand new save opens the primer,
# ============ FIRST TIME OUT, "what is worth knowing before you take the lift
# ============ up; the first three are the ones that get people killed", and then
# ============ immediately opens the welcome pack on top of it. Opening a window
# ============ closes every other one, so the primer is destroyed the instant it
# ============ appears and the player never sees a word of it.
# ============
# ============ Measured on v10.65 on a fresh profile: on arrival only the welcome
# ============ pack is up; the primer is gone and its seen flag is still 0, so it
# ============ is owed. It is paid only on a SECOND arrival at the floor with no
# ============ raid played in between, which is not what anybody does: you take
# ============ the pack, walk to the lift and go up. After that first raid the
# ============ primer sees a run on the profile, stamps itself seen and never
# ============ shows again. So the one card that teaches the game is the one card
# ============ a new player never reads.
# ============
# ============ The three first-run cards queue now instead of overwriting each
# ============ other: the pack, then the consent question when there is somewhere
# ============ to send reports, then the primer. Closing one shows the next.

SubRx @'
function maybeWelcome(){
  if(P.welcomed){ maybeShareAsk(); return; }
  if(!welcomeFresh()){ P.welcomed=1; saveProfile(); maybeShareAsk(); return; }
'@ @'
// v10.66: the first-run cards, in order, one at a time. Each one calls this as
// it closes, so the next thing that is still owed is shown instead of being
// painted over. Nothing here decides WHETHER a card is due; each maybe still
// owns its own rule.
function firstRunNext(){
  if(document.querySelector('.modal.on')) return;   // he is reading one already
  if(typeof maybeWelcome==='function'&&!P.welcomed){ maybeWelcome(); if(document.querySelector('.modal.on')) return; }
  if(typeof maybeShareAsk==='function'){ maybeShareAsk(); if(document.querySelector('.modal.on')) return; }
  if(typeof maybePrimer==='function') maybePrimer();
}
function maybeWelcome(){
  if(P.welcomed){ maybeShareAsk(); return; }
  if(!welcomeFresh()){ P.welcomed=1; saveProfile(); maybeShareAsk(); return; }
'@

# The three closes hand over to the next card instead of ending the queue.
SubRx @'
    try{ say2('The welcome pack is in your stash.'); }catch(e2){}
    maybeShareAsk();   // v10.39: the question follows the pack
  };
  document.getElementById('welcomeno').onclick=function(){ P.welcomed=1; saveProfile(); md.classList.remove('on'); maybeShareAsk(); };
'@ @'
    try{ say2('The welcome pack is in your stash.'); }catch(e2){}
    firstRunNext();   // v10.39: the question follows the pack; v10.66: and the primer follows that
  };
  document.getElementById('welcomeno').onclick=function(){ P.welcomed=1; saveProfile(); md.classList.remove('on'); firstRunNext(); };
'@
SubRx @'
    md.classList.remove('on');
    try{ say2('Run reports will be sent as each raid ends. Settings can turn it off.'); }catch(_sy){}
  };
  document.getElementById('shareno').onclick=function(){
    P.shareRuns=false; P.shareAsked=1; saveProfile();
    md.classList.remove('on');
  };
'@ @'
    md.classList.remove('on');
    try{ say2('Run reports will be sent as each raid ends. Settings can turn it off.'); }catch(_sy){}
    firstRunNext();   // v10.66
  };
  document.getElementById('shareno').onclick=function(){
    P.shareRuns=false; P.shareAsked=1; saveProfile();
    md.classList.remove('on');
    firstRunNext();   // v10.66
  };
'@

# Arrival asks the queue, rather than opening two cards on top of each other.
SubRx @'
    maybePrimer();   // v7.88: the call site the primer never had
    maybeWelcome();  // v10.29: and the welcome pack, once, over it
'@ @'
    // v10.66: one at a time and in order, or the pack paints over the primer
    // and a new player never reads the only card that teaches the game.
    firstRunNext();
'@

# The primer is owed until it is READ, not until a raid happens: a new player
# who goes straight up should still meet it when he comes back down.
SubRx @'
function maybePrimer(){
  if(P.primerOff||P.primerSeen) return;
  // v7.88: a profile that has already finished raids does not need the
  // onboarding card - stamp it quietly instead of showing it late.
  if((P.runs||0)>0){ P.primerSeen=1; saveProfile(); return; }
  openPrimer();
}
'@ @'
function maybePrimer(){
  if(P.primerOff||P.primerSeen) return;
  // v7.88 stamped this away for any profile with a raid behind it, so that a
  // long-standing save would not meet the onboarding card late. v10.66: that
  // also silenced it for the player it was written for, because the welcome
  // pack painted over it on the one arrival where runs was still 0. It is owed
  // until it has been READ, and three raids is where a new player has stopped
  // being new.
  if((P.runs||0)>3){ P.primerSeen=1; saveProfile(); return; }
  openPrimer();
}
'@

SubRx @'
var VER='10.65';
'@ @'
var VER='10.66';
'@
SubRx @'
  now:'v10.65: the card at the end of a raid has a Copy report button. It logs the raid, puts the whole report on your clipboard and says so, so a friend can paste it straight to Daniel without hunting through Settings for it.',
'@ @'
  now:'v10.66: a new character actually gets the briefing. The welcome pack used to open on top of FIRST TIME OUT and destroy it, so the one card that teaches the game was never read by anyone new. The cards wait their turn now.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
