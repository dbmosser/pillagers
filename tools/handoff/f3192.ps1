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

if ($s.Contains("  {v:'31.92',what:")) { throw "check 31.92 is in the fixture already" }

SubRx @'
  {v:'31.91',what:
'@ @'
  {v:'31.92',what:'the Sentry is drawn as a humanoid combat robot, not a tread and a box: two separate flat feet on the ground, legs that take turns lifting with the step, the lens and the muzzle flash on the gun arm, and a dead one leaves a low toppled robot (his order: more humanoid robot-y, not a big garbage can)',
   run:function(){
     if(typeof drawSentryS!=='function'||typeof drawWreckSentry!=='function'||typeof SENTRY_R0==='undefined'||typeof wreckSmoke!=='function') return 'SKIP: this build has no Sentry painter';
     var keepW=wc, keepS=shadowE, keepM=wreckSmoke, cv=document.createElement('canvas'), x2, R=SENTRY_R0*2, bad=[], d, b0, b1, p, q, r0, y0=190, top=-1, px, py;
     cv.width=260; cv.height=240; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function mk(o){ var e={kind:'sentry',r:R,x:130,y:y0,face:0,step:0,hp:150,maxhp:150,state:'patrol',legs:0,hitT:0,muzzle:0,seenYou:false,overheat:0,windup:null,moving:false}, k; for(k in o) e[k]=o[k]; return e; }
     function snap(e){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,260,240); wc=x2; drawSentryS(e); return x2.getImageData(0,0,260,240).data; }
     function al(m,qx,qy){ return m[(qy*260+qx)*4+3]; }
     function runs(m,qy){ var n=0, on=false, qx, o; for(qx=0;qx<260;qx++){ o=al(m,qx,qy)>60; if(o&&!on) n++; on=o; } return n; }
     function bottom(m,x0,x1){ var qy, qx; for(qy=239;qy>=0;qy--) for(qx=x0;qx<x1;qx++) if(al(m,qx,qy)>60) return qy; return -1; }
     function rgb(m,qx,qy){ var o=(qy*260+qx)*4; return [m[o],m[o+1],m[o+2],m[o+3]]; }
     try{
       shadowE=function(){}; wreckSmoke=function(){};
       // standing, both feet planted: two flat feet with daylight between them at the ground (the old tread was one solid block)
       d=snap(mk({}));
       if(runs(d,y0-4)<2||runs(d,y0-6)<2) bad.push('standing, the Sentry has no two separate feet on the ground ('+runs(d,y0-4)+' and '+runs(d,y0-6)+' runs)');
       if(Math.abs(bottom(d,90,128)-bottom(d,133,170))>2) bad.push('standing, the two feet are not on one ground line');
       // walking: the legs take turns, half a cycle later the other foot is the lifted one
       d=snap(mk({moving:true,step:0})); b0=[bottom(d,90,128),bottom(d,133,170)];
       d=snap(mk({moving:true,step:2.0944})); b1=[bottom(d,90,128),bottom(d,133,170)];
       if(!(b0[0]<b0[1]-4)||!(b1[1]<b1[0]-4)) bad.push('the legs do not take turns lifting with the step ('+b0.join('/')+' then '+b1.join('/')+')');
       // the lens keeps the sensor language on the facing side, the muzzle flash rides the gun arm tip
       d=snap(mk({state:'chase',seenYou:true})); p=rgb(d,147,104);
       if(!(p[0]>200&&p[1]<140)) bad.push('the hunting lens is not red where the head holds it ('+p.join(',')+')');
       d=snap(mk({face:Math.PI,state:'chase',seenYou:true})); p=rgb(d,113,104);
       if(!(p[0]>200&&p[1]<140)) bad.push('facing left, the hunting lens is not on the left side ('+p.join(',')+')');
       p=rgb(snap(mk({muzzle:0.06})),216,116); q=rgb(snap(mk({})),216,116);
       if(!(p[3]>60&&q[3]<30)) bad.push('the muzzle flash is not at the gun arm tip ('+p[3]+' lit, '+q[3]+' without)');
       // its wreck lies low, a toppled robot (the old wreck stood a bent mast 40 up)
       x2.setTransform(2,0,0,2,0,0); x2.clearRect(0,0,130,120); wc=x2;
       drawWreckSentry({x:65,y:100,opened:false,bot:'sentry'});
       x2.setTransform(1,0,0,1,0,0); r0=x2.getImageData(0,0,260,240).data;
       for(py=0;py<240&&top<0;py++) for(px=0;px<260;px++) if(al(r0,px,py)>60){ top=py; break; }
       if(top<0) bad.push('the Sentry wreck draws nothing');
       else if(top<200-2*30) bad.push('the Sentry wreck stands '+Math.round((200-top)/2)+' high, not a low toppled robot');
     } finally { wc=keepW; shadowE=keepS; wreckSmoke=keepM; }
     return bad.length?bad.join('; '):null; }},
  {v:'31.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
