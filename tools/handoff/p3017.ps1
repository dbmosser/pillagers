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

# SETTINGS PANE FOLLOWS THE ROWS IN VIEW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function rowOf(t){ var r=(t&&t.closest)?t.closest('.row'):null; return (r&&sl.contains(r))?r:null; }
  function sync(){
    pend=0;
    var pf=sl.querySelector('.padfocus'), r=pf?rowOf(pf):null, q, i;
    if(!real(r)&&hov){ q=sl.querySelectorAll('.row'); for(i=0;i<q.length;i++){ var bb=q[i].querySelector('div > b'); if(bb&&bb.textContent===hov){ r=q[i]; break; } } }
    if(!real(r)){ q=sl.querySelectorAll('.row'); r=null; for(i=0;i<q.length;i++) if(real(q[i])){ r=q[i]; break; } }
    if(!r){ if(dt.innerHTML) dt.innerHTML=''; return; }
'@ @'
function rowOf(t){ var r=(t&&t.closest)?t.closest('.row'):null; return (r&&sl.contains(r))?r:null; }
  // v28.xx (cw-setvis) critic c-31 (Settings 72 at 2, P0): "the detail pane names a row that is not on screen (Edit the words) and no row is visibly focused". The pane and the focus look now name the first row IN VIEW when nothing is pointed at, and follow the list as it scrolls or jumps to a tab.
  function vis(x){ var a=sl.getBoundingClientRect(), c=x.getBoundingClientRect(), m=(c.top+c.bottom)/2; return !a.height||(m>=a.top&&m<=a.bottom); }
  function sync(){
    pend=0;
    var pf=sl.querySelector('.padfocus'), r=pf?rowOf(pf):null, q, i;
    if(!real(r)&&hov){ q=sl.querySelectorAll('.row'); for(i=0;i<q.length;i++){ var bb=q[i].querySelector('div > b'); if(bb&&bb.textContent===hov&&vis(q[i])){ r=q[i]; break; } } }
    if(!real(r)){ q=sl.querySelectorAll('.row'); r=null; for(i=0;i<q.length;i++) if(real(q[i])&&vis(q[i])){ r=q[i]; break; } }
    if(!r){ q=sl.querySelectorAll('.row'); for(i=0;i<q.length;i++) if(real(q[i])){ r=q[i]; break; } }
    if(!r){ if(dt.innerHTML) dt.innerHTML=''; return; }
'@

SubRx @'
  sl.addEventListener('mouseover',function(e)
'@ @'
  sl.addEventListener('scroll',soon,{passive:true});
  sl.addEventListener('mouseover',function(e)
'@

SubRx @'
var VER='30.16';
'@ @'
var VER='30.17';
'@

$pat = "(?m)^  now:'v30\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.17: Settings detail and focus follow the first row in view. Check 30.17 fails on v30.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
