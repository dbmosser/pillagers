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

# THE PAUSE BOX FRAME HOLDS ITS CONTENT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .pausebox::before{ inset:50% auto auto 50%; width:780px; height:400px; transform:translate(-50%,-50%); }
'@ @'
  .pausebox::before{ inset:50% auto auto 50%; width:780px; height:min(var(--pbh,400px),calc(100% - 28px)); transform:translate(-50%,-50%); }   /* v19.90: --pbh from pauseFrameFit() */
'@

SubRx @'
function togglePauseBox(on){
'@ @'
// v19.90, from the code review of 2026-10-08: the pause box frame was a fixed 400px, and with the controller key line (v19.71, six
// lines) plus the BLEEDING OUT and hosting lines its content ran past the frame top and bottom. The frame now fits what is showing,
// never smaller than before. Measured in the box's own layout pixels, so the menu zoom does not matter.
function pauseFrameFit(){
  var b=document.getElementById('pausebox'), i, c, t=1e9, bo=-1e9;
  if(!b||!b.offsetHeight) return false;
  for(i=0;i<b.children.length;i++){ c=b.children[i]; if(c.offsetHeight>0){ t=Math.min(t,c.offsetTop); bo=Math.max(bo,c.offsetTop+c.offsetHeight); } }
  if(!(bo>t)) return false;
  b.style.setProperty('--pbh',Math.max(400,Math.ceil(bo-t)+64)+'px');
  return true;
}
function togglePauseBox(on){
'@

SubRx @'
  })();
  syncPause();
'@ @'
  })();
  syncPause();
  if(on){ try{ pauseFrameFit(); }catch(_pf){} }   // v19.90: the frame fits what is showing
'@

SubRx @'
function keysLegendApply(){ var el=document.getElementById('pausekeys'); if(!el) return false; el.innerHTML=String(keysLegendHtml()).split(' &nbsp; ').map(function(p){ return '<span style="white-space:nowrap">'+p+'</span>'; }).join(' &nbsp; '); return true; }
'@ @'
function keysLegendApply(){ var el=document.getElementById('pausekeys'); if(!el) return false; el.innerHTML=String(keysLegendHtml()).split(' &nbsp; ').map(function(p){ return '<span style="white-space:nowrap">'+p+'</span>'; }).join(' &nbsp; '); try{ pauseFrameFit(); }catch(_pf){} return true; }
'@

SubRx @'
var VER='19.89';
'@ @'
var VER='19.90';
'@

$pat = "(?m)^  now:'v19\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.90: The pause box frame always fits around its text. Check 19.90 fails on v19.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
