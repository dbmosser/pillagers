$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
    P.xp=Math.max(0,(P.xp||0)-_rc);
    say(_rc>0?('Walked out on the job. XP -'+_rc+'.'):'Walked out on the job. No XP to lose.');
'@ @'
    P.xp=Math.max(0,(P.xp||0)-_rc);
    // v15.09, quit audit finding 7: AN ABANDON THAT COSTS XP SAYS SO ON THE OUTCOME CARD. The line below is drawn on the raid
    // screen, and endRaid covers that screen with the outcome card in this same click, so the fee was never read and the card's
    // XP total came out lower than the XP it printed with nothing to explain it. The raid keeps the fee for the card and the report.
    G.abandonFee=_rc;
    say(_rc>0?('Walked out on the job. XP -'+_rc+'.'):'Walked out on the job. No XP to lose.');
'@
SubRx @'
    lines.push('Run abandoned. '+'$'+haul.toLocaleString()+' left behind.');
'@ @'
    lines.push('Run abandoned. '+'$'+haul.toLocaleString()+' left behind.');
    // v15.09, quit audit finding 7: AND THE FEE THE CONFIRM TOOK, ON ITS OWN LINE. The XP line above is his baked wording and its
    // total is counted after the fee, so this line is what explains the drop. A new line: no baked key is reworded.
    if(G.abandonFee>0) lines.push('<span style="color:var(--rust)">Walked out on the job. XP -'+G.abandonFee+'.</span>');
'@
SubRx @'
    dur:Math.round(elapsed()),
'@ @'
    dur:Math.round(elapsed()),
    abandonFee:G.abandonFee||0,   // v15.09, quit audit finding 7: the XP a walk-out cost, so the run report can say it
'@
SubRx @'
    if(r.outcome==='dead') line+=' killer:'+r.deathKiller+' diedAt:'+metres(r.deathDistExtract)+'m';
'@ @'
    if(r.outcome==='dead') line+=' killer:'+r.deathKiller+' diedAt:'+metres(r.deathDistExtract)+'m';
    // v15.09, quit audit finding 7: THE RUN REPORT NAMES THE ABANDON FEE. The row kept the run's own XP and nothing of the fee.
    if(r.abandonFee) line+=' abandonFee:'+r.abandonFee;
'@
SubRx @'
var VER='15.08';
'@ @'
var VER='15.09';
'@

$pat = "(?m)^  now:'v15\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.09: AN ABANDON THAT COSTS XP SAYS SO ON THE OUTCOME CARD. Walking out after the first minute takes an XP fee, and the only line that said so was drawn on the raid screen in the same click that covered it with the outcome card, so the card showed a lower XP total with nothing to explain it. The card now shows the fee on its own line and the run report records it. Check 15.09 walks out five minutes in with 5000 XP and reads the card, the run record and the report; it fails on v15.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
