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

# ARCADE: PLAYER 2 BACK FROM A RAID JOINS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){
    if(!m.arc) return 'arc:plain';
'@ @'
  // v23.26 (arcfixa), from the review of the arcade core: A WINDOW OUTSIDE THE ARCADE NEVER TAKES AN ARCADE RAID WORD. A linked player 2
  // still in a normal raid answers the arcade offer busy, and it was never offered again. When the host then dropped into an arcade
  // raid, its raid word reached that window back in the Undercroft, which built the raid as a normal one (no sandbox, no arcade
  // post-build) and was only turned away because the surfaces did not match, with a went up without you line. Now the word is
  // refused, and a player 2 window takes it as the arcade offer instead: it enters the arcade attract (or says busy again from the
  // middle of a raid) and joins with A as ever.
  if(m.arc&&!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)){
    if(NET.same==='p2'){ try{ arcadeOnMsg({t:'arcon',pair:NET.pair}); }catch(_ao){} }
    return 'arc:out';
  }
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){
    if(!m.arc) return 'arc:plain';
'@

SubRx @'
    if(m.t==='arcon'){
      if(G&&!G.arcade&&!G.over&&!G.sim){ netSamePost({t:'arcbusy',pair:NET.pair}); return 'busy'; }
      return arcadeEnter('p2')?'arcon':'fail';
    }
'@ @'
    if(m.t==='arcon'){
      // v23.26 (arcfixa): player 2 tells the host it is in (arcin), so the host stops offering; an offer that comes again while it is
      // in already changes nothing (a press of A stays pressed).
      if(ARCADE.on){ netSamePost({t:'arcin',pair:NET.pair}); return 'arcon'; }
      if(G&&!G.arcade&&!G.over&&!G.sim){ netSamePost({t:'arcbusy',pair:NET.pair}); return 'busy'; }
      if(!arcadeEnter('p2')) return 'fail';
      netSamePost({t:'arcin',pair:NET.pair});
      return 'arcon';
    }
'@

SubRx @'
    if(m.t==='arcbusy'){ try{ say('PLAYER 2 IS IN A RAID','warn'); }catch(_sb){} return 'busy'; }
    if(m.t==='arcjoin') return arcadeJoinAsk();   // v23.25 (arcade6): player 2 pressed A
'@ @'
    if(m.t==='arcbusy'){ if(!ARCADE.p2Busy){ try{ say('PLAYER 2 IS IN A RAID','warn'); }catch(_sb){} } ARCADE.p2Busy=1; ARCADE.offerAt=Date.now(); return 'busy'; }   // v23.26 (arcfixa): offered again from arcadeAttTick, said once
    if(m.t==='arcin'){ ARCADE.p2Busy=0; return 'arcin'; }   // v23.26 (arcfixa): player 2 is in the arcade
    if(m.t==='arcjoin'){ ARCADE.p2Busy=0; return arcadeJoinAsk(); }   // v23.25 (arcade6): player 2 pressed A
'@

SubRx @'
  ARCADE.wantIn=0;
  if(ARCADE.role==='host') netSamePost({t:'arcon',pair:NET.pair});
'@ @'
  ARCADE.wantIn=0; ARCADE.p2Busy=0;   // v23.26 (arcfixa)
  if(ARCADE.role==='host') netSamePost({t:'arcon',pair:NET.pair});
'@

SubRx @'
function arcadeAttTick(){
  if(!ARCADE.on) return;
'@ @'
function arcadeAttTick(){
  if(!ARCADE.on) return;
  // v23.26 (arcfixa): a player 2 that answered busy is offered the arcade again every 3 s, so it comes in once its raid is over.
  if(ARCADE.role==='host'&&ARCADE.p2Busy&&Date.now()-(+ARCADE.offerAt||0)>=3000){ ARCADE.offerAt=Date.now(); netSamePost({t:'arcon',pair:NET.pair}); }
'@

SubRx @'
var VER='23.25';
'@ @'
var VER='23.26';
'@

$pat = "(?m)^  now:'v23\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.26: Player 2 coming back from a normal raid is asked into the arcade again and joins with A. Check 23.26 fails on v23.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
