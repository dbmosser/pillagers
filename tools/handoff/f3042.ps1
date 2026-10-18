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

if ($s.Contains("  {v:'30.42',what:")) { throw "check 30.42 is in the fixture already" }

SubRx @'
  {v:'30.41',what:
'@ @'
  {v:'30.42',what:'his Q29: an open pause box never idles the demo out; a pause stays until a player unpauses',
   run:function(){
     if(typeof arcadeIdleTick!=='function'||typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade idle here';
     var bad=[], g, ru0, now, r, p0=pauseOpen;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.solo=1; ARCADE.mateAt=0;
       ru0=RUMBLE.usedAt; RUMBLE.usedAt=-1e9;
       now=Date.now(); ARCADE.ownAt=now-400000; pauseOpen=true;
       r=arcadeIdleTick(now);
       if(__state()!==g||g.over||r==='end'||r==='bench') bad.push('a pause box open for over six minutes idled the demo out (tick gave '+(r||'nothing')+')');
       pauseOpen=false;
       r=arcadeIdleTick(now);
       if(r!=='end'&&__state()===g) bad.push('control: the same idle with no pause box did not end the run (tick gave '+(r||'nothing')+')');
       RUMBLE.usedAt=ru0;
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       pauseOpen=p0; keys={};
       try{ ARCADE.solo=0; ARCADE.over=null; ARCADE.ini=null; }catch(_i){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
