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

# JOIN THE RAID IN PROGRESS CAN BE REACHED, BY MOUSE AND BY CONTROLLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var hub=document.getElementById('hub'), b=document.getElementById('joinlate'), want;
'@ @'
  var hub=document.body, b=document.getElementById('joinlate'), want, tt=document.getElementById('title');   // v17.51: on the page, not in the hidden terminal panel
'@

SubRx @'
  want=!!(hub&&NET.on&&NET.role==='join'&&NET.hostSeed&&state==='hub'&&!(typeof G!=='undefined'&&G&&!G.over));
'@ @'
  want=!!(hub&&NET.on&&NET.role==='join'&&NET.hostSeed&&state==='hub'&&!(tt&&tt.classList.contains('on'))&&!(typeof G!=='undefined'&&G&&!G.over));
'@

SubRx @'
    b.style.cssText='position:absolute;left:50%;top:14px;transform:translateX(-50%);z-index:30;padding:6px 18px';
'@ @'
    b.style.cssText='position:fixed;left:50%;top:14px;transform:translateX(-50%);z-index:30;padding:6px 18px';
'@

SubRx @'
function showScreen(s){
  state=s;
'@ @'
function showScreen(s){
  state=s;
  try{ netLateBtn(); }catch(_nlb){}   // v17.51: the drop-in button comes and goes with the floor
'@

SubRx @'
  netSay('Only the host can start the raid. You ascend with them.');
'@ @'
  if(NET.hostSeed&&!(typeof G!=='undefined'&&G&&!G.over)){ netLateAsk(); netSay('Your party is up top. Joining their raid in progress.'); return true; }   // v17.51: the lift joins a raid in progress
  netSay('Only the host can start the raid. You ascend with them.');
'@

SubRx @'
var VER='17.50';
'@ @'
var VER='17.51';
'@

$pat = "(?m)^  now:'v17\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.51: JOIN THE RAID IN PROGRESS now shows on the Undercroft floor while your host is up top, and going up at the lift as a teammate joins the raid in progress, so player 2 on a controller can drop in too. Check 17.51 fails on v17.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
