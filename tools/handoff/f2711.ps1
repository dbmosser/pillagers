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

if ($s.Contains("  {v:'27.11',what:")) { throw "check 27.11 is in the fixture already" }

SubRx @'
  {v:'27.10',what:
'@ @'
  {v:'27.11',what:'his answer 28: waves grow the longer you stay: with no score the wave tier still rises with the raid clock (one step every two minutes, up to 4), the score still lifts it to 8, and the wave tick uses it',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state) return 'SKIP: no raid here';
     if(typeof waveTier!=='function') return 'there is no wave tier function: the waves grow with the score only';
     var bad=[], g=null, t0, tl0, ts=[], i, secs=[0,130,250,370,490,590], t;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       t0=g.t; tl0=g.timeLeft;
       for(i=0;i<secs.length;i++){
         g.t=secs[i]; if(raidClockOn()) g.timeLeft=g.raidLen-secs[i];
         ts.push(waveTier(0));
       }
       if(ts[0]!==0) bad.push('at minute 0 the tier is '+ts[0]+', not 0');
       for(i=1;i<ts.length;i++) if(ts[i]<ts[i-1]) bad.push('the tier fell from '+ts[i-1]+' to '+ts[i]+' as the clock ran');
       if(!(ts[1]>=1)) bad.push('after 130 seconds with no score the tier is still '+ts[1]);
       if(!(ts[4]>=4)) bad.push('after 490 seconds with no score the tier is only '+ts[4]);
       if(ts[5]>4) bad.push('the clock alone lifts the tier past 4 ('+ts[5]+')');
       g.t=0; if(raidClockOn()) g.timeLeft=g.raidLen;
       t=waveTier(40000);
       if(t!==8) bad.push('a score of 40000 at minute 0 gives tier '+t+', not 8');
       if(String(arcadeWaveTick).indexOf('waveTier(')<0) bad.push('the wave tick does not read the tier from waveTier');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(g){ g.t=t0; g.timeLeft=tl0; } }catch(_t){}
       try{ var g2=__state(); if(g2&&!g2.over&&g2.player){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
