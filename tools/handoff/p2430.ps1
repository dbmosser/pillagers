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

# RUN OVER: THE SCORE COUNTS UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeOverSync(){

'@ @'
// v23.xx, HIS ANSWERS (2026-10-12), answer 20: "RUN OVER: score count-up plus best moments". THE SCORE COUNTS UP. The RUN OVER card
// showed the final score at once. Now the score rolls up from $0 to the final figure over 1.4 s (fast first, settling at the end),
// timed from the run end (ARCADE.over.at), so a rebuild of the card (a letter of the initials) carries on where it was and never
// starts the count again. Only the number moves; the line around it (SCORE, TEAM SCORE) is the card's own. A rAF step keeps it
// smooth and the half second attract tick sets it too, so a window with no frames still lands on the final score.
var ARCADE_OVER_CU=1400;
function arcadeOverCount(c,o){
  var el=c&&c.querySelector('.aos'), full, fin, k, v, t;
  if(!el||!o) return false;
  full=el.getAttribute('data-full'); if(full===null){ full=el.textContent; el.setAttribute('data-full',full); }
  fin=arcadeCr(+o.team||0);
  if(full.indexOf(fin)<0) return false;
  k=clamp((Date.now()-(+o.at||0))/ARCADE_OVER_CU,0,1);
  v=Math.round((+o.team||0)*(1-Math.pow(1-k,3)));
  t=full.replace(fin,function(){ return arcadeCr(v); });
  if(el.textContent!==t) el.textContent=t;
  c.setAttribute('data-cu',k<1?'1':'0');
  if(k<1&&!o.cuRaf&&typeof requestAnimationFrame==='function'){ o.cuRaf=1; requestAnimationFrame(function(){ o.cuRaf=0; try{ if(ARCADE.over===o&&c.style.display!=='none') arcadeOverCount(c,o); }catch(_cu){} }); }
  return k<1;
}
function arcadeOverSync(){

'@

SubRx @'
    if(ini) arcadeIniDraw(c,ini);
  }
  c.style.display=on?'block':'none';

'@ @'
    if(ini) arcadeIniDraw(c,ini);
  }
  if(on&&oc){ try{ arcadeOverCount(c,o); }catch(_cu){} }   // v23.xx (his answer 20): the score counts up
  c.style.display=on?'block':'none';

'@

SubRx @'
var VER='24.29';
'@ @'
var VER='24.30';
'@

$pat = "(?m)^  now:'v24\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.30: The RUN OVER score counts up from $0 to the final score. Check 24.30 fails on v24.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
