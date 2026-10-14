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

# PILLAGERS AND MACHINES FIGHT ON CONTACT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feudFoe(a,b){
'@ @'
// v26.xx (ai23), HIS WORDS (2026-10-14, suggestion 23): pillagers and machines "should fight each other even w/o decoys". What fought
// before: a pillager LOOTING shot a machine in sight (v3.9x, within 280 and 600 of you), and a Sentry or Crawler that could not see you
// went for a pillager in sight (v3.97). A pillager RUNNING for the ring, which is where most of them are most of the time, ignored every
// machine he met, and a Warden or a Bulwark had no eyes for anyone but you. Now (1) a pillager in the extract state deals with a machine
// in sight within 280 the way he deals with a rival crew (feudEngage takes machFoe as a foe too: same range, same gate of 600 from the
// party), and (2) a plain Warden or a Bulwark that cannot see you hunts a pillager in sight (machHuntRaider). THE OVERSEER is left
// alone (it walks home), and so are the Snitch, the Peddler and the Survivor. No decoy, no noise needed: contact is enough.
function machFoe(o){
  return !!o&&o.kind!=='raider'&&o.kind!=='snitch'&&o.kind!=='peddler'&&o.kind!=='stray'&&!o.neutral&&!o.boss&&!o.downed&&!o.finished&&o.hp>0;
}
function feudFoe(a,b){
'@

SubRx @'
    if(!feudFoe(e,o)||o.hp<=0) continue;
'@ @'
    if((!feudFoe(e,o)&&!machFoe(o))||o.hp<=0) continue;   // v26.xx (ai23): a machine in sight is a foe too
'@

SubRx @'
  if(e.kind!=='sentry'&&e.kind!=='crawler') return false;
'@ @'
  if(e.kind!=='sentry'&&e.kind!=='crawler'&&e.kind!=='bulwark'&&!(e.kind==='warden'&&!e.boss)) return false;   // v26.xx (ai23): and a plain Warden or a Bulwark
'@

SubRx @'
var VER='26.67';
'@ @'
var VER='26.68';
'@

$pat = "(?m)^  now:'v26\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.68: Pillagers heading for the ring now fight machines they meet, and Wardens and Bulwarks fight pillagers they see. Check 26.68 fails on v26.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
