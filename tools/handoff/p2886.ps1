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

# STASH VALUE AND BAG VALUE IN THE TOP RIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var _trLast='';

'@ @'
// v28.xx (cw-stashbag), HIS ORDER (2026-10-15): "Stash value and bag value are always shown in the top right corner, everywhere, with credits and XP."
// The corner readout gets a second, small line: STASH (what the stash would sell for) and BAG (what the raid bag holds, 0 outside a raid).
function trStash(){ var v=0, i; try{ for(i=0;i<P.stash.length;i++) v+=ival(P.stash[i]); }catch(_ts){} return v; }
function trBag(){ var v=0; try{ if(G&&G.bag&&!G.over) v=bagValue(); }catch(_tb){} return v; }
var _trLast='';

'@

SubRx @'
  var c=(P.credits||0).toLocaleString(), x=(P.xp||0).toLocaleString(), s=c+'|'+x;

'@ @'
  var c=(P.credits||0).toLocaleString(), x=(P.xp||0).toLocaleString(), sv=trStash(), bv=trBag(), s=c+'|'+x+'|'+sv+'|'+bv;   // v28.xx (cw-stashbag)

'@

SubRx @'
  el.innerHTML=c+' <small>CREDITS</small> '+x+' <small>XP</small>';   // spaces, so the text reads right when copied

'@ @'
  el.innerHTML=c+' <small>CREDITS</small> '+x+' <small>XP</small> <span class="trsub">STASH '+sv.toLocaleString()+' BAG '+bv.toLocaleString()+'</span>';   // v28.xx (cw-stashbag): spaces, so the text reads right when copied

'@

SubRx @'
  try{ return el.getBoundingClientRect().bottom||0; }catch(_e){ return 0; }

'@ @'
  try{ return (el.getBoundingClientRect().bottom||0)+Math.round(18*(parseFloat(el.style.zoom)||1)); }catch(_e){ return 0; }   // v28.xx (cw-stashbag): the STASH and BAG line hangs 18 below the readout box

'@

SubRx @'
  #topright small:last-child{ margin-right:0; }

'@ @'
  #topright small:nth-last-child(2){ margin-right:0; }   /* v28.xx (cw-stashbag): the STASH and BAG line is the last child now */
  #topright .trsub{ position:absolute; right:0; top:40px; line-height:16px; font-size:15px; font-weight:700; letter-spacing:.1em; color:var(--ash); }

'@

SubRx @'
var VER='28.85';
'@ @'
var VER='28.86';
'@

$pat = "(?m)^  now:'v28\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.86: The top right corner now also shows STASH and BAG values under credits and XP. Check 28.86 fails on v28.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
