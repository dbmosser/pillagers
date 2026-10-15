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

# THE PAUSE BOX LISTS WHERE YOU ARE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var k=function(t){ return '<b style="color:var(--bone)">'+t+'</b>'; };
  return k('MOUSE')+' aim &nbsp; '
'@ @'
  var k=function(t){ return '<b style="color:var(--bone)">'+t+'</b>'; };
  // v27.xx, UI CLEANUP uic5 (his 2026-10-14 note, from the 1080p shots of the Undercroft and DEMO pause boxes): THE PAUSE BOX LISTS THE KEYS OF WHERE YOU ARE.
  // The Undercroft box listed the raid (raid status, extraction, drop an item for a teammate) and the DEMO box listed the backpack, ENTER equip, Z drop and ping,
  // keys a walk-up guest has no use for, in 25 keycaps. The floor lists what the floor legend (H) lists; the DEMO lists the rows of its own controls card.
  if(typeof state!=='undefined'&&state==='hub') return s('KeyW')+s('KeyA')+s('KeyS')+s('KeyD')+' walk &nbsp; '+s('ShiftLeft')+' jog &nbsp; '+s('Space')+' roll &nbsp; '+s('KeyE')+' use a station &nbsp; '+s('KeyB')+' / '+s('KeyI')+' backpack &nbsp; '+k('TAB')+' pause, or back out';
  if(typeof G!=='undefined'&&G&&G.arcade&&typeof arcadeCardRows==='function'){ try{ return arcadeCardRows().map(function(r){ return k(r[1])+' '+String(r[0]).toLowerCase(); }).join(' &nbsp; ')+' &nbsp; '+k('TAB')+' pause'; }catch(_ac){} }
  return k('MOUSE')+' aim &nbsp; '
'@

SubRx @'
var VER='27.52';
'@ @'
var VER='27.53';
'@

$pat = "(?m)^  now:'v27\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.53: The pause box lists the keys of the place you are in. Check 27.53 fails on v27.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
