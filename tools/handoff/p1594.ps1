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

# THE HIRE DEATH LINE DECIDES YOU ARE IN DEBT ONLY AFTER THE RUN MONEY HAS LANDED. The death benefit line in endRaid read
# P.credits the moment the benefit came off, before the stall money and the hazard pay of the same extraction landed further
# down the function, so it said you were in debt beside a positive settled balance. The clause is now decided on what the
# extraction is about to bank. No number moves: the benefit, the balance and every sum below are unchanged.
SubRx @'
      P.credits-=MERC_DEATH;
      lines.push('<span style="color:var(--rust)">'+mname+' died. Death benefit '+'$'+MERC_DEATH.toLocaleString()+' owed'+(P.credits<0?', you are in debt':'')+'.</span>');
'@ @'
      P.credits-=MERC_DEATH;
      // v15.94, credits audit finding: THE HIRE DEATH LINE DECIDES YOU ARE IN DEBT ONLY AFTER THE RUN MONEY HAS LANDED. This
      // line read P.credits the moment the death benefit came off, but on an extraction two credits land further down this same
      // function: hazard pay (Math.round(Math.max(0,haul-(G.carriedIn||0))*tPay), paid only when tPay>0) and the stall money
      // the Peddler deal left riding with you (G.pedCarry, which v7.62 carries and never banks at the sale). Only rack pay lands
      // before this line. So with $1,000 banked, a dead hire and $3,000 of stall money, the card said the benefit put you in
      // debt, decided at -2,400, while the money line of the same card and the Undercroft header showed $600 banked. The clause
      // could only ever be wrong in that direction, and only on an extraction: on a death or an abandon nothing lands after it.
      // It is now decided on what the extraction is about to bank, the same two sums the lines below add (termsPay() is pure
      // and is the tPay computed below; both terms are zero when absent). The amount owed, the balance and every number are
      // unchanged, and no seeded draw moves.
      var _mdIn=P.credits+((how==='extract')?((G.pedCarry||0)+Math.round(Math.max(0,haul-(G.carriedIn||0))*termsPay())):0);
      lines.push('<span style="color:var(--rust)">'+mname+' died. Death benefit '+'$'+MERC_DEATH.toLocaleString()+' owed'+(_mdIn<0?', you are in debt':'')+'.</span>');
'@
SubRx @'
var VER='15.93';
'@ @'
var VER='15.94';
'@

$pat = "(?m)^  now:'v15\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.94: THE HIRE DEATH LINE DECIDES YOU ARE IN DEBT ONLY AFTER THE RUN MONEY HAS LANDED. With money banked, a dead hire and stall money or hazard pay coming home with you, the extraction card said the death benefit put you in debt while the money line of the same card and the Undercroft showed a positive balance, because the line was decided before the stall money and the hazard pay landed further down. The line now counts what the extraction is about to bank and says you are in debt only when the settled balance is below zero. Check 15.94 ends three staged extractions with a dead hire and reads the line beside the settled balance; it fails on v15.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
