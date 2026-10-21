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

# PIXEL CONTAINER SHAPES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-cx-propsshape): the 86e critic found plain rectangles and weak open silhouettes. These baked details identify the kind, never the loot value. Footprints are unchanged.
function pixContDetail(ct,w,lift,d2,cF,cT,cL){
  if(!pixOn()||ct.bot||ct.carcass||ct.type==='body'||ct.type==='botwreck') return;
  var x=ct.x, y=ct.y, top=y-lift-d2, metal=ct.type==='locker'||(ct.type==='safe'&&!ct.camp), k;
  if(ct.opened){
    wc.fillStyle=INK; wc.beginPath();
    if(metal){
      // v28.xx (cw-cx-propsshape): inset the hinge so the swung face stays inside the existing width-plus-lid footprint limit.
      var side=ct.type==='locker'?-1:1, edge=x+side*(w/2-4);
      wc.moveTo(edge,top); wc.lineTo(edge+side*7,top+3); wc.lineTo(edge+side*7,y-1); wc.lineTo(edge,y-4);
      wc.closePath(); wc.fill();
      wc.fillStyle=cT; wc.beginPath(); wc.moveTo(edge+side,top+2); wc.lineTo(edge+side*5,top+4); wc.lineTo(edge+side*5,y-3); wc.lineTo(edge+side,y-5); wc.closePath(); wc.fill();
      wc.fillStyle=cL; wc.fillRect(side<0?edge-5:edge+4,top+5,1,Math.max(3,lift-3));
    } else {
      wc.moveTo(x-w/2-1,top-2); wc.lineTo(x-w/2+3,top-10); wc.lineTo(x+w/2+2,top-7); wc.lineTo(x+w/2+1,top-2); wc.closePath(); wc.fill();
      wc.fillStyle=cT; wc.beginPath(); wc.moveTo(x-w/2+1,top-3); wc.lineTo(x-w/2+4,top-8); wc.lineTo(x+w/2,top-6); wc.lineTo(x+w/2-1,top-3); wc.closePath(); wc.fill();
      wc.fillStyle=cL; wc.fillRect(x-w/2+4,top-8,Math.max(3,w-5),1);
    }
    return;
  }
  if(ct.type==='crate'){
    wc.fillStyle='#302414'; wc.fillRect(x-w/2+5,y-lift,1,lift); wc.fillRect(x-w/2+10,y-lift,1,lift);
    wc.fillStyle=cL; wc.fillRect(x-w/2+1,y-3,w-2,1); wc.fillRect(x-w/2+2,top+2,1,d2-3); wc.fillRect(x+w/2-3,top+2,1,d2-3);
  } else if(ct.type==='locker'){
    wc.fillStyle=INK; for(k=0;k<3;k++) wc.fillRect(x-3,top+5+k*3,6,1);
    wc.fillStyle=cL; wc.fillRect(x+3,y-9,1,4);
  } else if(ct.type==='safe'&&!ct.camp){
    wc.strokeStyle=INK; wc.lineWidth=1; wc.strokeRect(x-w/2+2,y-lift+1,w-4,lift-3);
    wc.fillStyle=cL; wc.fillRect(x-1,y-9,3,3); wc.fillRect(x+3,y-8,1,4);
  } else if(ct.type==='cache'||ct.type==='jackpot'){
    wc.fillStyle=cF; wc.fillRect(x-w/2+2,top+2,w-4,Math.max(2,d2-4));
    wc.fillStyle=cL; wc.fillRect(x-w/2+2,y-lift,2,lift); wc.fillRect(x+w/2-4,y-lift,2,lift);
    wc.fillStyle=INK; wc.fillRect(x-3,y-lift+2,6,5); wc.fillStyle=cL; wc.fillRect(x-1,y-lift+3,2,2);
  } else if(ct.type!=='safe'){
    wc.fillStyle=cL; wc.fillRect(x-w/2+2,top+2,w-4,1); wc.fillRect(x-2,y-lift,4,2);
  }
}
function drawContS(ct){
'@

SubRx @'
    wc.fillRect(ct.x-1.6,ct.y-lift+1,3.2,3.4);
  }
  wc.globalAlpha=1;
  };
'@ @'
    wc.fillRect(ct.x-1.6,ct.y-lift+1,3.2,3.4);
  }
  pixContDetail(ct,w,lift,d2,cF,cT,cL);
  wc.globalAlpha=1;
  };
'@

SubRx @'
cF='#3a2050';cT='#8f4fc0';cL='#e0a0ff';
'@ @'
cF=pixOn()?'#403449':'#3a2050';cT=pixOn()?'#80638f':'#8f4fc0';cL=pixOn()?'#bc98ce':'#e0a0ff';
'@

SubRx @'
wc.fillStyle=fl?'#ff7a4a':'#c4281c'; wc.fillRect(x-w,y-h,w*2,h);
'@ @'
wc.fillStyle=fl?'#ff7a4a':(pixOn()?'#a4372f':'#c4281c'); wc.fillRect(x-w,y-h,w*2,h); // v28.xx (cw-cx-propsshape): calmer idle red; the hazard mark and live pulse stay
'@

SubRx @'
wc.fillStyle=fl?'#ffc08a':'#d9483c'; wc.beginPath(); wc.ellipse(x,y-h,w,4.2,0,0,6.2832); wc.fill();
'@ @'
wc.fillStyle=fl?'#ffc08a':(pixOn()?'#b8544c':'#d9483c'); wc.beginPath(); wc.ellipse(x,y-h,w,4.2,0,0,6.2832); wc.fill();
'@

SubRx @'
var VER='33.87';
'@ @'
var VER='33.88';
'@

$pat = "(?m)^  now:'v33\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.88: Pixel containers have clearer shapes and opened states. Check 33.88 fails on v33.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
