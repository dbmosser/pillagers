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

# THE GAME IS ON ITCH NOW, AND THIS IS THE FIRST THING THAT BREAKS THERE.
#
# With no collector deployed, a run report falls back to saving itself as a file.
# An itch HTML game runs inside an iframe, and that iframe does not carry
# allow-downloads, so clicking a download link there does nothing at all. It does
# not throw. So the catch never fires, lastReport is set to 'downloaded', and the
# player is told a report was saved that does not exist anywhere.
#
# THAT IS THE WHOLE FEEDBACK PATH FOR EVERY FRIEND PLAYING TODAY. The collector
# is not deployed yet, so the fallback IS the path, and on the only place the
# game is actually hosted the fallback is a no-op that reports success.
#
# WHAT CHANGES: the game stops claiming a save it cannot verify, and says what to
# do instead. Copy report already exists and works inside an iframe, because it
# is a clipboard write and not a download.
#
# reportEmbedded IS ITS OWN FUNCTION so a check can stub it. window.self and
# window.top cannot be assigned, so a test that cannot reach this decision cannot
# test it, and an untestable fix on the only hosted build is not good enough.
SubRx @'
function downloadExport(){
  try{
    var blob=new Blob([buildExport()],{type:'text/plain'});
    var url=URL.createObjectURL(blob);
    var a=document.createElement('a');
    a.href=url; a.download=reportFileName();   // v12.72: named for the game he is playing
    document.body.appendChild(a); a.click();
    setTimeout(function(){ document.body.removeChild(a); URL.revokeObjectURL(url); },800);
    P.lastReport='downloaded';
  }catch(e){ P.lastReport='failed'; }
}
'@ @'
// v13.20: ARE WE INSIDE SOMEBODY ELSE PAGE. An itch HTML game runs in an iframe
// whose sandbox carries no allow-downloads, so a download link there does
// nothing and throws nothing. Cross-origin access to window.top throws, and a
// throw is itself the answer, so both arms return true. Its own function so a
// check can stub it: window.self and window.top cannot be assigned, and a fix
// that cannot be tested on the only place the game is hosted is not good enough.
function reportEmbedded(){
  try{ return window.self!==window.top; }catch(_re){ return true; }
}
function downloadExport(){
  // EMBEDDED MEANS THE FILE NEVER LANDS. Saying "downloaded" here was not a
  // small lie: with no collector deployed the file IS the feedback path, so on
  // itch every report was being thrown away while the game reported success.
  // Copy report still works in an iframe, because a clipboard write is not a
  // download, so that is what the player is pointed at.
  if(reportEmbedded()){
    P.lastReport='embedded';
    try{ if(typeof say2==='function') say2('This page cannot save files. Use COPY REPORT and paste it to Daniel.'); }catch(_se){}
    return;
  }
  try{
    var blob=new Blob([buildExport()],{type:'text/plain'});
    var url=URL.createObjectURL(blob);
    var a=document.createElement('a');
    a.href=url; a.download=reportFileName();   // v12.72: named for the game he is playing
    document.body.appendChild(a); a.click();
    setTimeout(function(){ document.body.removeChild(a); URL.revokeObjectURL(url); },800);
    P.lastReport='downloaded';
  }catch(e){ P.lastReport='failed'; }
}
'@

SubRx @'
var VER='13.19';
'@ @'
var VER='13.20';
'@

$pat = "(?m)^  now:'v13\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.20: THE GAME IS ON ITCH NOW AND THIS IS THE FIRST THING THAT BREAKS THERE. With no collector deployed a run report falls back to saving itself as a file, an itch HTML game runs inside an iframe whose sandbox carries no allow-downloads, and a download link in such a frame does nothing at all and throws nothing, so the catch never fired, lastReport was set to downloaded, and the player was told a report had been saved that does not exist anywhere. That is the WHOLE feedback path for every friend playing today, because the collector is not deployed yet, so the fallback IS the path, and on the only place the game is actually hosted the fallback was a no-op that reported success. The game now stops claiming a save it cannot verify and says what to do instead, pointing at Copy report, which already exists and does work inside an iframe because a clipboard write is not a download. reportEmbedded is its own function so a check can stub it, since window.self and window.top cannot be assigned and a fix that cannot be tested on the only place the game is hosted is not good enough. SEPARATELY AND MORE URGENTLY, MEASURED BY LOADING HIS OWN PAGE AS A STRANGER: pillagers.itch.io/pillagersv1306 answers A PASSWORD IS REQUIRED TO VIEW THIS PAGE, so every build pushed today is behind a password and any friend sent that link has seen a password box rather than the game; either the project is still a Draft, which always asks whatever else is set, or Restricted is set to password rather than anyone with the secret URL. Told him, and it is his to change',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
