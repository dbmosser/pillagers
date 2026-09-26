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

# THE SECTOR CARD COUNTS EVERY RUN HE HAS MADE THERE. commitRun keeps only the last sixty runs in P.log, and renderSector
# counted his runs on a map from that log alone, so past sixty committed raids the card showed too few and a map whose raids
# had all aged out read YOU HAVE NEVER RAIDED HERE. A lifetime tally per map, seeded once from the log, bumped on every
# commit, read by the card and carried in a restore code.
SubRx @'
  addProgress(rec);
  P.log.push(rec);
  if(P.log.length>60) P.log.shift();
'@ @'
  addProgress(rec);
  // v15.88, sector audit finding: THE SECTOR CARD COUNTS EVERY RUN HE HAS MADE THERE. The log below keeps only the last sixty
  // runs (the v12.97 note on netEarn says so), and renderSector counted his runs on a map from that log alone, so past sixty
  // committed raids the card showed too few (eighty raids on COLD STORAGE read you: 60 runs here), and a map whose raids had
  // all aged out of the log read YOU HAVE NEVER RAIDED HERE. P.runs and P.netEarn are lifetime counters for exactly that
  // reason; nothing kept a lifetime count per map. This tally does: seeded once from whatever the log still holds, so an old
  // save keeps the count it could show, and bumped before every push. Clear recorder empties the log and leaves the tally
  // alone. It is saved with the whole of P, and restoreMake and restoreApply carry it in a restore code. No number, no seeded
  // draw and no sentence moved.
  if(!P.mapRunN){ P.mapRunN={}; for(var _mq=0;_mq<P.log.length;_mq++){ var _mqn=P.log[_mq]&&P.log[_mq].mapName; if(_mqn) P.mapRunN[_mqn]=(P.mapRunN[_mqn]||0)+1; } }
  if(rec.mapName) P.mapRunN[rec.mapName]=(P.mapRunN[rec.mapName]||0)+1;
  P.log.push(rec);
  if(P.log.length>60) P.log.shift();
'@
SubRx @'
var _myR=0;
    for(var _mr=0;_mr<P.log.length;_mr++) if(P.log[_mr].mapName===M.name) _myR++;
'@ @'
var _myR=0;
    for(var _mr=0;_mr<P.log.length;_mr++) if(P.log[_mr].mapName===M.name) _myR++;
    // v15.88, sector audit finding: THE SECTOR CARD COUNTS EVERY RUN HE HAS MADE THERE. The loop above counts only the sixty
    // runs the log still holds, so a long career read too few here, or YOU HAVE NEVER RAIDED HERE on a map whose raids had
    // all aged out. The per-map tally commitRun keeps outlives the log, and the card shows the larger of the two; a save
    // with no tally yet reads the log as before.
    if(P.mapRunN&&(P.mapRunN[M.name]|0)>_myR) _myR=P.mapRunN[M.name]|0;
'@
SubRx @'
         cc:P.cdone||0,   // v15.01, save audit finding 2: the contracts he completed, beside the standing it already carries
         w:{},s:{}};
'@ @'
         cc:P.cdone||0,   // v15.01, save audit finding 2: the contracts he completed, beside the standing it already carries
         // v15.88, sector audit finding: THE SECTOR CARD COUNTS EVERY RUN HE HAS MADE THERE. His lifetime runs per map, which
         // the log, kept out of the code, could not restate past sixty runs anyway.
         mr:P.mapRunN||null,
         w:{},s:{}};
'@
SubRx @'
  P.cdone=o.cc|0;
  var k;
'@ @'
  P.cdone=o.cc|0;
  // v15.88, sector audit finding: THE SECTOR CARD COUNTS EVERY RUN HE HAS MADE THERE. The per-map run tally is the restored
  // character's, the same mistake v15.00 to v15.02 fixed for rivals and contracts: left alone, a restored character wore the
  // replaced character's counts on the sector page. An older code carries none, and the next commit reseeds from the log.
  P.mapRunN=(o.mr&&typeof o.mr==='object'&&!Array.isArray(o.mr))?o.mr:null;
  var k;
'@
SubRx @'
var VER='15.87';
'@ @'
var VER='15.88';
'@

$pat = "(?m)^  now:'v15\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.88: THE SECTOR CARD COUNTS EVERY RUN HE HAS MADE THERE. The sector page counted your runs on a map from the run log, which keeps only the last sixty runs, so past sixty raids the card showed too few, and a map whose raids had all aged out of the log said YOU HAVE NEVER RAIDED HERE. Each map now keeps its own lifetime tally, seeded once from the log, carried in a restore code, and the card shows the larger of the two. Check 15.88 fills the log with sixty runs, commits three more and restores a code; it fails on v15.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
