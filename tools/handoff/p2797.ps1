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

# THE DEMO BOARD HAS TWENTY ROWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ARCADE_BOARD={keep:100,night:12*3600000,top:10,iniMs:20000,mirMs:25000};
'@ @'
// v27.xx (board20), HIS ANSWERS 12 and 13 (2026-10-13): the DEMO high score board has TWENTY rows (top, was 10), and it is reset ONLY through NEW PARTY in
// the operator menu: the 12 hour night no longer drops a row off it (arcadeBoardTonight counts every run since the last NEW PARTY, or all of them when there has
// been none) and the party seed no longer ends at 12 hours either. The page shows the twenty in two columns of ten. BEST EVER is unchanged.
var ARCADE_BOARD={keep:100,night:12*3600000,top:20,iniMs:20000,mirMs:25000};
'@

SubRx @'
var since=Math.max(now-ARCADE_BOARD.night,(typeof arcadePartyAt==='function')?arcadePartyAt():0);
'@ @'
var since=(typeof arcadePartyAt==='function')?arcadePartyAt():0;
'@

SubRx @'
function arcadePartySeed(){ var o=arcadePartyRec(), s=(+o.s)>>>0; return (s&&(+o.t||0)>0&&Date.now()-o.t<ARCADE_BOARD.night)?s:0; }
'@ @'
function arcadePartySeed(){ var o=arcadePartyRec(), s=(+o.s)>>>0; return (s&&(+o.t||0)>0)?s:0; }   // v27.xx (board20): the seed lasts until the next NEW PARTY, as the board does
'@

SubRx @'
  for(i=0;i<rows.length&&i<10;i++){ r=rows[i]||{}; arcadeAttLine(pg,'apr'
'@ @'
  var cols=null, c1=null, c2=null;
  if(rows.length>10){ cols=document.createElement('div'); cols.className='apcols'; c1=document.createElement('div'); c1.className='apcol'; c2=document.createElement('div'); c2.className='apcol'; cols.appendChild(c1); cols.appendChild(c2); pg.appendChild(cols); }   // v27.xx (board20): ten rows a column
  for(i=0;i<rows.length&&i<ARCADE_BOARD.top;i++){ r=rows[i]||{}; arcadeAttLine(cols?(i<10?c1:c2):pg,'apr'
'@

SubRx @'
.apb{color:#ff8a1f;margin-top:.35em}'+
'@ @'
.apb{color:#ff8a1f;margin-top:.35em}#attract .arcpage .apcols{display:flex;gap:3.2em;justify-content:center;align-items:flex-start}#attract .arcpage .apcol{min-width:13em}'+
'@

SubRx @'
var VER='27.96';
'@ @'
var VER='27.97';
'@

$pat = "(?m)^  now:'v27\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.97: The DEMO high score board holds twenty rows and is cleared only by NEW PARTY in the operator menu. Check 27.97 fails on v27.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
