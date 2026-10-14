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

# THE FORGE: MK III AND THE FOUR ELEMENTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(w.fk===1||w.fk===2) return {err:'MAX TIER',opts:[]};
'@ @'
  if(w.fk===2) return {err:'MAX TIER',opts:[]};
  if(w.fk===1) return {err:'',opts:ELEM_ORDER.map(function(e){ return {k:'el',el:e,cost:FORGE_COST[1]}; })};   // v26.xx (forgest3): MK III, and which element
'@

SubRx @'
sub:short?('NEED '+arcadeCr(need)):arcadeCr(need),short:short};
'@ @'
sub:short?('NEED '+arcadeCr(need)):(arcadeCr(need)+(w.fk===1?' \u00b7 CHOOSE ELEMENT':'')),short:short};
'@

SubRx @'
  p.wep=nw; p.wepIssued=false;
'@ @'
  if(o.k==='el') nw=forgeApply(w,2,o.el);   // v26.xx (forgest3): MK III with the element picked
  p.wep=nw; p.wepIssued=false;
'@

SubRx @'
  col=FORGE_GOLD; tag='MK II';
'@ @'
  col=(o.k==='el')?ELEM[o.el].c:FORGE_GOLD; tag=(o.k==='el')?ELEM[o.el].name:'MK II';
'@

SubRx @'
  say('GUN UPGRADED','obj',{sub:String(nw.name).toUpperCase()});
'@ @'
  say('GUN UPGRADED','obj',{sub:String(nw.name).toUpperCase()+((o.k==='el')?('  \u00b7  '+ELEM[o.el].name):'')});
'@

SubRx @'
  blip('forge');
'@ @'
  blip('forge'); if(o.k==='el'&&ELEM[o.el]&&ELEM[o.el].snd) blip(ELEM[o.el].snd);   // v26.xx (forgest3): and the element's own sound
'@

SubRx @'
function drawForgeUI(){
'@ @'
// v26.xx (forgest3): the four element marks of the MK III cards, one small glyph each in its colour: a flame, a bolt, a snowflake, a drop.
function forgeElemGlyph(c,el,cx,cy,s,col){
  var i, j, e, a, dx, dy, ex, ey, oa;
  function flame(k,oy,fill){
    c.fillStyle=fill; c.beginPath(); c.moveTo(cx,cy+oy-s*k);
    c.bezierCurveTo(cx+s*0.2*k,cy+oy-s*0.5*k,cx+s*0.8*k,cy+oy-s*0.2*k,cx+s*0.65*k,cy+oy+s*0.4*k);
    c.bezierCurveTo(cx+s*0.55*k,cy+oy+s*0.85*k,cx-s*0.55*k,cy+oy+s*0.85*k,cx-s*0.65*k,cy+oy+s*0.4*k);
    c.bezierCurveTo(cx-s*0.7*k,cy+oy+s*0.05*k,cx-s*0.3*k,cy+oy-s*0.2*k,cx-s*0.2*k,cy+oy-s*0.55*k);
    c.bezierCurveTo(cx-s*0.1*k,cy+oy-s*0.7*k,cx-s*0.05*k,cy+oy-s*0.85*k,cx,cy+oy-s*k);
    c.closePath(); c.fill();
  }
  c.save();
  c.globalAlpha=0.20; c.fillStyle=col; c.beginPath(); c.arc(cx,cy,s*1.3,0,6.2832); c.fill(); c.globalAlpha=1;
  c.fillStyle=col; c.strokeStyle=col; c.lineCap='round'; c.lineJoin='round';
  if(el==='fire'){ flame(1,0,col); flame(0.5,s*0.32,'#ffd27a'); }
  else if(el==='shock'){
    c.beginPath(); c.moveTo(cx+s*0.2,cy-s); c.lineTo(cx-s*0.6,cy+s*0.12); c.lineTo(cx-s*0.05,cy+s*0.12); c.lineTo(cx-s*0.25,cy+s); c.lineTo(cx+s*0.65,cy-s*0.22); c.lineTo(cx+s*0.08,cy-s*0.22); c.closePath(); c.fill();
  }
  else if(el==='cryo'){
    c.lineWidth=Math.max(1.5,s*0.17);
    for(i=0;i<3;i++){
      a=i*Math.PI/3+Math.PI/2; dx=Math.cos(a)*s; dy=Math.sin(a)*s;
      c.beginPath(); c.moveTo(cx-dx,cy-dy); c.lineTo(cx+dx,cy+dy); c.stroke();
      for(e=-1;e<=1;e+=2){
        ex=cx+dx*0.62*e; ey=cy+dy*0.62*e; oa=a+(e>0?0:Math.PI);
        for(j=-1;j<=1;j+=2){ c.beginPath(); c.moveTo(ex,ey); c.lineTo(ex+Math.cos(oa+j*0.75)*s*0.34,ey+Math.sin(oa+j*0.75)*s*0.34); c.stroke(); }
      }
    }
  }
  else {
    c.beginPath(); c.moveTo(cx,cy-s); c.quadraticCurveTo(cx+s*0.7,cy-s*0.05,cx+s*0.62,cy+s*0.3);
    c.arc(cx,cy+s*0.3,s*0.62,0,Math.PI,false); c.quadraticCurveTo(cx-s*0.7,cy-s*0.05,cx,cy-s); c.closePath(); c.fill();
    c.globalAlpha=0.55; c.fillStyle='#ffffff'; c.beginPath(); c.ellipse(cx-s*0.22,cy+s*0.28,s*0.1,s*0.2,0.3,0,6.2832); c.fill();
  }
  c.restore();
}
function drawForgeUI(){
'@

SubRx @'
  n=R.opts.length; pad=u(24); HH=u(54); GB=u(92); CH=u(132); FH=u(46);
'@ @'
  n=R.opts.length; pad=u(24); HH=u(54); GB=u(92); CH=u(144); FH=u(46);
'@

SubRx @'
  PW=u(600); PH=HH+GB+u(8)+CH+u(10)+FH;
'@ @'
  PW=u(660); PH=HH+GB+u(8)+CH+u(10)+FH;
'@

SubRx @'
chh, a, yy, rows, k, vr, tx, tw, ckL, xr, ok, lab, kw, hy;
'@ @'
chh, a, yy, rows, k, vr, tx, tw, ckL, xr, ok, lab, kw, hy, E, wd;
'@

SubRx @'
    cy=y+HH+GB+u(8); cx=x+pad; cw=PW-pad*2; chh=CH;
'@ @'
    cy=y+HH+GB+u(8); cx=x+pad; cw=(n>1)?Math.floor((PW-pad*2-u(12)*(n-1))/n):(PW-pad*2); chh=CH;
'@

SubRx @'
      ctx.fillStyle=FORGE_GOLD; ctx.fillRect(c.x+u(10),c.y,u(48),u(3));
'@ @'
      ctx.fillStyle=(o.k==='el')?ELEM[o.el].c:FORGE_GOLD; ctx.fillRect(c.x+u(10),c.y,u(48),u(3));
'@

SubRx @'
      cx+=cw+u(12);
'@ @'
      if(o.k==='el'){
        E=ELEM[o.el]; wd=String(E.w2||'').split(' \u00b7 ');
        forgeElemGlyph(ctx,o.el,c.x+c.w/2,c.y+u(42),u(16),E.c);
        ctx.textAlign='center';
        ctx.font=fH; ctx.fillStyle=E.c; ctx.fillText(E.name,c.x+c.w/2,c.y+u(84));
        ctx.font=fM; ctx.fillStyle=UIC.tx_2; ctx.fillText(wd[0]||'',c.x+c.w/2,c.y+u(101)); ctx.fillText(wd[1]||'',c.x+c.w/2,c.y+u(115));
        ctx.textAlign='left'; ctx.font=fL; ctx.fillStyle=(forgeScore()<o.cost)?UIC.danger:UIC.acc; ctx.fillText(arcadeCr(o.cost),c.x+u(14),c.y+chh-u(12));
        if(!padOn()) forgeKeycap(String(i+1),c.x+c.w-u(14)-u(24),c.y+chh-u(12),fM);
      }
      cx+=cw+u(12);
'@

SubRx @'
    if(padOn()){ hint(padB('A'),'UPGRADE'); hint(padB('B'),'CLOSE'); }
'@ @'
    if(padOn()){ if(n>1) hint('D-PAD','CHOOSE'); hint(padB('A'),'UPGRADE'); hint(padB('B'),'CLOSE'); }
'@

SubRx @'
    else { hint('1','UPGRADE'); hint(keyLabel('KeyE','E'),'CONFIRM'); hint('ESC','CLOSE'); }
'@ @'
    else { hint(n>1?('1-'+n):'1',n>1?'CHOOSE':'UPGRADE'); hint(keyLabel('KeyE','E'),'CONFIRM'); hint('ESC','CLOSE'); }
'@

SubRx @'
  G.forgeUI=null; G.forgeLock=1;
'@ @'
  G.forgeUI=null; G.forgeLock=keys['KeyE']?1:0;   // v26.xx (forgest3): the lock holds only while E is still down, so a quick second visit opens at once
'@

SubRx @'
var VER='26.24';
'@ @'
var VER='26.25';
'@

$pat = "(?m)^  now:'v26\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.25: At THE FORGE a MK II gun can become MK III with FIRE, SHOCK, CRYO or ACID for 6,000 score. Check 26.25 fails on v26.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
