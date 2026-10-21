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

# THE PIXEL RING, POSTS AND RACKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    wc.strokeStyle=act?'#4de3d0':'rgba(148,152,158,.38)';
    wc.lineWidth=act?3:1.5;
    wc.beginPath(); wc.arc(z.x,z.y,z.r,0,6.2832); wc.stroke();

'@ @'
    // v33.83 (cw-pixhub), HIS ORDER (2026-10-20 22:45 to 23:05, the pixel pass): with the pixel look on the ring line is one cached scene sprite per state and radius (a solid 2 or 3 art pixel line); the pulsing fill below stays live.
    var zrr=Math.round(z.r), zE=null;
    if(pixOn()) zE=pixWrap('xz:'+(act?'a':'i')+zrr,zrr*2+16,zrr*2+16,PIX_ENV,function(){ wc.strokeStyle=act?'#4de3d0':'#6c7076'; wc.lineWidth=act?6:4; wc.beginPath(); wc.arc(z.x,z.y,z.r,0,6.2832); wc.stroke(); },z.x,z.y,{up:zrr+8});
    if(!zE){
    wc.strokeStyle=act?'#4de3d0':'rgba(148,152,158,.38)';
    wc.lineWidth=act?3:1.5;
    wc.beginPath(); wc.arc(z.x,z.y,z.r,0,6.2832); wc.stroke();
    }
'@

SubRx @'
      shadowE(s2.x,s2.y+2,13,5,.4);
      wc.fillStyle='#232a33'; wc.fillRect(s2.x-11,s2.y-34,22,34);
      wc.fillStyle='#39424d'; wc.fillRect(s2.x-11,s2.y-37,22,4);
      wc.fillStyle=hexA(s2.c,.20); wc.fillRect(s2.x-8,s2.y-31,16,18);

'@ @'
      shadowE(s2.x,s2.y+2,13,5,.4);
      // v33.83 (cw-pixhub): with the pixel look on the post is one cached scene sprite per tint; its pulsing screen below stays live.
      var hsP=function(){
      wc.fillStyle='#232a33'; wc.fillRect(s2.x-11,s2.y-34,22,34);
      wc.fillStyle='#39424d'; wc.fillRect(s2.x-11,s2.y-37,22,4);
      wc.fillStyle=hexA(s2.c,.20); wc.fillRect(s2.x-8,s2.y-31,16,18);
      };
      if(!(pixOn()&&pixWrap('hs:'+s2.c,32,40,PIX_ENV,hsP,s2.x,s2.y,{up:38}))) hsP();
'@

SubRx @'
    wc.fillStyle='rgba(0,0,0,.4)'; wc.fillRect(_rx+2,_ry+3,26,44);
    wc.fillStyle='#1c2a30'; wc.fillRect(_rx,_ry,26,44);
    wc.fillStyle='#24444c'; wc.fillRect(_rx,_ry,26,5);
    wc.fillStyle='rgba(77,227,208,.5)'; wc.fillRect(_rx+4,_ry+10,18,3);

'@ @'
    // v33.83 (cw-pixhub): with the pixel look on the cabinet body is one cached scene sprite; the blinking lights below stay live.
    var hrP=function(){
    wc.fillStyle='rgba(0,0,0,.4)'; wc.fillRect(_rx+2,_ry+3,26,44);
    wc.fillStyle='#1c2a30'; wc.fillRect(_rx,_ry,26,44);
    wc.fillStyle='#24444c'; wc.fillRect(_rx,_ry,26,5);
    wc.fillStyle='rgba(77,227,208,.5)'; wc.fillRect(_rx+4,_ry+10,18,3);
    };
    if(!(pixOn()&&pixWrap('hr',36,54,PIX_ENV,hrP,_rx+13,_ry+44,{up:46}))) hrP();
'@

SubRx @'
  shadowE(d.x,d.y+2,14,5,.35);
  wc.fillStyle=INK; rrF(d.x-13,d.y-16,26,20,3);
  wc.fillStyle='#6a5236'; rrF(d.x-12,d.y-15,24,18,2.5);
  wc.fillStyle='#8a6a3a'; wc.fillRect(d.x-12,d.y-15,24,4);

'@ @'
  shadowE(d.x,d.y+2,14,5,.35);
  // v33.83 (cw-pixhub): with the pixel look on the crate is one cached scene sprite; the item icon on it stays live.
  var hdP=function(){
  wc.fillStyle=INK; rrF(d.x-13,d.y-16,26,20,3);
  wc.fillStyle='#6a5236'; rrF(d.x-12,d.y-15,24,18,2.5);
  wc.fillStyle='#8a6a3a'; wc.fillRect(d.x-12,d.y-15,24,4);
  };
  if(!(pixOn()&&pixWrap('hd',32,28,PIX_ENV,hdP,d.x,d.y,{up:18}))) hdP();
'@

SubRx @'
var VER='33.82';
'@ @'
var VER='33.83';
'@

$pat = "(?m)^  now:'v33\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.83: With the pixel look on, extraction rings and the Undercroft posts, racks and dropped crates draw as crisp pixel art. With the look off nothing changes. Check 33.83 fails on v33.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
