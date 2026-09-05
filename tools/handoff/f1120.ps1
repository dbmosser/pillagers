$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'11.19',what:'the seven building rules since v11.12 ship switched on, and switching all seven off builds a different world for the same seed, so the paired measurement has two real arms',
'@ @'
  {v:'11.20',what:'a body never stands still on a route: the waypoint it is steering at counts as reached at one step, the same step seekPoint calls arriving, so a coarse step cannot deadlock the two',
   run:function(){
     if(!(window.__simTraceSeed&&window.__deploy)) return 'SKIP: this fixture cannot replay a seeded sim raid';
     var bad=[];
     // THE FINDING. Seed 9071 on COLD STORAGE with the shipping rules: the bot
     // stood at 490,1157 inside building 6 from 45 to 120 seconds with a nine
     // point route in hand and its waypoint 24 units away, moving nothing,
     // because the follower wanted 10 units and seekPoint called 27 arrived.
     __runPrep(); __resetCfg(); __pinDefaults(0); __P().mapIx=0;
     var r=__simTraceSeed(9071), S=r.samples, i, run=0, worst=0, at=null;
     for(i=1;i<S.length;i++){ var q=S[i]; var still=(q[3]===0&&q[7]>0&&q[5]>0); if(still){ run++; if(run>worst){ worst=run; at=q[0]; } } else run=0; }
     // Samples are five seconds apart; three in a row standing still with a
     // route and health is fifteen seconds of nothing.
     if(worst>=3) bad.push('the bot stood still with a route in hand for '+(worst*5)+' seconds ending at '+at+' seconds into seed 9071');
     // CONTROL ONE: the raid really ran. It has to reach at least 60 seconds and
     // move at all, or the stall above is a raid that never started.
     var moved=0; for(i=1;i<S.length;i++) moved+=S[i][3];
     if(S.length<12||moved<500) bad.push('control: seed 9071 ran '+S.length+' samples and moved '+moved+' units, so nothing here was measured');
     // CONTROL TWO: the old follower, navBody 0, must not stand still either;
     // its fault was the jamb, not this. A stall there would mean the trace is
     // reading something else.
     __runPrep(); __resetCfg(); __pinDefaults(0); __P().mapIx=0; __cfg({navBody:0});
     var r0=__simTraceSeed(9071), S0=r0.samples, run0=0, worst0=0;
     for(i=1;i<S0.length;i++){ var q0=S0[i]; if(q0[3]===0&&q0[7]>0&&q0[5]>0){ run0++; if(run0>worst0) worst0=run0; } else run0=0; }
     if(worst0>=3) bad.push('control: with the old follower the bot also stood still for '+(worst0*5)+' seconds, so this trace is not reading the arrival rule');
     return bad.length?bad.join('; '):null; }},
  {v:'11.19',what:'the seven building rules since v11.12 ship switched on, and switching all seven off builds a different world for the same seed, so the paired measurement has two real arms',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
