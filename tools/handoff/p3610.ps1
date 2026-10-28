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

# SHORT CALLOUTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
say('Nothing to pick up.');
'@ @'
say('nothing to pick up'); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('Self-revive spent. One per raid.');
'@ @'
say('self-revive spent','info',{sub:'one per raid'}); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('SELF-REVIVE USED','info',{sub:'Back on your feet.'});
'@ @'
say('SELF-REVIVE USED','info',{sub:'back on your feet'}); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('SEAL BROKEN','obj',{sub:'Seal payout dropped.'});
'@ @'
say('SEAL BROKEN','obj',{sub:'seal payout dropped'}); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
    say('HOT GROUND MOVED','obj',{sub:'Check your map.'});
'@ @'
    say('HOT GROUND MOVED','obj',{sub:'check map'}); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
if(!G.sim) say('HOT GROUND MOVED','obj',{sub:'Check your map.'});
'@ @'
if(!G.sim) say('HOT GROUND MOVED','obj',{sub:'check map'}); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('The mainframe wall is full.');
'@ @'
say('mainframe wall full'); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('Not enough parts. '+rackCostLine());
'@ @'
say('not enough parts: '+rackCostLine()); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('Enter a name first.');
'@ @'
say('name required'); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('That is not a Pillagers run report.');
'@ @'
say('invalid pillagers run report'); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('A core is already slotted for your next raid.');
'@ @'
say('core already slotted: next raid'); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('No Data Core in your stash. Find them in rare containers or on elite pillagers.');
'@ @'
say('no data core: rare containers / elite pillagers'); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('Core slotted. Your next raid starts with intel.'+(_cp?' Used '+_cp+' packed Data Core out of your backpack.':''));
'@ @'
say('core slotted: next raid intel'+(_cp?' / '+_cp+' packed data core used':'')); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('SELECT A HEAL','info',{sub:'Bandage, Medkit or Armour Plate.',key:'selheal'});
'@ @'
say('SELECT A HEAL','info',{sub:'bandage, medkit or armour plate',key:'selheal'}); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
say('There is no profile to go back to.');
'@ @'
say('no previous profile'); /* v28.xx (cw-cx-sentence-callouts): his 10-28 audit order, short callouts without periods. */
'@

SubRx @'
var VER='36.09';
'@ @'
var VER='36.10';
'@

$pat = "(?m)^  now:'v36\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.10: Short callouts keep the revive limit, core sources, next raid intel, packed core count and rack costs. Check 36.10 fails on v36.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
