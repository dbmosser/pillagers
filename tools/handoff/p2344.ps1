$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ARCADE: OPERATOR LOCK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeKeyAtt(e){
  if(!ARCADE.on||!e) return false;
'@ @'
// v23.44, HIS YES (2026-10-11), recommendation 1, build 21 (arcade21): THE OPERATOR LOCK. A party machine is played by guests, so the
// only way out of the arcade is a keyboard chord only the operator knows: Ctrl+Shift+F10 runs arcadeLeave, from a raid, the bench,
// the attract or the initials card. In the arcade the pause box offers only RESUME and END RUN (arcade16 already hid Settings and
// Abandon run), and with no arcade raid up there is no pause box at all, so a guest pressing MENU, ESC or P on the attract never
// reaches Settings, character select, the stash or the Mainframe behind it. Only the arcade reaches any of it.
function arcadeOpChord(e){
  if(!e||String(e.type||'')!=='keydown'||String(e.code||'')!=='F10'||!e.ctrlKey||!e.shiftKey||e.altKey||e.metaKey) return false;
  try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){}
  if(e.repeat) return true;
  try{ if(typeof pauseOpen!=='undefined'&&pauseOpen) togglePauseBox(false); }catch(_tp){}
  arcadeLeave();
  return true;
}
function arcadeKeyAtt(e){
  if(!ARCADE.on||!e) return false;
  if(arcadeOpChord(e)) return true;   // v23.44 (arcade21): Ctrl+Shift+F10, the only way out
'@

SubRx @'
  if(!G&&state!=='hub') return;
  pauseOpen=on;
'@ @'
  if(!G&&state!=='hub') return;
  if(on&&!G&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return;   // v23.44 (arcade21): the arcade attract has no pause box (no Settings, no character select)
  pauseOpen=on;
'@

SubRx @'
    if(_rb) _rb.textContent=_inRaid?'Resume run':'RETURN TO THE UNDERCROFT';
    var _cs=document.getElementById('charselbtn');
    if(_cs) _cs.style.display=(_inRaid||_bleed)?'none':'';
'@ @'
    if(_rb) _rb.textContent=_inRaid?'Resume run':'RETURN TO THE UNDERCROFT';
    if(_rb&&_arcP) _rb.textContent='RESUME';   // v23.44 (arcade21): the arcade box is RESUME and END RUN only
    var _cs=document.getElementById('charselbtn');
    if(_cs) _cs.style.display=(_inRaid||_bleed)?'none':'';
    if(_cs&&_arcP) _cs.style.display='none';
'@

SubRx @'
var VER='23.43';
'@ @'
var VER='23.44';
'@

$pat = "(?m)^  now:'v23\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.44: In the arcade only Ctrl+Shift+F10 leaves the mode, the pause box shows only RESUME and END RUN, and the demo screen opens no pause box. Check 23.44 fails on v23.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
