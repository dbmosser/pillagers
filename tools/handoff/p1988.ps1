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

# THE UNDERCROFT PAUSE BOX LISTS THE FLOOR PAD BUTTONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(PAD&&PAD.on&&typeof LEGEND_PAD!=='undefined'&&LEGEND_PAD) return LEGEND_PAD.map(
'@ @'
  // v19.88, from the code review of 2026-10-08: in the Undercroft the pad does other things (A works a station, X, Y and RB are its
  // other actions, LS click jogs; the floor branch of pollPad), so the box there lists the floor buttons, not the raid ones.
  if(PAD&&PAD.on&&(typeof G==='undefined'||!G||state==='hub')) return [['L STICK','walk'],['LS CLICK','jog'],['A','use a station'],['X / Y / RB','the other station actions'],['Y','take a teammate offer'],['VIEW','backpack'],['MENU','pause']].map(function(r){ return '<b style="color:var(--bone)">'+padB(r[0])+'</b> '+r[1]; }).join(' &nbsp; ');
  if(PAD&&PAD.on&&typeof LEGEND_PAD!=='undefined'&&LEGEND_PAD) return LEGEND_PAD.map(
'@

SubRx @'
var VER='19.87';
'@ @'
var VER='19.88';
'@

$pat = "(?m)^  now:'v19\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.88: Pausing in the Undercroft on a controller shows the Undercroft controller buttons. Check 19.88 fails on v19.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
