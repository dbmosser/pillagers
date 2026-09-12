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

# FROM THE 2026-09-11 READ-ONLY AUDIT, and it is the most dangerous thing that
# audit found, because it is a promise made at the exact moment it can be broken.
#
# Restoring a backup replaces everything: credits, stash, armoury, wear,
# contracts, the run log, every Settings choice. The row that offers it says, in
# so many words, that the profile he is on right now is kept "in case you picked
# the wrong file". He reads that, picks a file, and if it was the wrong one, goes
# looking for the way back.
#
# THERE IS NO WAY BACK. The outgoing profile really is written, to
# salvagerun:profile:prerestore, and that string appears exactly once in the
# whole game. Nothing reads it. No button, no screen, no toast. The one sentence
# that makes it safe to press PICK FILE is the sentence that is untrue, and he
# only finds out after he has already lost the save the promise was about.
#
# THE FIX IS THE BUTTON, NOT THE SENTENCE. The data is already there and has been
# all along; only the way back was missing, so building it is a smaller change
# than deleting the promise and it leaves him better off than the wording ever
# claimed. UNDO appears on that row only when there is something to undo.
#
# IT RELOADS RATHER THAN RE-RENDERING, deliberately, and that is the same choice
# the friend restore-code path already makes. A profile arriving mid-session has
# to be applied everywhere at once, and the audit found a second defect in this
# very handler from not doing that: the stash layout is not re-applied on restore,
# so the Settings row and the grid disagree until the next reload. A reload cannot
# have that class of bug.
SubRx @'
    '<div class="row"><div style="flex:1"><b>Restore from a backup</b><div class="hint">Pick a backup file and your profile becomes what it was when you saved it. The profile you are on right now is kept under the hood until the next restore, in case you picked the wrong file.</div></div>'+
    '<button id="set_restore" style="padding:6px 12px">PICK FILE</button></div>'+
'@ @'
    '<div class="row"><div style="flex:1"><b>Restore from a backup</b><div class="hint">Pick a backup file and your profile becomes what it was when you saved it. The profile you are on right now is kept until the next restore, so if you pick the wrong file, UNDO puts it back.</div></div>'+
    '<button id="set_restore" style="padding:6px 12px">PICK FILE</button>'+
    // v12.85, 2026-09-11 audit: THE WAY BACK, which the sentence above has been
    // promising since v8.75 and which did not exist. The outgoing profile was
    // already being written to a key nothing ever read. The button only appears
    // when there is something behind it.
    (hasPreRestore()?'<button id="set_unrestore" style="padding:6px 12px;margin-left:8px">UNDO</button>':'')+
    '</div>'+
'@

SubRx @'
  document.getElementById('set_restore').onclick=function(){
'@ @'
  // v12.85: is there a profile to go back to. Kept to one place so the button and
  // the handler can never disagree about whether the way back exists.
  function preRestoreRaw(){
    try{ return localStorage.getItem('salvagerun:profile:prerestore')||''; }catch(_e){ return ''; }
  }
  function hasPreRestore(){
    var r=preRestoreRaw(); if(!r) return false;
    try{ var d=JSON.parse(r); return !!(d&&typeof d.credits==='number'); }catch(_e){ return false; }
  }
  var _unb=document.getElementById('set_unrestore');
  if(_unb) _unb.onclick=function(){
    var raw=preRestoreRaw(), d3=null;
    try{ d3=JSON.parse(raw); }catch(_e){}
    if(!d3||typeof d3.credits!=='number'){ say('There is no profile to go back to.'); return; }
    // The one he is on now becomes the thing UNDO goes back to, so pressing it
    // twice returns him to where he was rather than stranding him.
    try{ localStorage.setItem('salvagerun:profile:prerestore',JSON.stringify(P)); }catch(_e2){}
    storeSet(JSON.stringify(d3));
    say('Put back: '+(d3.runs||0)+' runs, '+'$'+(d3.credits||0).toLocaleString()+'. Reloading.');
    setTimeout(function(){ try{ location.reload(); }catch(_e3){} },700);
  };
  document.getElementById('set_restore').onclick=function(){
'@

# NEW IN.
SubRx @'
  'EQUIPPING A GUN TELLS YOU WHAT HAPPENED TO THE ONE IT REPLACED. That a loaner was left behind, or that a gun you own went back to the armoury rather than into your backpack, was written and then written over by the name of the gun you had just chosen, in the same frame, every time.',
'@ @'
  'EQUIPPING A GUN TELLS YOU WHAT HAPPENED TO THE ONE IT REPLACED. That a loaner was left behind, or that a gun you own went back to the armoury rather than into your backpack, was written and then written over by the name of the gun you had just chosen, in the same frame, every time.',
  'RESTORING A BACKUP CAN BE UNDONE, WHICH THE SETTINGS ROW HAS BEEN PROMISING FOR A WHILE. Your outgoing profile was already being kept, and nothing in the game could read it back. There is an UNDO button on that row now, and it only appears when there is something behind it.',
'@

# STAMPS.
SubRx @'
var VER='12.84';
'@ @'
var VER='12.85';
'@
SubRx @'
var WHATSNEW_VER='12.84';
'@ @'
var WHATSNEW_VER='12.85';
'@
$cnt=([regex]::Matches($s,"now:'v12\.84:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.84 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.84:[^']*'",{ param($m) "now:'v12.85: from the 2026-09-11 read-only audit, and the most dangerous thing that audit found, because it is a promise made at the exact moment it can be broken. Restoring a backup replaces everything: credits, stash, armoury, wear, contracts, the run log and every Settings choice. The row that offers it said, in so many words, that the profile he is on right now is kept in case he picked the wrong file. He reads that, picks a file, and if it was the wrong one he goes looking for the way back. There was no way back. The outgoing profile really is written, to a key whose name appears exactly once in the whole game, and nothing reads it: no button, no screen, no toast. The one sentence that makes it safe to press PICK FILE was the sentence that was untrue, and he would only find out after he had already lost the save the promise was about. THE FIX IS THE BUTTON, NOT THE SENTENCE: the data was already there all along and only the way back was missing, so building it is a smaller change than deleting the promise and leaves him better off than the wording ever claimed. UNDO appears on that row only when there is something behind it, and pressing it twice returns him to where he was rather than stranding him. It reloads rather than re-rendering, deliberately, and that is the same choice the friend restore-code path already makes: a profile arriving mid-session has to be applied everywhere at once, and the same audit found a second defect in this very handler from not doing that, because the stash layout is not re-applied on restore and the Settings row and the grid disagree until the next reload. A reload cannot have that class of bug. Check 12.85 restores over a staged profile, presses UNDO and requires the stored save to be the one he started with, with a control that the button is absent and the handler refuses when there is nothing to go back to; fails on v12.84.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
