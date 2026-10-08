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

# THE OUTFIT PREVIEWS FILL THEIR TILES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    x2.translate(64,122); x2.scale(2.2,2.2); wc=x2;
    drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});
'@ @'
    // v18.80, seen on the FASHION screenshot (2026-10-07): at a fixed 2.2 the figure filled half its tile. It is painted once at
    // 1.4 with room all round, measured (the rows with paint in them), then painted again scaled so it stands 112 of the 128 pixels, head to boots,
    // whatever the outfit, hat or hair adds on top.
    wc=x2;
    var _paint=function(s,ty){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,128,128); x2.translate(64,ty); x2.scale(s,s); drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); };
    _paint(1.4,96);
    (function(){ var dd, yy, xx, top=999, bot=-1, up, dn, s1;
      try{ dd=x2.getImageData(0,0,128,128).data; }catch(_g){ return; }
      for(yy=0;yy<128;yy++){ for(xx=0;xx<128;xx++){ if(dd[(yy*128+xx)*4+3]>40){ if(yy<top) top=yy; bot=yy; break; } } }
      if(bot<0||top<=0||bot>=127) return;
      up=(96-top)/1.4; dn=(bot-96)/1.4;
      if(!(up+dn>4)) return;
      s1=Math.max(1.6,Math.min(3.6,112/(up+dn)));
      _paint(s1,8+up*s1);
    })();
'@

SubRx @'
  try{ hit=cv2.toDataURL(); }catch(_u){ hit=''; }
'@ @'
  OUTPREV._cv=cv2;   // v18.80: the last preview painted, for the fixture to measure
  try{ hit=cv2.toDataURL(); }catch(_u){ hit=''; }
'@

SubRx @'
var VER='18.79';
'@ @'
var VER='18.80';
'@

$pat = "(?m)^  now:'v18\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.80: The operator in each FASHION outfit tile is bigger and easier to make out. Check 18.80 fails on v18.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
