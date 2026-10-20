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

# PRE-RAID: LABELS ON A DARK PILL, A BIGGER WINDOW TITLE, A QUIETER ARMOUR ROW AND BIGGER STEPPERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function put(s,x,y){ c.lineJoin='round'; c.lineWidth=2; c.strokeStyle='rgba(8,18,28,.6)'; c.strokeText(String(s).toLowerCase(),x,y); c.fillText(s,x,y); }
'@ @'
function put(s,x,y){ var tw=c.measureText(String(s)).width, tx=(c.textAlign==='right')?x-tw:((c.textAlign==='center')?x-tw/2:x), fh=parseInt((c.font.match(/(\d+)px/)||[0,16])[1],10), f0=c.fillStyle; c.fillStyle='rgba(11,12,13,.78)'; c.fillRect(tx-5,y-fh+2,tw+10,fh+5); c.fillStyle=f0; c.fillText(s,x,y); }
'@

SubRx @'
c.font='600 18px '+FF; c.textAlign='right'; c.fillStyle='#dcc3f4';
'@ @'
c.font='600 18px '+FF; c.textAlign='right'; c.fillStyle='#e6f1fb';
'@

SubRx @'
#root #sectormodal h3{ align-items:center; gap:16px; padding-bottom:8px; margin-bottom:10px; }
'@ @'
#root #sectormodal h3{ align-items:center; gap:16px; padding-bottom:8px; margin-bottom:10px; font-size:32px; }
'@

SubRx @'
#sectormodal .srmh b{ font:700 32px/1 var(--f-cond);
'@ @'
#sectormodal .srmh b{ font:700 24px/1 var(--f-cond);
'@

SubRx @'
<span class="hn">'+k('ENTER')+'ASCEND</span>
'@ @'

'@

SubRx @'
#sectormodal .wn b{ font:700 20px var(--f-cond); }
'@ @'
#sectormodal .wn b{ font:500 16px var(--f-cond); }
'@

SubRx @'
border:0; background:none; border-radius:0; color:var(--warn);
'@ @'
border:0; border-left:3px solid var(--warn); background:none; border-radius:0; color:var(--warn);
'@

SubRx @'
width:36px; height:36px; min-width:0; padding:0; display:grid;
'@ @'
width:44px; height:44px; min-width:0; padding:0; display:grid;
'@

SubRx @'
var VER='32.56';
'@ @'
var VER='32.57';
'@

$pat = "(?m)^  now:'v32\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.57: The pre-raid page labels are easier to read, the title is bigger than the map name, and the plus and minus buttons are bigger. Check 32.57 fails on v32.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
