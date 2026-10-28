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

# ONE GROWING DAMAGE NUMBER AND YOUR HURT IN RED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function dmgNum(x,y,amount,col,kill){
  if(!G||G.sim) return;
  G.dmgN=G.dmgN||[];
  if(G.dmgN.length>40) G.dmgN.shift();
  G.dmgN.push({x:x,y:y,t:0,life:kill?1.05:0.72,n:amount,c:col||'#FFF6DC',kill:!!kill,
               vx:fxn(-9,9),vy:-26-fxn(0,10)});
}
function tickDmgNums
'@ @'
// v28.xx (cw-cx-dmgmerge), v34.xx (cw-dmgmerge): his g-84 answer, "Yes, one growing number". Target and colour stay separate; only fxn moves the number.
function dmgNum(x,y,amount,col,kill,key){
  if(!G||G.sim||CFG.dmgNumbers===0) return;
  G.dmgN=G.dmgN||[];
  col=col||'#FFF6DC';
  if(key!==undefined&&key!==null){
    for(var i=G.dmgN.length-1;i>=0;i--){
      var d=G.dmgN[i];
      if(d.key===key&&d.c===col&&d.t<d.life&&G.t-d.last<=0.5){
        d.n+=amount; d.kill=d.kill||!!kill; if(d.kill) d.life=1.05;
        d.t=0; d.last=G.t; d.hits++; d.x=x; d.y=y;
        d.vx=fxn(-9,9); d.vy=-26-fxn(0,10); d.pop=0.12;
        return;
      }
    }
  }
  if(G.dmgN.length>=40) G.dmgN.shift();
  G.dmgN.push({x:x,y:y,t:0,life:kill?1.05:0.72,n:amount,c:col,kill:!!kill,
               vx:fxn(-9,9),vy:-26-fxn(0,10),key:key,last:G.t,hits:1,pop:0});
}
function tickDmgNums
'@

SubRx @'
    var d=G.dmgN[i]; d.t+=dt;
'@ @'
    var d=G.dmgN[i]; d.t+=dt; d.pop=Math.max(0,(d.pop||0)-dt);   // v28.xx (cw-cx-dmgmerge): the added-hit pop settles in 0.12 seconds
'@

SubRx @'
function drawDmgNums(){
  if(!G||!G.dmgN||!G.dmgN.length) return;
'@ @'
function drawDmgNums(){
  if(!G||CFG.dmgNumbers===0||!G.dmgN||!G.dmgN.length) return;
'@

SubRx @'
    wc.font=FS(d.kill?TYPE.head:TYPE.label);
'@ @'
    // v28.xx (cw-cx-dmgmerge): six percent per added hit, capped at half again, with a brief quarter-size pop on each add.
    var _dns=(1+Math.min(0.5,0.06*((d.hits||1)-1)))*(1+0.25*Math.min(1,(d.pop||0)/0.12));
    wc.font=FS(d.kill?TYPE.head:TYPE.label).replace(/([\d.]+)px/,function(m,n){ return (parseFloat(n)*_dns).toFixed(1)+'px'; });
'@

SubRx @'
      if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(best.x,best.y-Math.round(best.r*1.1),Math.max(1,Math.round(a)),ELEM.shock.c,best.hp<=0);
'@ @'
      if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(best.x,best.y-Math.round(best.r*1.1),Math.max(1,Math.round(a)),ELEM.shock.c,best.hp<=0,best);   // v28.xx (cw-cx-dmgmerge): shock keeps its target key
'@

SubRx @'
  if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(best.x,best.y-Math.round(best.r*1.1),Math.max(1,Math.round(a)),ELEM.shock.c,best.hp<=0);
'@ @'
  if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(best.x,best.y-Math.round(best.r*1.1),Math.max(1,Math.round(a)),ELEM.shock.c,best.hp<=0,best);   // v28.xx (cw-cx-dmgmerge): shock keeps its target key
'@

SubRx @'
  if(CFG.dmgNumbers!==0){ dmgNum(e.x+fxn(-5,5),top,n,col,kill); if(NET.on) netFxDmg(e.x,top,n,col,kill); }
'@ @'
  if(CFG.dmgNumbers!==0){ dmgNum(e.x+fxn(-5,5),top,n,col,kill,e); if(NET.on) netFxDmg(e.x,top,n,col,kill,e.nid); }   // v28.xx (cw-cx-dmgmerge): the crowbar shares the target id
'@

SubRx @'
                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*(WK?2.7:1.1)),_dn,_dc,hitKills(en,edmg));   // v8.35; v23.18: the kill style on player 2 too   // v27.xx (feel2f): a weak point number starts above its label
'@ @'
                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*(WK?2.7:1.1)),_dn,_dc,hitKills(en,edmg),en);   // v8.35; v23.18: the kill style on player 2 too   // v27.xx (feel2f): a weak point number starts above its label   // v28.xx (cw-cx-dmgmerge): one growing number per target and colour
'@

SubRx @'
                if(NET.on) netFxDmg(en.x,en.y-Math.round(en.r*(WK?2.7:1.1)),_dn,_dc,hitKills(en,edmg));   // v16.22: the party sees your numbers
'@ @'
                if(NET.on) netFxDmg(en.x,en.y-Math.round(en.r*(WK?2.7:1.1)),_dn,_dc,hitKills(en,edmg),en.nid);   // v16.22: the party sees your numbers   // v28.xx (cw-cx-dmgmerge): the teammate merges by target id too
'@

SubRx @'
function netFxDmg(x,y,n,c,dead){
'@ @'
function netFxDmg(x,y,n,c,dead,nid){   // v28.xx (cw-cx-dmgmerge): optional sixth field; older words still draw without merging
'@

SubRx @'
  m={t:'fx',k:'d',s:NET.seat,d:[Math.round(x),Math.round(y),n|0,String(c||'#FFF6DC').slice(0,9),dead?1:0]};
'@ @'
  m={t:'fx',k:'d',s:NET.seat,d:[Math.round(x),Math.round(y),n|0,String(c||'#FFF6DC').slice(0,9),dead?1:0]};
  if(typeof nid==='number'&&isFinite(nid)&&nid>0) m.d.push(nid);
'@

SubRx @'
    a=m.d; try{ if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(+a[0]||0,+a[1]||0,Math.max(1,a[2]|0),(/^#[0-9a-fA-F]{3,8}$/).test(a[3])?a[3]:'#FFF6DC',!!a[4]); }catch(_dn){}
'@ @'
    a=m.d; try{ if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(+a[0]||0,+a[1]||0,Math.max(1,a[2]|0),(/^#[0-9a-fA-F]{3,8}$/).test(a[3])?a[3]:'#FFF6DC',!!a[4],typeof a[5]==='number'&&isFinite(a[5])&&a[5]>0?'p'+a[5]:undefined); }catch(_dn){}   // v28.xx (cw-cx-dmgmerge): no id means no merge
'@

SubRx @'
  if(NET.on&&!G.sim&&amt>0.5&&CFG.dmgNumbers!==0){ try{ netFxDmg(p.x,p.y-26,Math.round(amt),'#ff5a4a',p.hp<=0); }catch(_nfd){} }   // v16.25, his note: your teammate sees the damage you take, in red, over you
'@ @'
  // v28.xx (cw-cx-dmgmerge), v34.xx (cw-selfdmg): his g-85 answer, "Yes, red numbers". Each window sees its own hurt; the bar and ghost still show it too.
  if(!G.sim&&amt>0.5&&CFG.dmgNumbers!==0) dmgNum(p.x+fxn(-5,5),p.y-26,Math.round(amt),'#ff5a4a',p.hp<=0,'self');
  if(NET.on&&!G.sim&&amt>0.5&&CFG.dmgNumbers!==0){ try{ netFxDmg(p.x,p.y-26,Math.round(amt),'#ff5a4a',p.hp<=0); }catch(_nfd){} }   // v16.25, his note: your teammate sees the damage you take, in red, over you
'@

SubRx @'
var VER='36.06';
'@ @'
var VER='36.07';
'@

$pat = "(?m)^  now:'v36\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.07: Hits on the same target and in the same colour grow one number within half a second. Your own hurt shows red above you in solo and co-op, with the health bar feedback kept. Watch: one climbing number should read cleaner in shotgun, LMG and SMG fights; check a weak point still stands out in its own colour, two players on one enemy stay readable, and your red numbers do not crowd your body or reticle. Check 36.07 fails on v36.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
