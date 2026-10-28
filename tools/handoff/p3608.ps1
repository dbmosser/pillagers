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

# DAMAGE NUMBERS CLEAR THE TARGET NAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawDmgNums(){
  if(!G||CFG.dmgNumbers===0||!G.dmgN||!G.dmgN.length) return;
  for(var i=0;i<G.dmgN.length;i++){
    var d=G.dmgN[i],k=1-d.t/d.life;
    wc.globalAlpha=Math.min(1,k*1.8);
    // v28.xx (cw-cx-dmgmerge): six percent per added hit, capped at half again, with a brief quarter-size pop on each add.
    var _dns=(1+Math.min(0.5,0.06*((d.hits||1)-1)))*(1+0.25*Math.min(1,(d.pop||0)/0.12));
    wc.font=FS(d.kill?TYPE.head:TYPE.label).replace(/([\d.]+)px/,function(m,n){ return (parseFloat(n)*_dns).toFixed(1)+'px'; });
    wc.textAlign='center';
    var _dlw=wc.lineWidth, _dlj=wc.lineJoin; wc.lineJoin='round'; wc.lineWidth=3; wc.strokeStyle=INK; wc.strokeText(d.kill?(d.n+'!'):String(d.n),d.x,d.y); wc.lineWidth=_dlw; wc.lineJoin=_dlj;   // v27.xx (feel2f): an ink outline, so every colour reads on every floor
    wc.fillStyle=INK;   wc.fillText(d.kill?(d.n+'!'):String(d.n),d.x+1,d.y+1);
    wc.fillStyle=d.c;   wc.fillText(d.kill?(d.n+'!'):String(d.n),d.x,d.y);
  }
  wc.globalAlpha=1; wc.textAlign='left';
}

'@ @'
// v28.xx (cw-cx-dmgspace): the critic on g-84 burst pictures: growing numbers covered the target name and other hit colours. Reserve space above the name; keep simultaneous colours apart.
function dmgNumLayout(){
  var out=[],i,j,d,e,nid,px,npx,top,txt,font,w,x,y,pass,clear,q,scale,alerted;
  if(!G||CFG.dmgNumbers===0||!G.dmgN) return out;
  npx=parseFloat((FS(TYPE.micro).match(/([\d.]+)px/)||[0,16])[1]);
  for(i=0;i<G.dmgN.length;i++){
    d=G.dmgN[i]; e=null;
    if(d.key&&typeof d.key==='object') e=d.key;
    else if(typeof d.key==='string'&&/^p[1-9]\d*$/.test(d.key)){
      nid=+d.key.slice(1); e=NET.entMap&&NET.entMap[nid];
      if(!e) for(j=0;j<G.ents.length;j++) if(G.ents[j].nid===nid){ e=G.ents[j]; break; }
    }
    scale=(1+Math.min(0.5,0.06*((d.hits||1)-1)))*(1+0.25*Math.min(1,(d.pop||0)/0.12));
    font=FS(d.kill?TYPE.head:TYPE.label).replace(/([\d.]+)px/,function(m,n){return (parseFloat(n)*scale).toFixed(1)+'px';});
    px=parseFloat((font.match(/([\d.]+)px/)||[0,18])[1]);
    txt=d.kill?(d.n+'!'):String(d.n); wc.font=font; w=wc.measureText(txt).width;
    x=d.x; y=d.y; alerted=e&&(e.state==='investigate'||e.state==='chase'||e.state==='alarm');
    if(e){
      top=e.y-spriteTop(e)-8-Math.ceil(npx*1.35)+3;
      y=Math.min(y,top-8-px*0.2);
    }else if(d.key==='self'||(!d.key&&d.c==='#ff5a4a')) y-=48;
    // v28.xx (cw-cx-dmgspace): colour, source, stored hit position and timing stay untouched. Only this frame's text bounds move; the alert mark keeps its own space too.
    for(pass=0;pass<81;pass++){
      x=d.x+(pass?Math.ceil(pass/2)*(w+10)*(pass%2?1:-1):0); clear=true;
      if(alerted&&x-w/2<e.x+npx/2+4&&x+w/2>e.x-npx/2-4&&y+px*0.2>top-4-Math.max(24,npx*2)&&y-px*0.85<top-4) clear=false;
      for(j=0;j<out.length;j++){
        q=out[j];
        if(x-w/2<q.x+q.w/2+8&&x+w/2>q.x-q.w/2-8&&y-px*0.85<q.y+q.px*0.2+8&&y+px*0.2>q.y-q.px*0.85-8){clear=false;break;}
      }
      if(clear) break;
    }
    out.push({d:d,x:x,y:y,w:w,px:px,font:font,txt:txt});
  }
  return out;
}
function drawDmgNums(){
  var nums=dmgNumLayout();
  if(!nums.length) return;
  for(var i=0;i<nums.length;i++){
    var q=nums[i],d=q.d,k=1-d.t/d.life;
    wc.globalAlpha=Math.min(1,k*1.8); wc.font=q.font; wc.textAlign='center';
    var _dlw=wc.lineWidth,_dlj=wc.lineJoin;
    wc.lineJoin='round'; wc.lineWidth=3; wc.strokeStyle=INK; wc.strokeText(q.txt,q.x,q.y); wc.lineWidth=_dlw; wc.lineJoin=_dlj;
    wc.fillStyle=INK; wc.fillText(q.txt,q.x+1,q.y+1);
    wc.fillStyle=d.c; wc.fillText(q.txt,q.x,q.y);
  }
  wc.globalAlpha=1; wc.textAlign='left';
}

'@

SubRx @'
var VER='36.07';
'@ @'
var VER='36.08';
'@

$pat = "(?m)^  now:'v36\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.08: Growing damage numbers sit above target names and separate when their text would overlap. Red hurt numbers sit clear of your head. Totals, colours and hit timing are unchanged. Check 36.08 fails on v36.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
