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

# KID MODE (his order: player 2 takes 1/2, 1/4, 1/5 or 1/10 of the damage).

SubRx @'
function damagePlayer(amt,src,srcName,sx,sy){
'@ @'
function damagePlayer(amt,src,srcName,sx,sy){
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&isFinite(amt)) amt*=netKidMul();   // v16.44, his order: kid mode, player 2 takes less
'@

SubRx @'
  host.innerHTML=_go+
'@ @'
  host.innerHTML=_go+kidRowHtml()+
'@

SubRx @'
  document.getElementById('set_tune').onclick=function(){ toggleTune(true); };
'@ @'
  document.getElementById('set_tune').onclick=function(){ toggleTune(true); };
  (function(){ var _kb=document.getElementById('set_kid'); if(_kb) _kb.onclick=function(){ kidCycle(); renderSettings(); }; })();   // v16.44
'@

SubRx @'
  m.bd=netBoardRows();   // v16.34: the board, for the party
'@ @'
  m.bd=netBoardRows();   // v16.34: the board, for the party
  m.kd=kidMulOwn();   // v16.44: kid mode as the host has it, live
'@

SubRx @'
  if(m.bd&&typeof m.bd.length==='number') netBoardTake(m.bd);   // v16.34: the host board
'@ @'
  if(m.bd&&typeof m.bd.length==='number') netBoardTake(m.bd);   // v16.34: the host board
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,0.1,1);   // v16.44: kid mode as the host has it
'@

SubRx @'
var NET_FEED_T=6;
'@ @'
var NET_FEED_T=6;
// v16.44, HIS ORDER: KID MODE. Player 2 (every window that joined a party) takes a fraction of the damage: all of it, 1/2, 1/4,
// 1/5 or 1/10. A row in Settings on either window sets it; the host sends its choice with the world word twice a second, so a
// change on the host lands on player 2 mid raid, and player 2 takes the lower of the two. Player 1 is never touched.
var KID_OPTS=[[1,'OFF'],[0.5,'1/2'],[0.25,'1/4'],[0.2,'1/5'],[0.1,'1/10']];
function kidMulOwn(){ var v=(typeof P!=='undefined'&&P)?+P.kidDmg:1; return (isFinite(v)&&v>=0.1&&v<=1)?v:1; }
function netKidMul(){ var h=(typeof NET.kidHost==='number'&&NET.kidHost>=0.1&&NET.kidHost<=1)?NET.kidHost:1; return Math.min(kidMulOwn(),h); }
function kidCycle(){
  var i, v=kidMulOwn(), ix=0;
  for(i=0;i<KID_OPTS.length;i++) if(Math.abs(KID_OPTS[i][0]-v)<1e-6) ix=i;
  P.kidDmg=KID_OPTS[(ix+1)%KID_OPTS.length][0];
  saveProfile();
  return P.kidDmg;
}
function kidRowHtml(){
  var i, v=kidMulOwn(), lbl='OFF';
  for(i=0;i<KID_OPTS.length;i++) if(Math.abs(KID_OPTS[i][0]-v)<1e-6) lbl=KID_OPTS[i][1];
  return '<div class="row"><div style="flex:1"><b>Kid mode</b><div class="hint">Player 2 takes less damage: 1/2, 1/4, 1/5 or 1/10 of every hit. Player 1 is not changed. Either window can set it, and it changes the raid at once.</div></div>'+
    '<button id="set_kid" style="padding:6px 12px;min-width:92px'+(v<1?';color:var(--amber)':'')+'">'+lbl+'</button></div>';
}
'@

SubRx @'
var VER='16.43';
'@ @'
var VER='16.44';
'@

$pat = "(?m)^  now:'v16\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.44: KID MODE. His order: player 2 incoming damage can be cut to 1/2, 1/4, 1/5 or 1/10 to make the game easier for player 2. A Kid mode row in Settings on either window; the host choice reaches player 2 live with the world word, and player 2 takes the lower of the two. Player 1 is never changed. Check 16.44 fails on v16.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
