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

# ARCADE: RUN END ALWAYS REACHES PLAYER 2 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
}function netUpEnd(how){
  if(!NET.on) return false;
'@ @'
}function netUpEnd(how,ae){   // v23.50 (arcade26): ae marks the out word of an arcade run end on the host; nothing else passes it
  if(!NET.on) return false;
'@

SubRx @'
  netBroadcast({t:'up',st:'out',how:netClean(how,12),sd:_sd});   // v18.53: names its raid (sd), so a late word never marks the next one
'@ @'
  var _ow={t:'up',st:'out',how:netClean(how,12),sd:_sd}; if(ae) _ow.ae=1;   // v23.50 (arcade26): the arcade run end mark; a normal raid sends the word as before
  netBroadcast(_ow);   // v18.53: names its raid (sd), so a late word never marks the next one
'@

SubRx @'
  if(NET.role==='join'&&st==='out'&&s===0) netHostGone('out');   // v15.91: the host raid ended with nobody left to run it: abandon for the whole party
'@ @'
  // v23.50 (arcade26): an out word the host marks as its arcade run end (ae) stops the player 2 arcade raid back to its attract, as
  // arcend does, and is acknowledged (arcendok). Taken as a host gone before, player 2 picked the raid up and played on alone.
  if(NET.role==='join'&&st==='out'&&s===0&&m.ae&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&NET.same==='p2'&&typeof G!=='undefined'&&G&&G.arcade&&!G.netWasJoin){ arcadeEndTake(); netSamePost({t:'arcendok',pair:NET.pair,run:''}); }
  else if(NET.role==='join'&&st==='out'&&s===0) netHostGone('out');   // v15.91: the host raid ended with nobody left to run it: abandon for the whole party
'@

SubRx @'
    try{ if(typeof NET==='object'&&NET&&NET.on) netUpEnd('abandon'); }catch(_ne){}
    try{ recStop(); }catch(_rs){}
'@ @'
    try{ if(typeof NET==='object'&&NET&&NET.on) netUpEnd('abandon',(why==='end'&&ARCADE.role==='host')?1:0); }catch(_ne){}   // v23.50 (arcade26): the host run end is marked ae
    try{ recStop(); }catch(_rs){}
'@

SubRx @'
    if(m.t==='arcend'){   // v23.39 (arcade16): the host ended the run: tear down silently, back to the attract
      if(!ARCADE.on) return 'ignored';
      if(G&&G.arcade&&!G.netWasJoin) arcadeRaidStop('end');
      ARCADE.wantIn=0; ARCADE.late=0; ARCADE.idleSaid=0;
      try{ arcadeAttShow(); }catch(_ae){}
      return 'arcend';
    }
'@ @'
    if(m.t==='arcend'){   // v23.39 (arcade16): the host ended the run: tear down silently, back to the attract
      if(!ARCADE.on) return 'ignored';
      var _er=String(m.run||'').slice(0,40);   // v23.50 (arcade26): acknowledged every time (arcendok), so the host stops repeating it
      netSamePost({t:'arcendok',pair:NET.pair,run:_er});
      if(_er&&ARCADE.endRun===_er) return 'ignored';   // v23.50 (arcade26): a repeat of a run end already taken changes nothing
      ARCADE.endRun=_er;
      return arcadeEndTake();
    }
'@

SubRx @'
    if(m.t==='arcin'){ ARCADE.p2Busy=0; return 'arcin'; }   // v23.26 (arcfixa): player 2 is in the arcade
'@ @'
    if(m.t==='arcin'){ ARCADE.p2Busy=0; return 'arcin'; }   // v23.26 (arcfixa): player 2 is in the arcade
    if(m.t==='arcendok'){ if(ARCADE.endSend&&(!m.run||String(m.run)===ARCADE.endSend.id)) ARCADE.endSend=null; return 'arcendok'; }   // v23.50 (arcade26): player 2 took the run end, no more repeats
'@

SubRx @'
  if(host) netSamePost({t:'arcend',pair:NET.pair});
  arcadeRaidStop('end');
'@ @'
  if(host) arcadeEndSend();   // v23.50 (arcade26): arcend with the run id, repeated until arcendok or 3 s
  arcadeRaidStop('end');
'@

SubRx @'
// Player 2 goes out of the arcade raid, back to its attract.
function arcadeP2Out(why){
'@ @'
// v23.50, HIS YES (2026-10-11) to the five recommendations, arcade26 (a low finding of the arcade 14-25 review): RUN END ALWAYS REACHES
// PLAYER 2. The host run end told player 2 twice: arcend on the pair channel and the out word on the co-op link (netUpEnd, from
// arcadeRaidStop). When the out word came first, player 2 took it as a host gone (netHostGone), picked the raid up as its own
// (netWasJoin), and the arcend after it then left that raid alone, so player 2 played on alone. Now the host marks its run end out
// word (ae) and player 2 stops its arcade raid on whichever word comes first, back to its attract (arcadeEndTake); an out word with
// no mark (the host window went away) still hands player 2 the raid, his 2026-10-02 ruling. The host names the run in arcend and
// repeats it every half second until player 2 acknowledges it (arcendok) or 3 s pass, or a new arcade raid is up. Only the arcade
// reaches any of it.
var ARCADE_END={ms:3000,every:500};
function arcadeEndSend(){
  var id=String((ARCADE.run&&ARCADE.run.id)||''), now=Date.now();
  ARCADE.endSend={id:id,at:now,last:now};
  netSamePost({t:'arcend',pair:NET.pair,run:id});
  return true;
}
// Run from the attract tick. Returns what it did: '', again or done.
function arcadeEndTick(now){
  var e=ARCADE.endSend;
  if(!e) return '';
  now=+now||Date.now();
  if(!ARCADE.on||ARCADE.role!=='host'||now-e.at>=ARCADE_END.ms||(G&&G.arcade)){ ARCADE.endSend=null; return 'done'; }
  if(now-e.last<ARCADE_END.every) return '';
  e.last=now;
  netSamePost({t:'arcend',pair:NET.pair,run:e.id});
  return 'again';
}
// Player 2 takes the host run end, from arcend or the marked out word, whichever comes first.
function arcadeEndTake(){
  if(!ARCADE.on) return 'ignored';
  if(G&&G.arcade&&!G.netWasJoin) arcadeRaidStop('end');
  ARCADE.wantIn=0; ARCADE.late=0; ARCADE.idleSaid=0;
  try{ arcadeAttShow(); }catch(_ae){}
  return 'arcend';
}
// Player 2 goes out of the arcade raid, back to its attract.
function arcadeP2Out(why){
'@

SubRx @'
  try{ arcadeScFlush(Date.now()); }catch(_sf){}   // v23.29 (arcade8): a held score word, and the 2 s repeat
'@ @'
  try{ arcadeScFlush(Date.now()); }catch(_sf){}   // v23.29 (arcade8): a held score word, and the 2 s repeat
  try{ arcadeEndTick(Date.now()); }catch(_et){}   // v23.50 (arcade26): the arcend repeat until arcendok or 3 s
'@

SubRx @'
var VER='23.49';
'@ @'
var VER='23.50';
'@

$pat = "(?m)^  now:'v23\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.50: In the arcade, ending the run on player 1 always sends player 2 back to its attract. Check 23.50 fails on v23.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
