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

# A DEMO RUN SAVES ITS RUN REPORT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v10.65: the one commit, so the copy button and the way out cannot disagree

'@ @'
// v32.xx (cw-demoreport), HIS ANSWER 66 (save each party run's report) and 2.92 (the game logs everything automatically): a finished demo run (the 2 player
// arcade) posts its run report to the local collector, tagged demo and the window's seat (p1 host, p2 guest), so stutter on the two TVs becomes numbers (the
// gfx p50, p95 and slow line). One exporter: buildExport and telemetryDest. A demo run never falls back to a Downloads file and never shows a banner: if the
// collector does not answer the report is dropped quietly, and off localhost (itch) nothing is sent at all. The post waits 333 ms so the RUN OVER card is up
// first, times out after 4 s, and writes nothing to the profile (the arcade plays on a sandbox copy, saveProfile is off while ARCADE.on).
var DEMOREP={last:null};
function demoReportEnd(why){
  if(typeof ARCADE!=='object'||!ARCADE||!ARCADE.on) return false;
  var m=null, T=null;
  try{
    if(!LOCAL_DROP||telemetryDest()!==LOCAL_DROP||P.autoExport===false) return false;
    if(G&&G.tel&&G.tel.gfx) T=G.tel.gfx;
    m={seat:(ARCADE.role==='p2')?'p2':'p1',why:String(why||''),mine:ARCADE.mine|0,mate:ARCADE.mate|0,kills:ARCADE.kills|0,at:Date.now(),
       gfx:T?{n:T.n,p50:T.p50,p95:T.p95,slow:T.slow,q:T.q}:null};
    DEMOREP.last=m;
    setTimeout(function(){ demoReportPost(m); },333);
    return true;
  }catch(_dr){ return false; }
}
function demoReportPost(m){
  if(!m||!LOCAL_DROP||telemetryDest()!==LOCAL_DROP) return false;
  try{
    var body=buildExport()+'\n=== DEMO RUN ===\ndemo: yes\nseat: '+m.seat+'\nwhy: '+m.why+'\nscore: '+m.mine+' mate '+m.mate+' kills '+m.kills+
      '\ngfx: '+(m.gfx?('n '+m.gfx.n+' p50 '+m.gfx.p50+' p95 '+m.gfx.p95+' slow '+m.gfx.slow+' q '+m.gfx.q):'none')+'\n';
    var ac=(typeof AbortController==='function')?new AbortController():null;
    if(ac) setTimeout(function(){ try{ ac.abort(); }catch(_ab){} },4000);
    fetch(LOCAL_DROP,{method:'POST',headers:{'Content-Type':'text/plain'},body:body,keepalive:true,mode:'cors',signal:ac?ac.signal:undefined})
      .then(function(){},function(){});
    return true;
  }catch(_dp){ return false; }
}
// v10.65: the one commit, so the copy button and the way out cannot disagree

'@

SubRx @'
  if(host) arcadeEndSend();   // v23.50 (arcade26): arcend with the run id, repeated until arcendok or 3 s
  arcadeRaidStop('end');

'@ @'
  if(host) arcadeEndSend();   // v23.50 (arcade26): arcend with the run id, repeated until arcendok or 3 s
  demoReportEnd(why);   // v32.xx (cw-demoreport): the run report goes to the local collector after the card is up
  arcadeRaidStop('end');

'@

SubRx @'
  if(G&&G.arcade&&!G.netWasJoin){ ARCADE.p2StopAt=Date.now(); arcadeRaidStop('end'); }
'@ @'
  if(G&&G.arcade&&!G.netWasJoin){ demoReportEnd('end'); ARCADE.p2StopAt=Date.now(); arcadeRaidStop('end'); }   // v32.xx (cw-demoreport): player 2 posts its own report
'@

SubRx @'
  netSamePost({t:'arcleft',pair:NET.pair});
  arcadeRaidStop('idle');

'@ @'
  netSamePost({t:'arcleft',pair:NET.pair});
  demoReportEnd(why||'idle');   // v32.xx (cw-demoreport): player 2 leaving posts its own report too
  arcadeRaidStop('idle');

'@

SubRx @'
var VER='32.92';
'@ @'
var VER='32.93';
'@

$pat = "(?m)^  now:'v32\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.93: Every finished demo run posts its report (with the gfx p50 p95 slow line) to the local collector from both windows. Check 32.93 fails on v32.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
