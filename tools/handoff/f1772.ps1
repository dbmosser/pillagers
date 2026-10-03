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

if ($s.Contains("  {v:'17.72',what:")) { throw "check 17.72 is in the fixture already" }

SubRx @'
  {v:'17.71',what:
'@ @'
  {v:'17.72',what:'a covered host window keeps the raid running: with no frame for 200 ms and this window hosting a shared raid, the worker tick runs a frame (the clock moves); solo, or with frames coming, it does nothing',
   run:function(){
     if(typeof hidTick!=='function'||typeof HID!=='object') return 'a covered host window freezes the raid for the party';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], t0, r, st0=state;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       state='raid';
       HID.lastRaf=performance.now()-1000; t0=G.t; r=hidTick();
       if(r||G.t!==t0) bad.push('solo, a covered window ran the raid on');
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[{seat:1,state:'in'}]; NET.upSeed=G.seed>>>0;
       HID.lastRaf=performance.now(); t0=G.t; r=hidTick();
       if(r||G.t!==t0) bad.push('with frames still coming the worker tick ran a frame');
       HID.lastRaf=performance.now()-1000; t0=G.t; r=hidTick();
       if(!r) bad.push('hosting a shared raid with no frame for a second, the worker tick did nothing');
       else if(!(G.t>t0)) bad.push('the worker tick ran but the raid clock did not move ('+t0+' to '+G.t+')');
       if(HID.fromWorker) bad.push('the worker flag stayed up after the tick');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       state=st0;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
