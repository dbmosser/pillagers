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

# NEVER-WORDS OUT OF RAID TEXT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var UNITNAME={sentry:'sentry',crawler:'crawler',raider:'pillager',snitch:'crier',listener:'listener'};
'@ @'
var UNITNAME={sentry:'sentry',crawler:'crawler',raider:'pillager',snitch:'crier',listener:'listener'};
// v22.xx, the raid text rewrite (R49): NEVER-WORDS OUT OF RAID TEXT. The internal kinds (snitch, choir, stray, botwreck) leaked
// onto the screen: a ping on a Crier read SNITCH, a dead Crier was labelled SNITCH DOWN, a machine wreck was SEARCH BOTWRECK and
// the Peddler cache was PEDLAR STOCK. KINDWORD is the one table from a kind to the word the player knows (his vocabulary); the
// kinds stay in the code. A machine is DESTROYED and a person ELIMINATED, never DOWN, which is the word for a knocked-down body.
var KINDWORD={sentry:'SENTRY',crawler:'CRAWLER',raider:'PILLAGER',snitch:'CRIER',listener:'LISTENER',choir:'PILLBOX',warden:'WARDEN',
  bulwark:'BULWARK',howler:'HOWLER',stray:'SURVIVOR',peddler:'THE PEDDLER'};
function kindWord(k){ return KINDWORD[k]||String(k||'').toUpperCase(); }
function killWord(e){ return (e&&(e.kind==='raider'||e.kind==='stray'||e.kind==='peddler'))?' ELIMINATED':' DESTROYED'; }
'@

SubRx @'
        label(e.x,e.y-16,(e.name||e.kind.toUpperCase())+(e.kind==='raider'?' ELIMINATED':' DOWN'),e.kind==='raider'?'#ff5a4a':'#ffc04a',0,true);
'@ @'
        label(e.x,e.y-16,(e.name||kindWord(e.kind))+killWord(e),e.kind==='raider'?'#ff5a4a':'#ffc04a',0,true);   // v22.xx (R49): a machine is DESTROYED, never DOWN
'@

SubRx @'
    if(p&&canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)) label(e.x,e.y-16,(e.name||String(e.kind).toUpperCase())+(e.kind==='raider'?' ELIMINATED':' DOWN'),e.kind==='raider'?'#ff5a4a':'#ffc04a',0,true);
'@ @'
    if(p&&canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)) label(e.x,e.y-16,(e.name||kindWord(e.kind))+killWord(e),e.kind==='raider'?'#ff5a4a':'#ffc04a',0,true);   // v22.xx (R49)
'@

SubRx @'
function netPingName(hit){ return ((hit.kind==='raider'||hit.boss||hit.name===BOSS_NAME)&&hit.name)?netClean(hit.name,24):String(hit.kind).toUpperCase(); }function netPingMake(){
'@ @'
function netPingName(hit){ return ((hit.kind==='raider'||hit.boss||hit.name===BOSS_NAME)&&hit.name)?netClean(hit.name,24):kindWord(hit.kind); }   /* v22.xx (R49): CRIER, PILLBOX, SURVIVOR, THE PEDDLER, never the internal kind */ function netPingMake(){
'@

SubRx @'
    lbl=nm+(p.w?(': '+p.w):(p.dg?': DANGER':''))+'  '+((G&&G.player)?metres(dist(G.player,p)):0)+'m';   // v22.xx (R43): 120m
'@ @'
    lbl=nm+(p.w?('  \u00b7  '+p.w):(p.dg?'  \u00b7  DANGER':''))+'  \u00b7  '+((G&&G.player)?metres(dist(G.player,p)):0)+'m';   // v22.xx (R43): 120m   // v22.xx (R49): no colon labels; NAME, what, distance
'@

SubRx @'
        cpd.cache=1; cpd.time=1.4; cpd.tag='PEDLAR STOCK'; G.containers.push(cpd);
'@ @'
        cpd.cache=1; cpd.time=1.4; cpd.tag='PEDDLER STOCK'; G.containers.push(cpd);   // v22.xx (R49): his vocabulary spells it Peddler
'@

SubRx @'
      else _ft=_skey+(nc2.mercSrc?(String(nc2.mercSrc.name).toUpperCase()+"'S BACKPACK"):((nc2.type==='safe'&&nc2.camp)?'STRONGBOX':nc2.type.toUpperCase()));
'@ @'
      else _ft=_skey+(nc2.mercSrc?(String(nc2.mercSrc.name).toUpperCase()+"'S BACKPACK"):((nc2.type==='safe'&&nc2.camp)?'STRONGBOX':(nc2.type==='botwreck')?'WRECK':nc2.type.toUpperCase()));   // v22.xx (R49): SEARCH WRECK, the internal kind stays in the code
'@

SubRx @'
+dead+' down',PADX,yy+LH(1));
'@ @'
+dead+' dead',PADX,yy+LH(1));   // v22.xx (R49): the dead are dead; down is a knocked-down body
'@

SubRx @'
  ['','BULWARK and CHOIR have an'],
'@ @'
  ['','BULWARK and PILLBOX have an'],   // v22.xx (R49): the Pillbox by its name
'@

SubRx @'
var VER='23.01';
'@ @'
var VER='23.02';
'@

$pat = "(?m)^  now:'v23\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.02: Pings, kill labels, the wreck prompt, the Peddler cache and the pillager board use the names you know: CRIER, PILLBOX, WRECK, DESTROYED and dead. Check 23.02 fails on v23.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
