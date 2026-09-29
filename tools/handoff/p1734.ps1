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

# THE KIT WAIT NO LONGER STARTS THE HOST RAID BEHIND THE CHARACTER SELECTION TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(typeof state!=='undefined'&&state!=='hub') return false;
'@ @'
  if(typeof state!=='undefined'&&state!=='hub') return false;
  // v17.34, co-op hunt 2026-09-28: and never behind the character selection title, which leaves state at hub. A kit answer or
  // the timer that ran out there started the host raid under the title, and leaving the title then stranded the party up top.
  var _kt=document.getElementById('title');
  if(_kt&&_kt.classList.contains('on')) return false;
'@

SubRx @'
  if(G) return;                       // never from inside a raid
'@ @'
  if(G) return;                       // never from inside a raid
  // v17.34, co-op hunt 2026-09-28: a kit wait still standing from the lift is dropped, so it cannot start the raid behind the title.
  if(typeof NET==='object'&&NET&&NET.kitWait){ clearTimeout(NET.kitWait.tm); NET.kitWait=null; NET.status=''; }
'@

SubRx @'
  NET.pend=null; NET.on=false; NET.role=null; NET.seat=-1; NET.roster=[]; NET.code=''; NET.reply=''; NET.codeLen=0; NET.busy=false;
'@ @'
  NET.pend=null; NET.on=false; NET.role=null; NET.seat=-1; NET.roster=[]; NET.code=''; NET.reply=''; NET.codeLen=0; NET.busy=false;
  if(NET.kitWait){ clearTimeout(NET.kitWait.tm); NET.kitWait=null; }   // v17.34, co-op hunt 2026-09-28: and no kit wait is left to send anyone up
'@

SubRx @'
var VER='17.33';
'@ @'
var VER='17.34';
'@

$pat = "(?m)^  now:'v17\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.34: Kit wait, co-op hunt 2026-09-28: netKitGo only refused when state was not hub, and the character selection title is an overlay that leaves state at hub. So a kitok from player 2, or the 15 s timer, ran ascendNow while the title was up: the kit was committed, the raid built, player 2 sent up, and the host raid ran behind the title. Nothing on that path shuts the title, and ENTER on the title then called showScreen hub with G still live, so the host stopped stepping the shared world and the next ascent built a raid over the unfinished one. netKitGo now also refuses while the title is on (the same test hubModalOpen makes since v12.06), and RETURN TO CHARACTER SELECTION and netReset clear a standing NET.kitWait and its waiting line. A refused wait leaves player 2 safe on the floor, since his answer commits nothing until the host word arrives. No number moved. Check 17.34 fails on v17.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
