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

if ($s.Contains("  {v:'18.93',what:")) { throw "check 18.93 is in the fixture already" }

SubRx @'
  {v:'18.92',what:
'@ @'
  {v:'18.93',what:'Blotter comes on gradually: a dose nine seconds old barely touches the frame and the trip climbs without a step, a Blotter bought under Liquor does not switch every effect on at once, and a second dose bought at the bar fades the melt to its new roll instead of swapping it in one frame (his report 2026-10-07)',
 run:function(){
   var bad=[];
   if(!__vpAlive()) return 'SKIP: the pane has no layout, nothing is drawn';
   if(typeof drawBuzzFx!=='function'||typeof BUZZRND==='undefined'||typeof renderBar!=='function') return 'SKIP: this build has no Blotter to draw';
   if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim raid is loaded and draws no buzz';
   __pinDPR(1); __forceSize(1920,1080);
   var P2=__P(), keepBuzz=P2.buzz, keepCr=P2.credits, keepR=BUZZRND, keepT=BUZZT;
   var hasF=(typeof BUZZRNDP!=='undefined'), kP=hasF?BUZZRNDP:null, kTo=hasF?BUZZRNDTO:null, kAt=hasF?BUZZRNDAT:0;
   var oD=wc.drawImage, rec=[];
   var rollA=[0.12,0.88,0.41,0.67,0.95,0.23,0.58,0.34];
   function lsd(age){ return {id:'lsd',tag:'lsd',t:180-age,dur:180}; }
   function draw(T){ BUZZT=T; rec=[]; drawBuzzFx(); return rec; }
   function disp(a,W,H){
     if(a.length>=9) return Math.abs(a[5]-a[1])+Math.abs(a[6]-a[2])+Math.abs(a[7]-a[3])+Math.abs(a[8]-a[4]);
     if(a.length>=5) return Math.abs(a[1])+Math.abs(a[2])+Math.abs(a[3]-W)+Math.abs(a[4]-H);
     return Math.abs(a[1]||0)+Math.abs(a[2]||0); }
   // hue: the tinted (saturate) self-copy's alpha; tr: the trail buffer's alpha; moved: the largest alpha-weighted shift of any plain self-copy
   function read(T){
     var r=draw(T), W=wc.canvas.width, H=wc.canvas.height, o={hue:0,tr:0,moved:0}, i, c;
     for(i=0;i<r.length;i++){ c=r[i];
       if(c.tr){ o.tr=Math.max(o.tr,c.al); continue; }
       if(!c.self) continue;
       if(c.f.indexOf('saturate(')>=0){ o.hue=Math.max(o.hue,c.al); continue; }
       if(c.f&&c.f!=='none') continue;
       o.moved=Math.max(o.moved,c.al*disp(c.a,W,H)); }
     return o; }
   function sig(T){
     var r=draw(T), s=[], i, j, c, q;
     for(i=0;i<r.length;i++){ c=r[i];
       if(!c.self||c.tr||(c.f&&c.f!=='none')||!(c.al>0.002)) continue;
       q=[c.al.toFixed(4)]; for(j=1;j<c.a.length;j++) q.push((+c.a[j]).toFixed(2)); s.push(q.join(',')); }
     return s.join('|'); }
   try{
     wc.drawImage=function(img){ rec.push({self:img===this.canvas, tr:(!!BUZZTR&&img===BUZZTR), al:+this.globalAlpha, f:String(this.filter||''), a:Array.prototype.slice.call(arguments)}); return oD.apply(this,arguments); };
     // (A) ONSET. One dose at rising ages, same clock (t=1.2: no glitch burst, no flash), one roll.
     BUZZRND=rollA.slice();
     var ages=[5,7,9,15,25,35,45,90], m={}, ai, k;
     for(ai=0;ai<ages.length;ai++){ P2.buzz=[lsd(ages[ai])]; m[ages[ai]]=read(3.0); }
     var pk=m[90];
     if(!(pk.hue>0.3&&pk.tr>0.12&&pk.moved>5)) bad.push('control: a dose at its peak draws the tint at '+pk.hue.toFixed(3)+', trails at '+pk.tr.toFixed(3)+' and moves '+pk.moved.toFixed(1)+' px, so there is no trip to measure');
     else {
       var keys=['hue','tr','moved'], names={hue:'the tinted copy',tr:'the trails',moved:'the melt and the drift'}, prev=null, rr;
       for(ai=0;ai<ages.length;ai++){
         rr={}; for(k=0;k<keys.length;k++) rr[keys[k]]=m[ages[ai]][keys[k]]/pk[keys[k]];
         // THE FINDING. On the current build every pass appears at 7.8 s at 60 to 85 percent of its peak.
         if(ages[ai]===9) for(k=0;k<keys.length;k++) if(rr[keys[k]]>0.3) bad.push('a dose nine seconds old already draws '+names[keys[k]]+' at '+Math.round(rr[keys[k]]*100)+' percent of its peak: it hits all at once');
         if(prev) for(k=0;k<keys.length;k++) if(rr[keys[k]]-prev[keys[k]]>0.4) bad.push(names[keys[k]]+' jumps from '+Math.round(prev[keys[k]]*100)+' to '+Math.round(rr[keys[k]]*100)+' percent of its peak between '+ages[ai-1]+' s and '+ages[ai]+' s');
         prev=rr; }
       if(m[45].hue<0.4*pk.hue||m[45].moved<0.4*pk.moved) bad.push('control: 45 s into a dose the trip has still not arrived');
     }
     // (B) LIQUOR holds the gate open: a Blotter one second old must not draw its floors.
     P2.buzz=[{id:'liquor',tag:'drunk',t:150,dur:180}, lsd(1)];
     var lb=read(3.0);
     if(lb.hue>0.02||lb.tr>0.02) bad.push('with Liquor in him a Blotter bought a second ago already draws the tinted copy at '+lb.hue.toFixed(3)+' and the trails at '+lb.tr.toFixed(3));
     // (C) THE REAL BAR BUTTON. A second dose at age 0 adds no strength, so only the roll can change the frame.
     P2.buzz=[lsd(90)]; P2.credits=1000000; BUZZRND=rollA.slice();
     var s0=sig(3.0);
     renderBar();
     var btn=document.querySelector('#barlist [data-bz="lsd"]');
     if(!btn||btn.disabled||typeof btn.onclick!=='function') bad.push('control: the bar has no Blotter button to press');
     else {
       btn.onclick.call(btn);
       if(P2.buzz.length!==2) bad.push('control: pressing INGEST did not sell a second dose');
       else if(JSON.stringify(BUZZRND)===JSON.stringify(rollA)) bad.push('a fresh dose did not roll the clocks');
       else {
         var R1=BUZZRND, s1=sig(3.0), late=sig(12.0);
         BUZZRND=R1.slice(); var ref=sig(12.0);
         BUZZRND=rollA.slice(); var old12=sig(12.0);
         if(s1!==s0) bad.push('buying a second dose swapped the melt to a new pattern in one frame');
         if(late!==ref) bad.push('nine seconds after the second dose the melt has not landed on its new roll');
         if(ref===old12) bad.push('control: the new roll draws the same melt as the old one');
       }
     }
   }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
   finally{
     try{ delete wc.drawImage; if(wc.drawImage!==oD) wc.drawImage=oD; }catch(_d){}
     P2.buzz=keepBuzz||[]; P2.credits=keepCr; BUZZRND=keepR; BUZZT=keepT;
     if(hasF){ BUZZRNDP=kP; BUZZRNDTO=kTo; BUZZRNDAT=kAt; }
     try{ saveProfile(); renderBar(); }catch(_p){}
     try{ BUZZMENU=''; buzzMenuFx(0,0); }catch(_m){}
     try{ __topClear(); }catch(_c){}
   }
   return bad.length?bad.join('; '):null; }},
  {v:'18.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
