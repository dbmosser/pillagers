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

if ($s.Contains("  {v:'28.78',what:")) { throw "check 28.78 is in the fixture already" }

SubRx @'
  {v:'28.77',what:
'@ @'
  {v:'28.78',what:'the downed bar: a press with the slider in the middle halves the bleed-out for about a second and it lapses, a miss does nothing and locks the trigger, a held trigger and a standing player do nothing (his order)',
   run:function(){
     if(typeof downBarTick!=='function'||typeof downBarPos!=='function') return 'no downed bar in this build (downBarTick is missing)';
     var bad=[], g, p, md=mouse.down, a, r0, rH, r, i;
     function stage(){ __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); p=g.player; g.ents.length=0;
       p.hp=0; p.downed=true; p.downT=60; p.revived=1; p.iv=99; p.pendKiller=null; p.dbOn=0; p.dbSteady=0; p.dbLock=0; mouse.down=false; }
     function step(down,at){ if(at!==undefined) p.dbT=at-0.1; mouse.down=down; a=p.downT; __sim(0.1); return a-p.downT; }
     try{
       stage();
       r0=step(false);
       if(!(r0>0)) return 'a downed player is not bleeding out at all ('+r0+')';
       // a HIT: slider at 0.45, a fresh press
       rH=step(true,0.45)/r0;
       if(!(p.dbSteady>0)) bad.push('a press with the slider in the middle did not start the slow bleed');
       if(Math.abs(rH-0.5)>0.06) bad.push('on the hit frame the bleed ran at '+rH.toFixed(2)+' of normal, not half');
       for(i=0;i<9;i++) step(false);
       r=step(false)/r0;
       if(Math.abs(r-0.5)>0.06) bad.push('a second after the hit the bleed ran at '+r.toFixed(2)+' of normal, it should still be half');
       step(false); step(false);
       r=step(false)/r0;
       if(r<0.94) bad.push('the slow bleed did not lapse about 1.2 s after the hit (still '+r.toFixed(2)+' of normal)');
       // a second hit renews the time, it does not stack
       stage(); step(false); step(true,0.45);
       for(i=0;i<6;i++) step(false);
       step(true,0.45);
       if(!(p.dbSteady>1.0&&p.dbSteady<=1.2)) bad.push('a second hit left '+(+p.dbSteady).toFixed(2)+' s of slow bleed, it should renew to about 1.1, not stack');
       // a MISS: slider at 0.15
       stage(); r0=step(false);
       r=step(true,0.15)/r0;
       if(p.dbSteady>0||Math.abs(r-1)>0.06) bad.push('a press outside the middle slowed the bleed (steady '+p.dbSteady+', rate '+r.toFixed(2)+')');
       if(!(p.dbLock>0)) bad.push('a miss did not lock the trigger');
       step(false);
       r=step(true,0.45)/r0;
       if(p.dbSteady>0||Math.abs(r-1)>0.06) bad.push('a press in the middle during the lockout still counted');
       step(false);
       step(true,0.45);
       if(!(p.dbSteady>0)) bad.push('the trigger stayed dead after the lockout');
       // a HELD trigger: down before the first downed frame, never let go
       stage(); mouse.down=true; r0=step(true);
       r=step(true,0.45)/r0;
       if(p.dbSteady>0||p.dbLock>0) bad.push('a trigger held down as he fell counted as a press');
       step(false);
       step(true,0.45);
       if(!(p.dbSteady>0)) bad.push('letting go and pulling again did not count');
       // revive: the bar state goes with him
       step(false);
       p.downed=false; p.hp=40; __sim(0.1);
       if(p.dbOn) bad.push('the bar state outlived the revive');
       // not downed: a press with the slider in the middle does nothing
       stage(); p.downed=false; p.hp=100; p.dbT=0.45; mouse.down=true;
       downBarTick(p,0.1);
       if(p.dbSteady>0||p.dbOn===1||p.dbLock>0) bad.push('a press while standing woke the downed bar');
       // the overlay draws it on a real frame
       if(!bad.length&&(typeof __vpAlive!=='function'||__vpAlive())){
         stage(); step(false); var d0=DB_DRAWS;
         for(i=0;i<3;i++) __loop(performance.now()+i*17);
         if(DB_DRAWS<=d0) bad.push('the downed overlay never drew the bar');
       }
       return bad.length?bad.join('; '):null;
     } finally { mouse.down=md; try{ __endRaid('abandon'); }catch(_e){} __topClear(); } }},
  {v:'28.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
