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

# ============ THE ALPHA, and the one thing standing between a friend having an
# ============ opinion and Daniel ever reading it.
# ============
# ============ He ships to friends inside three days. The end of a raid is the
# ============ one moment a player has an opinion, and the card there already
# ============ asks for it: HOW DID THAT RUN FEEL, the tags, the note box. Then
# ============ the only way to hand any of it over was a Copy to clipboard button
# ============ buried in Settings, behind the Operator Terminal, on a tab called
# ============ the recorder. No friend is going to find that, and there is no
# ============ server to send it to: PUBLIC_DROP is still null, so a friend's
# ============ report goes to their own Downloads folder and stops there.
# ============
# ============ So the card that asks the question also hands you the answer:
# ============ Copy report, right beside Log run and return. It logs the raid
# ============ with the tags and the note attached, exactly as the other button
# ============ does, fills the recorder box with the report so Settings shows the
# ============ same text, copies it, and says so on its own face. The card stays
# ============ open, and pressing Log run and return afterwards cannot log the
# ============ same raid twice.

# 1. The button, and one line telling a friend what it is for.
SubRx @'
  <button style="margin-top:14px;padding:8px 22px" id="oc_btn">Log run and return</button>
'@ @'
  <div style="display:flex;gap:8px;margin-top:14px;flex-wrap:wrap;justify-content:center">
    <button style="padding:8px 22px" id="oc_btn">Log run and return</button>
    <button style="padding:8px 22px" id="oc_copy">Copy report</button>
  </div>
  <div style="font-size:11px;color:var(--ash);margin-top:8px;max-width:520px;line-height:1.5">Copy report puts this raid, and every raid before it, on your clipboard. Paste it to Daniel and the game gets fixed from it.</div>
'@

# 2. The commit both buttons share, so the report can never be copied without the
#    raid you just played in it, and can never be logged twice.
SubRx @'
document.getElementById('oc_btn').onclick=function(){
  if(pendingRun){
    // The tags and the note are collected HERE, so they are attached before the
    // commit when the button is the way out, and patched onto the already
    // written row when the commit happened without him.
    pendingRun.tags=selTags.slice();
    pendingRun.note=document.getElementById('oc_note').value.trim();
    commitRun(pendingRun);
    pendingRun=null;
    saveProfile();
    autoExport();
  }
'@ @'
// v10.65: the one commit, so the copy button and the way out cannot disagree
// about whether this raid was logged, and neither can log it twice.
function ocCommit(){
  if(!pendingRun) return false;
  // The tags and the note are collected HERE, so they are attached before the
  // commit when the button is the way out, and patched onto the already
  // written row when the commit happened without him.
  pendingRun.tags=selTags.slice();
  var _ocn=document.getElementById('oc_note');
  pendingRun.note=_ocn?_ocn.value.trim():'';
  commitRun(pendingRun);
  pendingRun=null;
  saveProfile();
  autoExport();
  return true;
}
document.getElementById('oc_copy').onclick=function(){
  // Log it first, or the report he pastes is missing the raid he just played.
  ocCommit();
  var txt=buildExport();
  // The recorder pane in Settings holds exactly this text, so it is filled from
  // the same string rather than rebuilt later and quietly differing.
  var ta=document.getElementById('exporttext');
  if(ta) ta.value=txt;
  var b=document.getElementById('oc_copy'), was='Copy report';
  function done(){ b.textContent='Copied. Paste it to Daniel.'; setTimeout(function(){ b.textContent=was; },2600); }
  try{
    if(navigator.clipboard&&navigator.clipboard.writeText) navigator.clipboard.writeText(txt).then(done,done);
    else { if(ta){ ta.select(); document.execCommand('copy'); } done(); }
  }catch(_cp){ done(); }
};
document.getElementById('oc_btn').onclick=function(){
  ocCommit();
'@

SubRx @'
var VER='10.64';
'@ @'
var VER='10.65';
'@
SubRx @'
  now:'v10.64: F strikes. You can melee with whatever you are holding instead of only with empty hands, and the controls list says so, in the short list and the full one.',
'@ @'
  now:'v10.65: the card at the end of a raid has a Copy report button. It logs the raid, puts the whole report on your clipboard and says so, so a friend can paste it straight to Daniel without hunting through Settings for it.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
