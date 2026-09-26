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

# YOUR RIVAL IS ALWAYS A PILLAGER, NEVER THE IMPORTED FRIEND. myRival walked every key of P.rivals, and the imported friend's own
# record (ghost_<tag>, keyed there on purpose by v13.93 so the kill lands on him) could win it; no pillager identity carries that
# key, so once the friend had been killed twice no body on any map wore the rival mark. One line in the chooser.
SubRx @'
  for(var id in (P.rivals||{})){
    var r=P.rivals[id],f=(r.kills||0);   // v13.94: kills alone. deaths is only ever a hire dying on your job.
'@ @'
  for(var id in (P.rivals||{})){
    // v15.97, ghost audit finding: YOUR RIVAL IS ALWAYS A PILLAGER, NEVER THE IMPORTED FRIEND. applyGhost keys the imported
    // friend's body as ghost_<tag> (v13.93) so the kill written at the death path lands on him and not on the pillager whose
    // body he took. That record then sat in this loop beside the pillagers, and two kills on the friend put it ahead of every
    // real identity (strict f>bs from 1). mkRaider, the only reader, matches the winner against IDENTITIES, which holds no
    // ghost_ id, and applyGhost only re-dresses a body after the roll, so no body could ever match: the star on the pillager
    // board vanished, the YOUR RIVAL warning never played and G.tel.rivalMet never set, until he out-killed his own friend.
    // The friend's record is skipped here, in the chooser, so the ledger write v13.93 wanted stays where it lands. No number
    // and no seeded draw moved.
    if(id.indexOf('ghost_')===0) continue;
    var r=P.rivals[id],f=(r.kills||0);   // v13.94: kills alone. deaths is only ever a hire dying on your job.
'@
SubRx @'
var VER='15.96';
'@ @'
var VER='15.97';
'@

$pat = "(?m)^  now:'v15\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.97: YOUR RIVAL IS ALWAYS A PILLAGER, NEVER THE IMPORTED FRIEND. Killing the friend imported from a run report twice put their record ahead of every pillager on the ledger, and from then on no pillager wore the rival star, the rival warning never played and the run report lost its rival line. The rival is now chosen among the pillagers alone and the friend keeps their own record. Check 15.97 puts the friend record at three kills beside a pillager at two and asks who the rival is and whether a body built for that pillager gets the mark; it fails on v15.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
