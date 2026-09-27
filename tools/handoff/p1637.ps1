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

# EVERY PLAYER CHOOSES A KIT (his note: player 2 gets freebie kit or main kit, just like always).

SubRx @'
function askKit(){
'@ @'
function askKit(then,mate){   // v16.37: then, what an answer leads to; mate, a teammate asked for the party (no sector page to put back)
  then=then||function(){ netKitGate(ascendNow); };
'@

SubRx @'
  ASKYES=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; saveProfile(); ascendNow(); };   // v12.16: MY LOADOUT gets his packing back too
'@ @'
  ASKYES=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; saveProfile(); then(); };   // v12.16: MY LOADOUT gets his packing back too
'@

SubRx @'
    try{ renderStage(); }catch(_e){}
    ascendNow();
'@ @'
    try{ renderStage(); }catch(_e){}
    then();
'@

SubRx @'
  ASKBACK='sectormodal';
'@ @'
  ASKBACK=mate?null:'sectormodal';
'@

SubRx @'
  if(m.t==='contact') return netContactTake(peer,m);   // v16.36: an enemy went for this seat first, from the host
'@ @'
  if(m.t==='contact') return netContactTake(peer,m);   // v16.36: an enemy went for this seat first, from the host
  if(m.t==='kitask'||m.t==='kitok') return netKitTake(peer,m);   // v16.37: every player chooses a kit
'@

SubRx @'
function netKillTake(peer,m){
'@ @'
// v16.37, HIS NOTE: the player who is not starting the raid gets the freebie kit or main kit choice, just like always. THE HOST,
// answering MY LOADOUT or FREEBIE KIT with the party linked, asks each teammate the same question and ascends once every one has
// answered, or after NET_KIT_WAIT seconds with the kit each had chosen before. A TEAMMATE sees the same card on its own save;
// its answer sets its own kit and tells the host. A teammate already up top or on the title answers at once.
var NET_KIT_WAIT=15;
function netKitGate(f){
  var i, q, n=0;
  if(typeof NET!=='object'||!NET||!NET.on||NET.role!=='host') return f();
  if(NET.kitWait){ clearTimeout(NET.kitWait.tm); NET.kitWait=null; }
  for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q.state==='in'&&netSend(q,{t:'kitask'})) n++; }
  if(!n) return f();
  NET.kitWait={f:f,need:n,got:0,tm:setTimeout(netKitGo,NET_KIT_WAIT*1000)};
  NET.status='Waiting for your party to choose a kit.'; netRefresh();
  return 'wait';
}
function netKitGo(){
  var w=NET.kitWait;
  if(!w) return false;
  NET.kitWait=null; clearTimeout(w.tm); NET.status=''; netRefresh();
  w.f();
  return true;
}
function netKitTake(peer,m){
  if(!peer||peer.state!=='in') return 'ignored';
  if(m.t==='kitask'){
    if(NET.role!=='join') return 'ignored';
    if(netUpBusy()){ netSend(peer,{t:'kitok'}); return 'kit:busy'; }
    askKit(function(){ netSend(peer,{t:'kitok'}); },true);
    return 'kit:ask';
  }
  if(NET.role!=='host'||!NET.kitWait) return 'ignored';
  NET.kitWait.got++;
  if(NET.kitWait.got>=NET.kitWait.need) netKitGo();
  return 'kit:ok';
}
function netKillTake(peer,m){
'@

SubRx @'
var VER='16.36';
'@ @'
var VER='16.37';
'@

$pat = "(?m)^  now:'v16\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.37: EVERY PLAYER CHOOSES A KIT. His note: the player who is not starting the raid should get the freebie kit or main kit choice just like always. The host answering MY LOADOUT or FREEBIE KIT now asks each teammate the same question on its own window and save, and the party ascends once every teammate has answered (or after 15 seconds with the kit each had before). Check 16.37 fails on v16.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
