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

# ============ FOUND BY THE v10.96 CHECK ON THE FULL CORPUS, AND IT IS REAL AND
# ============ IT IS DANGEROUS: A PRIMED ABANDON SURVIVES THE BOX CLOSING.
# ============
# ============ Abandon run does not abandon; it arms. The button becomes NO, KEEP
# ============ PLAYING and a red YES, ABANDON THIS RUN appears beside it, which is
# ============ the right design for an irreversible act. But NOTHING disarms it
# ============ except pressing Resume. Close the box with Escape while it is
# ============ armed, which is the fastest way anyone closes anything, and the arm
# ============ is still there the next time the box opens: YES, ABANDON THIS RUN
# ============ sitting live under the pointer, one click from ending the raid he
# ============ came back to finish.
# ============
# ============ HOW IT WAS FOUND: the new check asserts the raid pause box still
# ============ offers a way to abandon, as a control on his Undercroft change. It
# ============ passed alone and failed in the full corpus, because a check twenty
# ============ places earlier had armed the button and walked away. A leak between
# ============ checks is a leak in the game, and this one is his to hit.
# ============
# ============ THE FIX: opening the box disarms it, always. One function does it,
# ============ called from the open and from Resume, rather than two copies of the
# ============ same four lines that can drift apart.
SubRx @'
function togglePauseBox(on){
'@ @'
// v10.96: PUT THE ABANDON BUTTON BACK TO SLEEP. Abandon run arms rather than
// acts, and until now only Resume disarmed it, so closing the box with Escape
// left a live YES, ABANDON THIS RUN waiting for the next time it opened. One
// place decides what disarmed looks like; the open and Resume both ask it.
function disarmAbandon(){
  var _ca=document.getElementById('confirmabandon');
  if(_ca) _ca.style.display='none';
  var _ab=document.getElementById('abandonbtn');
  if(_ab){ _ab.textContent='Abandon run'; _ab.style.borderColor='var(--rust)'; _ab.style.color='var(--rust)'; }
}
function togglePauseBox(on){
'@
SubRx @'
  pauseOpen=on;
  document.getElementById('pausebox').classList.toggle('on',on);
'@ @'
  pauseOpen=on;
  // v10.96: every opening starts unarmed. An arm that outlives the box is a run
  // ended by a misclick on a screen he only opened to read the controls.
  if(on) disarmAbandon();
  document.getElementById('pausebox').classList.toggle('on',on);
'@
SubRx @'
document.getElementById('resumebtn').onclick=function(){
  document.getElementById('confirmabandon').style.display='none';
  var _ab=document.getElementById('abandonbtn');
  _ab.textContent='Abandon run'; _ab.style.borderColor='var(--rust)'; _ab.style.color='var(--rust)';
  var note=document.getElementById('pausenote').value.trim();
'@ @'
document.getElementById('resumebtn').onclick=function(){
  disarmAbandon();   // v10.96: the same four lines this used to carry itself
  var note=document.getElementById('pausenote').value.trim();
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
