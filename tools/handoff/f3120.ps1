$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'31.20',what:")) { throw "check 31.20 is in the fixture already" }

SubRx @'
  {v:'31.19',what:
'@ @'
  {v:'31.20',what:'cw-ascendin, his lore (you ascend, you never drop in): the arcade respawn count drawn on the real HUD reads ascending in n, counts down in place, and never says dropping in',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof txRecord!=='function') return 'SKIP: no arcade or text recorder in this build';
     var bad=[], g, seen, holdWas=ARCADE.holdT;
     function frames(){ return txRecord(function(){ for(var f=0;f<2;f++) __loop(performance.now()+f*16.7); }).map(function(h){ return String(h.t); }); }
     function has(list,rx){ for(var j=0;j<list.length;j++) if(rx.test(list[j])) return true; return false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.banner=null; g.mapOpen=false; g.bagOpen=false;
       ARCADE.holdT=2.4; seen=frames();
       if(__state()!==g||g.over) return 'the arcade raid ended';
       if(!seen.length) return 'SKIP: the HUD drew no text';
       if(!has(seen,/^ascending in [23]$/)) bad.push('ONE: a drop-in hold of 2.4 s draws no ascending in n on the HUD (the count lines drawn: '+seen.filter(function(s){ return /in \d$/.test(s); }).slice(0,3).join(' | ')+')');
       if(has(seen,/dropping in|drop in/)) bad.push('ONE: the respawn count still says dropping in');
       g.alert=null; g.alertQ=[]; ARCADE.holdT=1.2; seen=frames();
       if(!has(seen,/^ascending in [12]$/)) bad.push('TWO: the count at 1.2 s left draws no ascending in n (lines: '+seen.filter(function(s){ return /in \d$/.test(s); }).slice(0,3).join(' | ')+')');
       if(has(seen,/dropping in|drop in/)) bad.push('TWO: the respawn count still says dropping in');
       g.alert=null; g.alertQ=[]; ARCADE.holdT=0; seen=frames();
       if(has(seen,/ascending in|dropping in/)) bad.push('THREE: the count is drawn with no hold running');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.streak=null; ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; }catch(_m){}
       keys={}; __topClear(); } }},
  {v:'31.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
