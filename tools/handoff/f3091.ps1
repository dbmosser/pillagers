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

if ($s.Contains("  {v:'30.91',what:")) { throw "check 30.91 is in the fixture already" }

SubRx @'
  {v:'30.90',what:
'@ @'
  {v:'30.91',what:'cw-downgain, his words on the downed bar: a hit gives half a second back at once with +0.50s shown, one hit a pass, the clock shows two decimals, a miss locks the trigger, a held trigger and a standing player do nothing',
   run:function(){
     if(typeof downBarTick!=='function'||typeof downBarPos!=='function') return 'no downed bar in this build (downBarTick is missing)';
     var bad=[], g, p, md=mouse.down, a, d, i, txt, proto=CanvasRenderingContext2D.prototype, oFt=proto.fillText;
     function stage(){ __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); p=g.player; g.ents.length=0;
       p.hp=0; p.downed=true; p.downT=60; p.revived=1; p.iv=99; p.pendKiller=null; p.dbOn=0; p.dbLock=0; mouse.down=false; }
     function step(down,at){ if(at!==undefined) p.dbT=at-0.1; mouse.down=down; a=p.downT; __sim(0.1); return p.downT-a; }   // the change of the clock over 0.1 s
     function near(x,y){ return Math.abs(x-y)<0.03; }
     try{
       stage();
       d=step(false);
       if(!near(d,-0.1)) return 'a downed player does not bleed 0.1 s in 0.1 s ('+d.toFixed(3)+')';
       // ONE: a HIT gives half a second back at once and shows it
       d=step(true,0.45);
       if(!near(d,0.4)) bad.push('ONE: a hit moved the clock by '+d.toFixed(3)+' s in 0.1 s, not +0.4 (half a second back less the 0.1 s bled)');
       if(!(p.dbGainT>0)) bad.push('ONE: a hit shows no +0.50s');
       for(i=0;i<3;i++){ d=step(false); if(!near(d,-0.1)) { bad.push('ONE: after the hit the clock ran '+d.toFixed(3)+' s in 0.1 s, not -0.1 (no slow bleed)'); break; } }
       // TWO: one hit a pass; out of the spot and back it scores again
       stage(); step(false); step(true,0.45); step(false,0.5);
       d=step(true,0.55);
       if(!near(d,-0.1)) bad.push('TWO: a second press inside the same pass moved the clock by '+d.toFixed(3)+', it should give nothing');
       if(p.dbLock>0) bad.push('TWO: a second press inside a scored spot counted as a miss');
       step(false,0.85); d=step(true,0.45);
       if(!near(d,0.4)) bad.push('TWO: the next pass did not score again ('+d.toFixed(3)+')');
       // THREE: a MISS gives nothing and locks the trigger for a moment
       stage(); step(false);
       d=step(true,0.15);
       if(!near(d,-0.1)) bad.push('THREE: a press outside the middle moved the clock by '+d.toFixed(3));
       if(!(p.dbLock>0)) bad.push('THREE: a miss did not lock the trigger');
       step(false); d=step(true,0.45);
       if(!near(d,-0.1)) bad.push('THREE: a press in the middle during the lockout still counted');
       step(false); d=step(true,0.45);
       if(!near(d,0.4)) bad.push('THREE: the trigger stayed dead after the lockout');
       // FOUR: a HELD trigger as he fell is not a press
       stage(); mouse.down=true; step(true);
       d=step(true,0.45);
       if(!near(d,-0.1)||p.dbLock>0) bad.push('FOUR: a trigger held down as he fell counted as a press');
       step(false); d=step(true,0.45);
       if(!near(d,0.4)) bad.push('FOUR: letting go and pulling again did not count');
       // FIVE: on his feet the bar goes, and a press while standing does nothing
       step(false); p.downed=false; p.hp=40; __sim(0.1);
       if(p.dbOn) bad.push('FIVE: the bar state outlived the revive');
       stage(); p.downed=false; p.hp=100; p.dbT=0.45; mouse.down=true; a=p.downT;
       downBarTick(p,0.1);
       if(p.dbOn===1||p.dbLock>0||p.downT!==a) bad.push('FIVE: a press while standing woke the downed bar');
       // SIX: on a real frame the clock under DOWN has two decimals and a fresh hit draws +0.50s
       if(typeof __vpAlive!=='function'||__vpAlive()){
         stage(); step(false); step(true,0.45); mouse.down=false; txt=[];
         proto.fillText=function(){ txt.push(String(arguments[0])); return oFt.apply(this,arguments); };
         try{ for(i=0;i<3;i++) __loop(performance.now()+i*17); } finally { proto.fillText=oFt; }
         if(!txt.some(function(s){ return /^\d+\.\d\ds$/.test(s); })) bad.push('SIX: the downed clock does not show two decimals ('+txt.filter(function(s){ return /\ds$/.test(s); }).slice(0,4).join(', ')+')');
         if(txt.indexOf('+0.50s')<0) bad.push('SIX: a hit did not draw +0.50s');
       }
       return bad.length?bad.join('; '):null;
     } finally { proto.fillText=oFt; mouse.down=md; try{ __endRaid('abandon'); }catch(_e){} __topClear(); } }},
  {v:'30.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
