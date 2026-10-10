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

# A DISTRICT CONTRACT NAMES THE RIGHT PLACE EVERYWHERE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    G.tel.contractsMid.push({desc:c.desc||'contract',
      label:(c.type==='kill'?('kill-'+c.tgt):c.type)});
    // v8.68, his wording.
    if(!G.sim) say('CONTRACT DONE: '+(c.desc||'contract')+'. Complete contract at mainframe.');
'@ @'
    // v22.12, from the whole-game bug hunt of 2026-10-08 (K24): THE DONE LINE AND THE RUN CARD NAME THE PLACE ON THIS SECTOR. A
    // district contract writes its sentence once, for the sector picked when it was rolled, so after a change of sector this line
    // and the card's CONTRACT COMPLETE named a place on the other sector. contractDesc works the place out live, as the board row
    // and the raid panel already do; every other kind of contract reads exactly as before.
    G.tel.contractsMid.push({desc:contractDesc(c),
      label:(c.type==='kill'?('kill-'+c.tgt):c.type)});
    // v8.68, his wording.
    if(!G.sim) say('CONTRACT DONE: '+contractDesc(c)+'. Complete contract at mainframe.');
'@

SubRx @'
    '<h4>'+escHtml(c.desc||'Contract')+'</h4>'+
'@ @'
    '<h4>'+escHtml((c.desc||c.type==='district')?contractDesc(c):'Contract')+'</h4>'+   // v22.12 (K24): the place on the sector he is playing, as the board row
'@

SubRx @'
var VER='22.11';
'@ @'
var VER='22.12';
'@

$pat = "(?m)^  now:'v22\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.12: A district contract names the place on the sector you are playing on the Mainframe card, in the raid and on the run card. Check 22.12 fails on v22.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
