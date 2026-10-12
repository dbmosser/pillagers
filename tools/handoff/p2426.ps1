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

# END RUN ASKS TWICE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
document.getElementById('arcendbtn').onclick=function(){ togglePauseBox(false); try{ arcadeRunEnd('menu'); }catch(_are){} };   // v23.39 (arcade16)
'@ @'
// v24.26, HIS ORDER 2026-10-12 (his #39, full controller navigation): END RUN ARMS FIRST. END RUN ended the whole demo run on one press,
// with no confirm, and on a pad the highlight opens on RESUME, so one D-pad step and A threw a party run away. The first press now
// arms it and reads END RUN? PRESS AGAIN; a second press within 3 seconds ends the run; after 3 seconds, or when the box is opened
// again, it reads END RUN and is safe once more. The mouse, ENTER and the pad A all press the same button, so all three get it.
var ARC_END_ARM=0;
function arcEndDisarm(){ ARC_END_ARM=0; var b=document.getElementById('arcendbtn'); if(b) b.textContent='END RUN'; }
document.getElementById('arcendbtn').onclick=function(){
  var now=Date.now();
  if(!(ARC_END_ARM>0&&now-ARC_END_ARM<3000)){ ARC_END_ARM=now; this.textContent='END RUN? PRESS AGAIN'; setTimeout(function(){ if(ARC_END_ARM===now) arcEndDisarm(); },3000); return; }
  arcEndDisarm();
  togglePauseBox(false); try{ arcadeRunEnd('menu'); }catch(_are){}
};   // v23.39 (arcade16)
'@

SubRx @'
    if(_aeb) _aeb.style.display=_arcP?'':'none';
'@ @'
    if(_aeb) _aeb.style.display=_arcP?'':'none';
    if(_aeb&&typeof arcEndDisarm==='function') arcEndDisarm();   // v24.26 (his #39): END RUN opens safe, unarmed
'@

SubRx @'
var VER='24.25';
'@ @'
var VER='24.26';
'@

$pat = "(?m)^  now:'v24\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.26: END RUN in the demo asks for a second press before it ends the run. Check 24.26 fails on v24.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
