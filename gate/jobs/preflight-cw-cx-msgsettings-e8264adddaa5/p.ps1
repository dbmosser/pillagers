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

# MESSAGE SOUNDS AND CONTROLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function msgKind(k){ return (typeof k==='string'&&MSGK.hasOwnProperty(k))?k:'info'; }
'@ @'
function msgKind(k){ return (typeof k==='string'&&MSGK.hasOwnProperty(k))?k:'info'; }
// v28.xx (cw-cx-msgsettings): his review 10-28, five local message families; pickups, money and sp keep their own rules.
function msgTimeK(){ var n=+CFG.msgTime; return n>=1&&n<=10?n:1; }
function msgScaleK(){ var n=+CFG.msgScale; return n>=1&&n<=2?n:1; }
function msgEnabled(c){ return !c||CFG['msgOn'+c]!==0; }
function msgFamily(m,k,o){ if(k==='pick'||k==='log') return ''; var c=msgReach(m,k,o); return /^[abcde]$/.test(c)?c:''; }
function msgFont(f){ return f.replace(/([\d.]+)px/,function(_,n){ return (+n*msgScaleK()).toFixed(1)+'px'; }); }
function msgPlate(x,y,w,h,accent,fill){
  var n=+CFG.msgOpacity; if(!(n>=0&&n<=1)) n=0.88;
  hudPlate(x,y,w,h,accent,String(fill||HUDC.plate).replace(/,[\d.]+\)$/,','+n+')'));
}
var MSGSND={
  a:[[0,196,147,0.12,'sawtooth',0.035],[0.15,147,110,0.14,'sawtooth',0.035]],
  b:[[0,659,659,0.07,'triangle',0.03],[0.08,880,880,0.13,'triangle',0.03]],
  c:[[0,440,440,0.06,'sine',0.04],[0.09,440,440,0.08,'sine',0.04]],
  d:[[0,523,659,0.08,'triangle',0.03],[0.09,784,1047,0.12,'triangle',0.03]],
  e:[[0,220,110,0.12,'square',0.022]]
};
function msgSound(c,k,m,o){
  if(!G||G.sim||G.hubFloor||!MSGSND[c]||!msgEnabled(c)) return false;
  if(typeof NET==='object'&&NET&&NET.specTick) return false;
  var now=statusNow(), seen=G.msgSoundAt||(G.msgSoundAt={}), n=MSGSND[c], v=1;
  if(seen[c]!==undefined&&now-seen[c]<1.5) return false;
  if(c==='b'&&!extAlertSoundOn(m,k,o)) return false;
  seen[c]=now;
  if(c==='a'){ v=volOf('volAlarm'); if(k==='crit') padRumble(0.35,140); }
  if(!(v>0)) return false;
  if(v<1) n=n.map(function(q){ var z=q.slice(); z[5]*=v; return z; });
  return styTone(n);
}

'@

SubRx @'
function alertSting(k){
'@ @'
function alertSting(k,mc,m,o){
  if(mc) return msgSound(mc,k,m,o);   // v28.xx (cw-cx-msgsettings): keep the existing alert sound entry point.
'@

SubRx @'
  try{ if(extAlertSoundOn(m,k,o)) alertSting(k); }catch(_asg){}   // v28.xx (cw-cx-extractquiet): delayed extract/siege callouts obey the audio windows too.
'@ @'
  var mc=msgFamily(m,k,o); if(!msgEnabled(mc)) return;
  try{ if(extAlertSoundOn(m,k,o)) alertSting(k,mc,m,o); }catch(_asg){}   // v28.xx (cw-cx-msgsettings): one sound when the lane shows it, never on refresh.
'@

SubRx @'
function alertSay(m,k,o){
  var now=
'@ @'
function alertSay(m,k,o){
  if(!msgEnabled(msgFamily(m,k,o))) return;
  var now=
'@

SubRx @'
return (a&&a.T>0&&a.m)?a:null;
'@ @'
return (a&&a.T>0&&a.m&&msgEnabled(msgFamily(a.m,a.k,null)))?a:null;
'@

SubRx @'
if(a&&a.T>0){ a.T-=dt;
'@ @'
if(a&&a.T>0){ a.T-=dt/msgTimeK();
'@

SubRx @'
hf=railF(TYPE.title,1.15); lf=railF(TYPE.head,1.28);
'@ @'
hf=msgFont(railF(TYPE.title,1.15)); lf=msgFont(railF(TYPE.head,1.28));
'@

SubRx @'
dn=!!(G.player&&G.player.downed), oa=
'@ @'
dn=!!(G.player&&G.player.downed)||msgScaleK()>1, oa=
'@

SubRx @'
hh=dn?Math.round(42*z):RAIL.h,
'@ @'
hh=dn?Math.round(Math.max(42*z,L.hp*1.5)):RAIL.h,
'@

SubRx @'
  if(dn){ ctx.fillStyle=HUDC.dangerPlate; ctx.fillRect(Math.round(tx0-gm),y0,Math.round(bw+gm*2),hh); RAIL.b=y0+hh; }
'@ @'
  msgPlate(Math.round(tx0-gm),y0,Math.round(bw+gm*2),hh,null,alertDanger(a.k)?HUDC.dangerPlate:HUDC.plate);
  if(dn) RAIL.b=y0+hh;
'@

SubRx @'
var age=(G.fd?G.fd.t:0)-ln.at;
'@ @'
var age=((G.fd?G.fd.t:0)-ln.at)/(ln.mc?msgTimeK():1);
'@

SubRx @'
  F=feedS(); now=F.t; key=(o&&o.key)||''; n=
'@ @'
  if(o&&o.mc&&!msgEnabled(o.mc)) return null;
  F=feedS(); now=F.t; key=(o&&o.key)||''; n=
'@

SubRx @'
  F.lines.push(ln);
'@ @'
  ln.mc=(o&&o.mc)||'';
  F.lines.push(ln);
  if(ln.mc) msgSound(ln.mc,ln.mc==='b'?'ext':'',txt,null);
'@

SubRx @'
  fk=feedKindOf(s,k,o); col=feedCol(fk); gl=undefined;
'@ @'
  var mc=msgFamily(m,k,o); if(!msgEnabled(mc)) return null;
  fk=feedKindOf(s,k,o); col=feedCol(fk); gl=undefined;
'@

SubRx @'
col:col,cap:cap||'',still:(o&&o.still)||null
'@ @'
col:col,cap:cap||'',mc:mc,still:(o&&o.still)||null
'@

SubRx @'
      ln=F.lines[i]; al=feedAlpha(ln);
'@ @'
      ln=F.lines[i]; if(!msgEnabled(ln.mc)) continue;
      fL=ln.mc?msgFont(feedFont()):feedFont(); R.fp=msgPx(fL); R.rh=Math.round(R.fp*1.38); gs=Math.round(R.fp*0.95); ctx.font=fL;
      al=feedAlpha(ln);
'@

SubRx @'
      yt=y-R.rh; x=R.x+
'@ @'
      yt=y-R.rh; if(yt<Math.max(RAIL.b||0,LH(60)*rs)) break; x=R.x+
'@

SubRx @'
      hudPlate(x,yt,w,R.rh,ln.col,HUDC.plate);
'@ @'
      if(ln.mc) msgPlate(x,yt,w,R.rh,ln.col,HUDC.plate); else hudPlate(x,yt,w,R.rh,ln.col,HUDC.plate);
'@

SubRx @'
function ansSay(m,o){

'@ @'
function ansSay(m,o){
  if(!msgEnabled('e')) return null;

'@

SubRx @'
now-A.at<ANSLIFE)
'@ @'
now-A.at<ANSLIFE*msgTimeK())
'@

SubRx @'
  G.ans={m:s,sub:(o&&o.sub)?String(o.sub):'',at:now};
'@ @'
  G.ans={m:s,sub:(o&&o.sub)?String(o.sub):'',at:now};
  msgSound('e','info',m,o);
'@

SubRx @'
(A&&statusNow()-A.at<ANSLIFE)?A:null
'@ @'
(A&&msgEnabled('e')&&statusNow()-A.at<ANSLIFE*msgTimeK())?A:null
'@

SubRx @'
  k=statusNow()-A.at; al=
'@ @'
  f=msgFont(f); px=msgPx(f);
  k=(statusNow()-A.at)/msgTimeK(); al=
'@

SubRx @'
    hudPlate(Math.round(x-bw/2),Math.round(y-bh/2),bw,bh,null,HUDC.plate);
'@ @'
    msgPlate(Math.round(x-bw/2),Math.round(y-bh/2),bw,bh,null,HUDC.plate);
'@

SubRx @'
var GAMEOPTS=[
'@ @'
var GAMEOPTS=[
// v28.xx (cw-cx-msgsettings): his review 10-28, local message controls, all kinds on by default.
  {k:'msgTime',label:'message time',sec:'ACCESSIBILITY',hint:'message time',opts:[{n:'1x',cfg:{msgTime:1}},{n:'2x',cfg:{msgTime:2}},{n:'4x',cfg:{msgTime:4}},{n:'6x',cfg:{msgTime:6}},{n:'8x',cfg:{msgTime:8}},{n:'10x',cfg:{msgTime:10}}],def:0},
  {k:'msgScale',label:'message text size',sec:'ACCESSIBILITY',hint:'message text size',opts:[{n:'100%',cfg:{msgScale:1}},{n:'125%',cfg:{msgScale:1.25}},{n:'150%',cfg:{msgScale:1.5}},{n:'175%',cfg:{msgScale:1.75}},{n:'200%',cfg:{msgScale:2}}],def:0},
  {k:'msgOpacity',label:'message plate opacity',sec:'ACCESSIBILITY',hint:'message plate opacity',opts:[{n:'0%',cfg:{msgOpacity:0}},{n:'25%',cfg:{msgOpacity:0.25}},{n:'50%',cfg:{msgOpacity:0.5}},{n:'75%',cfg:{msgOpacity:0.75}},{n:'88%',cfg:{msgOpacity:0.88}},{n:'100%',cfg:{msgOpacity:1}}],def:4},
  {k:'msgOna',label:'danger messages',sec:'ACCESSIBILITY',hint:'danger messages',opts:[{n:'on',cfg:{msgOna:1}},{n:'off',cfg:{msgOna:0}}],def:0},
  {k:'msgOnb',label:'extraction messages',sec:'ACCESSIBILITY',hint:'extraction messages',opts:[{n:'on',cfg:{msgOnb:1}},{n:'off',cfg:{msgOnb:0}}],def:0},
  {k:'msgOnc',label:'teammate messages',sec:'ACCESSIBILITY',hint:'teammate messages',opts:[{n:'on',cfg:{msgOnc:1}},{n:'off',cfg:{msgOnc:0}}],def:0},
  {k:'msgOnd',label:'goal done messages',sec:'ACCESSIBILITY',hint:'goal done messages',opts:[{n:'on',cfg:{msgOnd:1}},{n:'off',cfg:{msgOnd:0}}],def:0},
  {k:'msgOne',label:'did not work messages',sec:'ACCESSIBILITY',hint:'did not work messages',opts:[{n:'on',cfg:{msgOne:1}},{n:'off',cfg:{msgOne:0}}],def:0},
'@

SubRx @'
var VER='37.67';
'@ @'
var VER='37.68';
'@

$pat = "(?m)^  now:'v37\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.68: Messages have distinct sounds, kind switches, up to 10x time, 200 percent text and plate opacity. Pickups, money and sp keep their rules. Check 37.68 fails on v37.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
