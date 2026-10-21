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

# THE PIXEL BARRELS AND THE PROPS SHEET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  wc.fillStyle=INK; wc.fillRect(x-w-1,y-h-1,w*2+2,h+2);
  wc.fillStyle=fl?'#ff7a4a':'#c4281c'; wc.fillRect(x-w,y-h,w*2,h);
'@ @'
  // v33.66 (cw-pixbarrels), HIS ORDER (2026-10-20 22:45 to 23:05, the pixel pass): with the pixel look on the barrel body (not its pulse, glow or pools) is one cached sprite per blink state.
  var bp=function(){
  wc.fillStyle=INK; wc.fillRect(x-w-1,y-h-1,w*2+2,h+2);
  wc.fillStyle=fl?'#ff7a4a':'#c4281c'; wc.fillRect(x-w,y-h,w*2,h);
'@

SubRx @'
  wc.fillStyle='#f6f3ec'; wc.fillRect(x-2.6,y-h+7,5.2,11); wc.beginPath(); wc.arc(x,y-5.4,2.6,0,6.2832); wc.fill();
'@ @'
  wc.fillStyle='#f6f3ec'; wc.fillRect(x-2.6,y-h+7,5.2,11); wc.beginPath(); wc.arc(x,y-5.4,2.6,0,6.2832); wc.fill();
  };
  if(!(pixOn()&&pixWrap('br:red'+(fl?'f':'n'),48,52,PIX_ACT,bp,x,y,{up:40}))) bp();
'@

SubRx @'
  wc.fillStyle=INK; wc.fillRect(x-w-1,y-h-1,w*2+2,h+2);
  wc.fillStyle=fl?P.fl:P.body; wc.fillRect(x-w,y-h,w*2,h);
'@ @'
  var bp=function(){   // v33.66 (cw-pixbarrels): the body and its symbol, baked once per kind and blink state when the pixel look is on
  wc.fillStyle=INK; wc.fillRect(x-w-1,y-h-1,w*2+2,h+2);
  wc.fillStyle=fl?P.fl:P.body; wc.fillRect(x-w,y-h,w*2,h);
'@

SubRx @'
  if(!lit){   // the idle tell
'@ @'
  };
  if(!(pixOn()&&pixWrap('bk:'+k+(fl?'f':'n'),48,52,PIX_ACT,bp,x,y,{up:40}))) bp();
  if(!lit){   // the idle tell
'@

SubRx @'
pixReg('pillager bots 27',function(){ return pixBodySheet(1); });
'@ @'
pixReg('pillager bots 27',function(){ return pixBodySheet(1); });
// v33.66 (cw-pixprops): the props sheet, 8 across: every container kind closed then opened, the corpse, the carcass, the 9 wrecks, the 4 barrels. Each cell is drawn by the real painter (drawContS, brlDraw) into the sheet with a stub raid.
function pixPropsSheet(){
  var cw=96, ch=96, items=[], w0=wc, g0=G, s, i, it, nm, st;
  function box(type,fn){ var c1={x:0,y:0,r:15,type:type,loot:[],opened:false,time:1,best:'common',prog:0}, c2; if(fn) fn(c1); c2={}; for(var q in c1) c2[q]=c1[q]; c2.opened=true; items.push(['c',c1],['c',c2]); }
  box('crate'); box('locker'); box('safe'); box('safe',function(q){ q.camp=1; }); box('cache'); box('jackpot'); box('bin'); box('botwreck'); box('body');
  box('crate',function(q){ q.carcass='deer'; });
  for(nm in WRECKDRAW) box('cache',function(q){ q.bot=nm; q.cache=1; });
  ['red','shock','acid','cryo'].forEach(function(k){ items.push(['b',{x:0,y:0,id:1,k:k,fuse:-1}]); });
  s=pixCanvas(cw*8,ch*Math.ceil(items.length/8));
  st={sim:0,t:0,tel:{},searching:null,over:false};
  try{
    G=st; wc=s.x;
    for(i=0;i<items.length;i++){
      it=items[i][1]; it.x=7+i*13; it.y=40+i*5;
      wc.setTransform(1,0,0,1,(i%8)*cw+cw/2-it.x,Math.floor(i/8)*ch+ch-12-it.y);
      pixFrame(); if(items[i][0]==='c') drawContS(it); else brlDraw(it);
      pixFrame(); wc.globalAlpha=1;
    }
  } finally { wc=w0; G=g0; }
  return pixSprite(s.c,0,0,PIX_ACT);
}
pixReg('props: loot, bodies, wrecks, barrels',function(){ return pixPropsSheet(); });
'@

SubRx @'
var VER='33.70';
'@ @'
var VER='33.71';
'@

$pat = "(?m)^  now:'v33\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.71: With the pixel look on, explosive barrels draw as crisp pixel sprites; the floor pulse, sparks and glow still move. A props sheet is added to the pixel bench page. With the look off nothing changes. Check 33.71 fails on v33.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
