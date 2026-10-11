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

# ONE WAY TO WRITE NUMBERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function fmtMS(sec){
  sec=Math.max(0,Math.round(sec));
  var m=Math.floor(sec/60), r=sec%60;
  return m?(m+' min'+(r?(' '+r+' sec'):'')):(r+' sec');
}
'@ @'
function fmtMS(sec){
  sec=Math.max(0,Math.round(sec));
  var m=Math.floor(sec/60), r=sec%60;
  return m?(m+' min'+(r?(' '+r+' sec'):'')):(r+' sec');
}
// v22.xx, the raid text rewrite (R48): ONE WAY TO WRITE A DURATION IN A RAID. Raid lines wrote time three ways: 12s on the band,
// 1:30 on the call, and 7 min 30 sec from fmtMS on the map, the conditions rows, the downed overlay and the clock line. A raid
// line now reads 12s below a minute and m:ss from a minute up, like every shooter HUD. fmtMS stays for the Undercroft panels
// and the run card, which are prose.
function fmtDur(sec){
  sec=Math.max(0,Math.round(+sec||0));
  return (sec<60)?(sec+'s'):(Math.floor(sec/60)+':'+('0'+(sec%60)).slice(-2));
}
'@

SubRx @'
      itm.name+(itm.use==='ammo'?' +'+itm.amt+' ammo':' '+ival(key)+'c'),
'@ @'
      itm.name+(itm.use==='ammo'?' +'+itm.amt+' ammo':'  '+'$'+ival(key).toLocaleString()),   // v22.xx (R48): Credits read $1,234 everywhere, never 1234c
'@

SubRx @'
              sub:_sd?('Extraction closes in '+fmtMS(Math.max(0,Math.ceil(_dz.hold)))):'Extraction inbound',
'@ @'
              sub:_sd?('Extraction closes in '+fmtDur(Math.max(0,Math.ceil(_dz.hold)))):'Extraction inbound',   // v22.xx (R48): 12s, or m:ss from a minute
'@

SubRx @'
      else _zSub='closes in '+fmtMS(Math.max(0,Math.ceil(G.timeLeft-Z.closeAt)));
'@ @'
      else _zSub='closes in '+fmtDur(Math.max(0,Math.ceil(G.timeLeft-Z.closeAt)));   // v22.xx (R48): m:ss, never 2 min 57 sec
'@

SubRx @'
      if(Z.open&&(_zAct||_zHold)&&(Z.closeAt===undefined||G.timeLeft>Z.closeAt)) ctx.fillText(   /* v21.27 (R9): a ring called before its cutoff runs past it; no 0:00 then */(Z.closeAt===undefined)?'STAYS OPEN':('closes in '+fmtMS(Math.max(0,Math.ceil(G.timeLeft-Z.closeAt)))),ox+Z.x*sc,oy+Z.y*sc+Math.max(4,Z.r*sc)+LH(16)*_MZ);
'@ @'
      if(Z.open&&(_zAct||_zHold)&&(Z.closeAt===undefined||G.timeLeft>Z.closeAt)) ctx.fillText(   /* v21.27 (R9): a ring called before its cutoff runs past it; no 0:00 then */(Z.closeAt===undefined)?'STAYS OPEN':('closes in '+fmtDur(Math.max(0,Math.ceil(G.timeLeft-Z.closeAt)))),ox+Z.x*sc,oy+Z.y*sc+Math.max(4,Z.r*sc)+LH(16)*_MZ);
'@

SubRx @'
      rows.push({k:_bzTags[_bq][1]+(_bn>1?(' \u00d7'+_bn):''),v:fmtMS(_bt)+' left',c:'#d98aff'});
'@ @'
      rows.push({k:_bzTags[_bq][1]+(_bn>1?(' \u00d7'+_bn):''),v:fmtDur(_bt)+' left',c:'#d98aff'});   // v22.xx (R48): m:ss
'@

SubRx @'
  say('Raid clock changed: '+fmtMS(G.timeLeft)+' left.');
'@ @'
  say('RAID CLOCK SET TO '+fmtDur(G.timeLeft),'sys');   // v22.xx (R48): a system row in caps, the clock as m:ss
'@

SubRx @'
var VER='22.99';
'@ @'
var VER='23.00';
'@

$pat = "(?m)^  now:'v22\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.00: Loot labels show their value as $1,234, and raid times read 12s or 7:30, never 7 min 30 sec. Check 23.00 fails on v22.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
