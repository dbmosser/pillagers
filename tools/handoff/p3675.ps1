$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# ONE DANGER AT A TIME, LOWER ON THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ALERTMIN=2.0, ALERTWAIT=2.5;
'@ @'
var ALERTMIN=2.0, ALERTWAIT=2.5;
// v36.73 (cw-dangerslot), the research rule of 2026-10-27 (his "too many messages coming in to the player"): ONE DANGER AT A TIME, LOWER ON THE SCREEN. The alert banner stood at
// 16 percent of the height, where eyes rarely go in a fight. It now stands at 27 percent (the top of the zone where most fixations land), scales in over 0.2 s and lasts
// 3 s (4 s for a down). A danger (crit, warn) replaces extraction news at once (the extraction line goes back to wait); the same danger and key do not show again for
// 10 s; a danger that cannot show within 1.5 s is dropped and is never written to the feed. The final rush callout keeps its place under the clock stack.
var ALERTDROP=1.5, ALERTAGAIN=10, ALERTYF=0.27, ALERTIN=0.2, ALERTLIFE=3, ALERTLIFEDN=4;
function alertDanger(k){ return k==='crit'||k==='warn'; }
function alertId(m,key){ return String(m)+'|'+String(key||''); }
function alertLife(m,k,o){ if(o&&o.life>0) return o.life; if(!alertDanger(k)) return MSGK[k].life; return (/\bdown\b/i).test(String(m))?ALERTLIFEDN:ALERTLIFE; }
function alertMark(a,now){ if(a&&alertDanger(a.k)&&G) (G.alertSeen=G.alertSeen||{})[alertId(a.m,a.key)]=now; }   // the last time this danger was on screen
function alertRepeat(m,k,o,now){   // a danger said again within 10 s of being on screen (a teammate going down is always new)
  var key=(o&&o.key)||'', s=G&&G.alertSeen, id=alertId(m,key);
  if(!alertDanger(k)||(/^tmdown/).test(key)) return false;
  return !!(s&&s.hasOwnProperty(id)&&now-s[id]<ALERTAGAIN);
}
function alertWaitMax(e){ if(e.back&&e.o&&e.o.hold) return 8; if(alertDanger(e.k)) return ALERTDROP; return e.back?5:ALERTWAIT; }
function alertSlotY(){ return Math.max(ALERTY||LH(96),Math.round(H*ALERTYF/((HUDZ.msg||1)*hudRes()*hudUserZ('msg')))); }   // the top of the danger plate, before the message scale
'@

SubRx @'
G.alert={m:m,k:k,sub:(o&&o.sub)||'',key:(o&&o.key)||'',hold:(o&&o.hold)||null,icon:(o&&o.icon)||'',c:(o&&o.c)||'',
           T:(o&&o.life>0)?o.life:MSGK[k].life,at:now};
'@ @'
G.alert={m:m,k:k,sub:(o&&o.sub)||'',key:(o&&o.key)||'',hold:(o&&o.hold)||null,icon:(o&&o.icon)||'',c:(o&&o.c)||'',col:(o&&o.col)||'',
           T:alertLife(m,k,o),at:now};   // v36.73 (cw-dangerslot): 3 s, 4 s for a down; col is the teammate colour of a teammate down
  alertMark(G.alert,now);
'@

SubRx @'
alertEnq(a.m,a.k,{sub:a.sub,key:a.key,hold:a.hold,icon:a.icon,c:a.c,life:
'@ @'
alertEnq(a.m,a.k,{sub:a.sub,key:a.key,hold:a.hold,icon:a.icon,c:a.c,col:a.col,life:
'@

SubRx @'
function alertToFeed(e){ var o=e.o||{}; 
'@ @'
function alertToFeed(e){ var o=e.o||{}; if(alertDanger(e.k)) return;   // v36.73 (cw-dangerslot): a danger that could not show in time is dropped, never moved to the feed
  
'@

SubRx @'
a.T=Math.max(a.T,(o&&o.life>0)?o.life:MSGK[k].life); alertQDrop(m,key); return;
'@ @'
a.T=Math.max(a.T,alertLife(m,k,o)); alertMark(a,now); alertQDrop(m,key); return;
'@

SubRx @'
if(!a||k==='crit'||(MSGK[k].r>=MSGK[msgKind(a.k)].r&&now-a.at>=ALERTMIN)){ alertQDrop(m,key); alertShow(m,k,o,now); return; }
'@ @'
if(alertRepeat(m,k,o,now)) return;   // v36.73 (cw-dangerslot): the same danger and key do not show again for 10 s
  if(!a||k==='crit'||(k==='warn'&&msgKind(a.k)==='ext')||(MSGK[k].r>=MSGK[msgKind(a.k)].r&&now-a.at>=ALERTMIN)){ alertQDrop(m,key); alertShow(m,k,o,now); return; }   // v36.73 (cw-dangerslot): a warn replaces extraction news at once
'@

SubRx @'
if(a&&a.T>0){ a.T-=dt; if(a.T<0.4&&alertHeld(a)&&now-a.at<8) a.T=0.4; }
'@ @'
if(a&&a.T>0){ a.T-=dt; if(a.T<0.4&&alertHeld(a)&&now-a.at<8) a.T=0.4; alertMark(a,now); }
'@

SubRx @'
if(now-e.t>(e.back?((e.o&&e.o.hold)?8:5):ALERTWAIT)) alertToFeed(q.splice(i,1)[0]);
'@ @'
if(now-e.t>alertWaitMax(e)) alertToFeed(q.splice(i,1)[0]);   // v36.73 (cw-dangerslot): a danger waits 1.5 s and is dropped; extraction news waits 2.5 s (5 s displaced) and goes to the feed
'@

SubRx @'
return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,w:Math.max(LH(320)
'@ @'
return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,slot:0,y:ALERTY||LH(96),w:Math.max(LH(320)
'@

SubRx @'
return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,w:Math.ceil(LH(12)+gs
'@ @'
return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,slot:1,y:alertSlotY(),w:Math.ceil(LH(12)+gs
'@

SubRx @'
if(al){ ALERTL=al; HUDALERTB=Math.round((ALERTY+al.h)*z); HUDFEEDT=ALERTY+al.h+LH(4); }
'@ @'
if(al){ ALERTL=al; HUDALERTB=Math.round((al.y+al.h)*z); HUDFEEDT=al.slot?ALERTY:ALERTY+al.h+LH(4); }   // v36.73 (cw-dangerslot): the danger plate stands at 27 percent, so nothing under the clock stack moves down for it
'@

SubRx @'
al=Math.max(0,Math.min(1,(now-a.at)/0.12,a.T/0.4)), col=HUDC[a.c]
'@ @'
rm=Math.min(1,(now-a.at)/(L.slot?ALERTIN:0.12)), al=Math.max(0,Math.min(rm,a.T/0.4)), col=a.col||HUDC[a.c]
'@

SubRx @'
y0=ALERTY||LH(96), gx=x0+LH(12)
'@ @'
y0=L.y, sc, gx=x0+LH(12)
'@

SubRx @'
ctx.save(); ctx.translate(0,Math.round((1-Math.min(1,(now-a.at)/0.12))*-LH(10)));
'@ @'
ctx.save();
  if(L.slot){ sc=0.86+0.14*(1-(1-rm)*(1-rm)); ctx.translate(W/2,y0+L.h/2); ctx.scale(sc,sc); ctx.translate(-W/2,-(y0+L.h/2)); }   // v36.73 (cw-dangerslot): it scales in over 0.2 s
  else ctx.translate(0,Math.round((1-rm)*-LH(10)));
'@

SubRx @'
key:'tmdown'+s,icon:'party',
'@ @'
key:'tmdown'+s,icon:'party',col:mapSeatColor(s|0),
'@

SubRx @'
var VER='36.74';
'@ @'
var VER='36.75';
'@

$pat = "(?m)^  now:'v36\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.75: Danger callouts stand at 27 percent of the height, one at a time, and a repeated warning is quiet for 10 s. Check 36.75 fails on v36.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
