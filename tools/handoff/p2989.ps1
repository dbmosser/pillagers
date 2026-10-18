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

# Abandon question: a named title, one amber primary, a snug card (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox::after{ box-sizing:border-box; width:var(--pw); max-width:100%; text-align:right; }
'@ @'
#root #pausebox::after{ box-sizing:border-box; width:var(--pw); max-width:100%; text-align:right; }
/* v28.xx (cw-confirm59) the critic on screen 59, the abandon question (2 of 5): "two identical red buttons", "title still says Raid paused", "dead space in a 556px card". Now: the title asks Abandon this run, Keep playing is the one amber primary on top, the YES button is a plain red outline under it, and the card shrinks to 320px around the two buttons. */
#root #pausebox.asking #abandonbtn{ order:-1; margin-top:0 !important; background:var(--acc); border-color:var(--acc) !important; color:var(--acc-ink) !important; }
#root #pausebox.asking #abandonbtn:hover{ filter:brightness(1.08); }
#root #pausebox.asking #confirmabandon{ margin-top:var(--sp-3); background:transparent; border-color:var(--danger) !important; color:var(--danger) !important; }
#root #pausebox.asking::before{ height:min(calc(var(--sp-1) * 40),calc(100% - var(--sp-4))) !important; }
'@

SubRx @'
function disarmAbandon(){
'@ @'
// v28.xx (cw-confirm59): "title still says Raid paused": while the question is up the title asks it, and any disarm gives the old title back.
function pauseAskTitle(on){
  var h=document.querySelector('#pausebox h3'); if(!h) return;
  if(on){ if(!h.hasAttribute('data-was')) h.setAttribute('data-was',h.textContent); h.textContent='Abandon this run?'; }
  else if(h.hasAttribute('data-was')){ h.textContent=h.getAttribute('data-was'); h.removeAttribute('data-was'); }
}
function disarmAbandon(){
  try{ pauseAskTitle(false); }catch(_pa){}
'@

SubRx @'
this.textContent='NO, keep playing';
'@ @'
this.textContent='Keep playing'; try{ pauseAskTitle(true); }catch(_pt){}   // v28.xx (cw-confirm59): "two identical red buttons": the way back is the amber primary
'@

SubRx @'
try{ var _pbx2=document.getElementById('pausebox'); if(_pbx2) _pbx2.classList.remove('asking'); }catch(_as2){}
'@ @'
try{ var _pbx2=document.getElementById('pausebox'); if(_pbx2) _pbx2.classList.remove('asking'); }catch(_as2){} try{ pauseAskTitle(false); }catch(_pu){}
'@

SubRx @'
var VER='29.88';
'@ @'
var VER='29.89';
'@

$pat = "(?m)^  now:'v29\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.89: Abandon question: clearer title and one primary button. Check 29.89 fails on v29.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
