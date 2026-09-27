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

# PLAYER 2 CURRENT PILLAGERS BOARD (his note: player 2 board was broken).

SubRx @'
function netWorldSend(){
'@ @'
// v16.34, HIS NOTE: player 2 CURRENT PILLAGERS board was broken. It listed the pillagers of its own seed, whose bodies it never
// runs (the host bodies replace them), so every row read DEAD and dropped off. THE HOST: its board rows, sent with the world word.
function netBoardRows(){
  var R=G.roster||[], out=[], i, r, e, inE, v, b;
  for(i=0;i<R.length&&out.length<40;i++){
    r=R[i]; e=r.ref;
    if(r.merc||(e&&e.merc)) continue;
    inE=!!(e&&G.ents.indexOf(e)>=0);
    if(inE){ v=0; for(b=0;b<(e.bag||[]).length;b++) v+=ival(e.bag[b]); r.val=v; }
    out.push([netClean(r.name,24),Math.round(r.val||0),r.out?'EXTRACTED':(inE?raiderStatus(e):'DEAD'),r.crew|0,r.out?1:0,(e&&e.rival)?1:0,(e&&e.elite)?1:0,(e&&e.ghost)?1:0]);
  }
  return out;
}
// A LINKED WINDOW: the host board, with the time each name went out or down kept here so the board ages them off as it does.
function netBoardTake(bd){
  var i, a, nm, st, o, row, old={}, rows=[];
  for(i=0;i<(G.netBoard||[]).length;i++) old[G.netBoard[i].name]=G.netBoard[i];
  for(i=0;i<bd.length&&i<40;i++){
    a=bd[i]; if(!a||typeof a.length!=='number'||a.length<5) continue;
    nm=(a[5]?'\u2605 ':'')+netClean(a[0],24); if(!nm) continue;
    st=netClean(a[2],24)||'GONE'; o=old[nm];
    row={name:nm,val:Math.max(0,+a[1]||0),st:st,crew:a[3]|0,out:!!a[4],el:!!a[6],gh:!!a[7]};
    if(row.out) row.outAt=(o&&o.outAt!==undefined)?o.outAt:elapsed();
    if(st==='DEAD') row.deadAt=(o&&o.deadAt!==undefined)?o.deadAt:elapsed();
    rows.push(row);
  }
  G.netBoard=rows;
  return rows.length;
}
function netWorldSend(){
'@

SubRx @'
  m={t:'wd',sd:G.seed>>>0,tl:netNum(G.timeLeft),wx:(G.wx&&G.wx.id)||'',wn:(G.wxNext&&G.wxNext.id)||'',wt:netNum(G.wxT)||0,ai:(G.zones||[]).indexOf(G.active),z:z,s:s};
'@ @'
  m={t:'wd',sd:G.seed>>>0,tl:netNum(G.timeLeft),wx:(G.wx&&G.wx.id)||'',wn:(G.wxNext&&G.wxNext.id)||'',wt:netNum(G.wxT)||0,ai:(G.zones||[]).indexOf(G.active),z:z,s:s};
  m.bd=netBoardRows();   // v16.34: the board, for the party
'@

SubRx @'
  G.wxNext=netWxOf(m.wn); G.wxT=(typeof m.wt==='number'&&isFinite(m.wt))?clamp(m.wt,0,1):0;
'@ @'
  G.wxNext=netWxOf(m.wn); G.wxT=(typeof m.wt==='number'&&isFinite(m.wt))?clamp(m.wt,0,1):0;
  if(m.bd&&typeof m.bd.length==='number') netBoardTake(m.bd);   // v16.34: the host board
'@

SubRx @'
  var R=G.roster;
'@ @'
  var R=G.roster, _nb=(NET.on&&netEntsPeer()&&G.netBoard)?G.netBoard:null;   // v16.34: a linked window draws the host board
  if(_nb) R=[];
'@

SubRx @'
  if(!R||!R.length) return;
'@ @'
  if(!_nb&&(!R||!R.length)) return;
'@

SubRx @'
  var _eNow=elapsed(),_stay=[],_gone=[],_LEAVE=10;
'@ @'
  if(_nb) for(i=0;i<_nb.length;i++){ if(_nb[i].out) out++; else if(_nb[i].st==='DEAD') dead++; else live++; rows.push(_nb[i]); }
  var _eNow=elapsed(),_stay=[],_gone=[],_LEAVE=10;
'@

SubRx @'
var VER='16.33';
'@ @'
var VER='16.34';
'@

$pat = "(?m)^  now:'v16\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.34: PLAYER 2 CURRENT PILLAGERS BOARD. His note: player 2 board was broken. It listed the pillagers of its own seed, whose bodies the host bodies replace, so every row read DEAD and then dropped off. The host now sends its board (names, values, status, extracted) with the twice a second world word and player 2 draws that. Check 16.34 fails on v16.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
