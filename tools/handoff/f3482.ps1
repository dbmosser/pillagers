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

if ($s.Contains("  {v:'34.82',what:")) { throw "check 34.82 is in the fixture already" }

SubRx @'
  {v:'34.81',what:
'@ @'
  {v:'34.82',what:'cw-fpscap, his order of 2026-10-25 ("I want higher frame rates to be an option, eg 75, 90, 120, 144, 240"): every frame cap gives its own rate on 60, 120, 144 and 165 Hz screens (60 drew 48 on 144 Hz, 75 and 90 drew 72), a hitch brings no burst, and the Frame cap row steps off, 30, 60, 75, 90, 120, 144, 165, 240 in order',
   run:function(){
     if(typeof frameCapSkip!=='function'||typeof CAP_LAST==='undefined'||typeof cycleGameOpt!=='function'||typeof GAMEOPTS==='undefined'||typeof applyGameOpts!=='function') return 'SKIP: no frame cap here';
     var bad=[], c0=CFG.fpsCap, l0=CAP_LAST, go=(P&&P.gameOpts)?JSON.stringify(P.gameOpts):null, sp=saveProfile, k, i, n, ts, hz, cap, want, seen=[], burst, last;
     var T=[[60,144],[75,144],[90,144],[120,144],[144,144],[240,144],[90,120],[60,120],[60,60],[30,60],[165,165],[240,240]];
     try{
       for(k=0;k<T.length;k++){
         cap=T[k][0]; hz=T[k][1]; CFG.fpsCap=cap; CAP_LAST=0; n=0;
         for(i=0,ts=10000;i<hz*2;i++,ts+=1000/hz+((i%3)-1)*0.3) if(!frameCapSkip(ts)) n++;
         want=Math.min(cap,hz)*2;
         if(Math.abs(n-want)>3) bad.push('a '+cap+' cap on a '+hz+' Hz screen drew '+(n/2)+' frames a second, not '+(want/2));
       }
       // a 300 ms hitch at a 60 cap on 144 Hz: the frames after it keep the 60 spacing (no burst of back to back frames)
       CFG.fpsCap=60; CAP_LAST=0; burst=0; last=-1;
       for(i=0,ts=10000;i<288;i++){ ts+=(i===100)?300:1000/144; if(!frameCapSkip(ts)){ if(last>0&&i>100&&ts-last<12) burst++; last=ts; } }
       if(burst) bad.push(burst+' frames after a hitch came closer than 12 ms apart at a 60 cap');
       CFG.fpsCap=0; CAP_LAST=0; if(frameCapSkip(20000)||frameCapSkip(20001)) bad.push('with the cap off a frame was skipped');
       saveProfile=function(){};
       if(!P.gameOpts) P.gameOpts={};
       P.gameOpts.fpsCap=0; applyGameOpts();
       for(i=0;i<9;i++){ cycleGameOpt('fpsCap'); seen.push(CFG.fpsCap); }
       if(seen.join(',')!=='30,60,75,90,120,144,165,240,0') bad.push('the Frame cap row steps '+seen.join(', ')+' from off, not 30 up to 240 in order then off');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ saveProfile=sp; try{ if(go===null) delete P.gameOpts; else P.gameOpts=JSON.parse(go); applyGameOpts(); }catch(_r){} CFG.fpsCap=c0; CAP_LAST=l0; }
     return bad.length?bad.join('; '):null; }},
  {v:'34.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
