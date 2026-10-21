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

# THE PIXEL WILDLIFE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        shadowE(CT.x,CT.y+1,CT.k==='deer'?15:5,CT.k==='deer'?5:2.5,.34);
        wc.fillStyle='#3a1b12';

'@ @'
        shadowE(CT.x,CT.y+1,CT.k==='deer'?15:5,CT.k==='deer'?5:2.5,.34);
        // v33.84 (cw-pixwild), HIS ORDER (2026-10-20 22:45 to 23:05, the pixel pass): with the pixel look on a dead deer or bird is one cached scene sprite per kind.
        var cdP=function(){
        wc.fillStyle='#3a1b12';

'@

SubRx @'
          wc.moveTo(CT.x+11,CT.y-4); wc.lineTo(CT.x+17,CT.y-7);
          wc.moveTo(CT.x-9,CT.y-1); wc.lineTo(CT.x-15,CT.y+1);
          wc.stroke();
        }

'@ @'
          wc.moveTo(CT.x+11,CT.y-4); wc.lineTo(CT.x+17,CT.y-7);
          wc.moveTo(CT.x-9,CT.y-1); wc.lineTo(CT.x-15,CT.y+1);
          wc.stroke();
        }
        };
        if(!(pixOn()&&pixWrap('cd:'+CT.k,CT.k==='deer'?48:20,CT.k==='deer'?26:14,PIX_ENV,cdP,CT.x,CT.y,{up:CT.k==='deer'?14:8}))) cdP();

'@

SubRx @'
        var flap=CT.st==='flee'?Math.sin(CT.f)*5:0;
        wc.fillStyle=INK;
        wc.beginPath(); wc.ellipse(cxw,cyw-3,4.2,3,0,0,6.2832); wc.fill();
        wc.fillStyle='#2e3238';
        wc.beginPath(); wc.ellipse(cxw,cyw-3.5,3.2,2.2,0,0,6.2832); wc.fill();
        if(CT.st==='flee'){
          wc.strokeStyle='#20242a'; wc.lineWidth=1.6; wc.beginPath();
          wc.moveTo(cxw-2,cyw-4); wc.lineTo(cxw-8,cyw-4-flap);
          wc.moveTo(cxw+2,cyw-4); wc.lineTo(cxw+8,cyw-4-flap);
          wc.stroke();
        } else {
          // Head down and pecking, which is what says "nothing has spooked it".
          var pk=Math.sin(CT.f*1.4)>0.72?2:0;
          wc.fillStyle=INK; wc.fillRect(cxw+fl*3,cyw-5+pk,2,2);
        }

'@ @'
        var flap=CT.st==='flee'?Math.round(Math.sin(CT.f)*2)*2.5:0, pk=(CT.st!=='flee'&&Math.sin(CT.f*1.4)>0.72)?2:0;   // v33.84 (cw-pixwild): the wing beat and the peck are steps, so a pixel frame can be cached
        var bdP=function(){
        wc.fillStyle=INK;
        wc.beginPath(); wc.ellipse(cxw,cyw-3,4.2,3,0,0,6.2832); wc.fill();
        wc.fillStyle='#2e3238';
        wc.beginPath(); wc.ellipse(cxw,cyw-3.5,3.2,2.2,0,0,6.2832); wc.fill();
        if(CT.st==='flee'){
          wc.strokeStyle='#20242a'; wc.lineWidth=1.6; wc.beginPath();
          wc.moveTo(cxw-2,cyw-4); wc.lineTo(cxw-8,cyw-4-flap);
          wc.moveTo(cxw+2,cyw-4); wc.lineTo(cxw+8,cyw-4-flap);
          wc.stroke();
        } else {
          // Head down and pecking, which is what says "nothing has spooked it".
          wc.fillStyle=INK; wc.fillRect(cxw+fl*3,cyw-5+pk,2,2);
        }
        };
        if(!(pixOn()&&pixWrap('bd:'+(CT.st==='flee'?'f'+flap:'g'+pk)+(fl>0?'r':'l'),24,24,PIX_ENV,bdP,cxw,cyw,{up:16}))) bdP();
'@

SubRx @'
        var run=CT.st==='flee',gait=Math.sin(CT.f)*(run?5:1.2);
        wc.strokeStyle=INK; wc.lineWidth=2.2; wc.beginPath();
        wc.moveTo(cxw-6,cyw-9); wc.lineTo(cxw-6-gait*0.5,cyw);
        wc.moveTo(cxw+6,cyw-9); wc.lineTo(cxw+6+gait*0.5,cyw);
        wc.moveTo(cxw-3,cyw-9); wc.lineTo(cxw-3+gait*0.5,cyw);
        wc.moveTo(cxw+3,cyw-9); wc.lineTo(cxw+3-gait*0.5,cyw);
        wc.stroke();
        wc.fillStyle=INK; rrF(cxw-11,cyw-23,22,15,6);
        wc.fillStyle='#6b563f'; rrF(cxw-10,cyw-22,20,13,5);
        wc.fillStyle='#7d6749'; rrF(cxw-10,cyw-22,20,5,4);
        // neck and head: down when grazing, level and forward when running
        var hy=run?(cyw-30):(cyw-13+Math.sin(CT.f*0.8)*2);
        var hx=cxw+fl*13;
        wc.strokeStyle=INK; wc.lineWidth=4.5; wc.beginPath();
        wc.moveTo(cxw+fl*8,cyw-20); wc.lineTo(hx,hy); wc.stroke();
        wc.strokeStyle='#6b563f'; wc.lineWidth=2.6; wc.beginPath();
        wc.moveTo(cxw+fl*8,cyw-20); wc.lineTo(hx,hy); wc.stroke();
        wc.fillStyle=INK; rrF(hx-3,hy-4,7,7,2.5);
        wc.fillStyle='#7d6749'; rrF(hx-2.5,hy-3.5,6,6,2);
        // antlers on some of them, decided by the fixed phase so one deer does
        // not grow and lose them frame to frame
        if(CT.ant){
          wc.strokeStyle='#4a3f30'; wc.lineWidth=1.5; wc.beginPath();
          wc.moveTo(hx,hy-3); wc.lineTo(hx+fl*3,hy-11); wc.lineTo(hx+fl*7,hy-13);
          wc.moveTo(hx+fl*3,hy-11); wc.lineTo(hx-fl*1,hy-14);
          wc.stroke();
        }
        wc.fillStyle='rgba(232,226,214,.55)';
        wc.fillRect(cxw-fl*11,cyw-14,4,4);

'@ @'
        var run=CT.st==='flee',gait=Math.round(Math.sin(CT.f)*(run?5:1.2)), hbob=Math.round(Math.sin(CT.f*0.8)*2);   // v33.84 (cw-pixwild): the gait and the head bob are whole steps, so a pixel frame can be cached
        var drP=function(){
        wc.strokeStyle=INK; wc.lineWidth=2.2; wc.beginPath();
        wc.moveTo(cxw-6,cyw-9); wc.lineTo(cxw-6-gait*0.5,cyw);
        wc.moveTo(cxw+6,cyw-9); wc.lineTo(cxw+6+gait*0.5,cyw);
        wc.moveTo(cxw-3,cyw-9); wc.lineTo(cxw-3+gait*0.5,cyw);
        wc.moveTo(cxw+3,cyw-9); wc.lineTo(cxw+3-gait*0.5,cyw);
        wc.stroke();
        wc.fillStyle=INK; rrF(cxw-11,cyw-23,22,15,6);
        wc.fillStyle='#6b563f'; rrF(cxw-10,cyw-22,20,13,5);
        wc.fillStyle='#7d6749'; rrF(cxw-10,cyw-22,20,5,4);
        // neck and head: down when grazing, level and forward when running
        var hy=run?(cyw-30):(cyw-13+hbob);
        var hx=cxw+fl*13;
        wc.strokeStyle=INK; wc.lineWidth=4.5; wc.beginPath();
        wc.moveTo(cxw+fl*8,cyw-20); wc.lineTo(hx,hy); wc.stroke();
        wc.strokeStyle='#6b563f'; wc.lineWidth=2.6; wc.beginPath();
        wc.moveTo(cxw+fl*8,cyw-20); wc.lineTo(hx,hy); wc.stroke();
        wc.fillStyle=INK; rrF(hx-3,hy-4,7,7,2.5);
        wc.fillStyle='#7d6749'; rrF(hx-2.5,hy-3.5,6,6,2);
        // antlers on some of them, decided by the fixed phase so one deer does
        // not grow and lose them frame to frame
        if(CT.ant){
          wc.strokeStyle='#4a3f30'; wc.lineWidth=1.5; wc.beginPath();
          wc.moveTo(hx,hy-3); wc.lineTo(hx+fl*3,hy-11); wc.lineTo(hx+fl*7,hy-13);
          wc.moveTo(hx+fl*3,hy-11); wc.lineTo(hx-fl*1,hy-14);
          wc.stroke();
        }
        wc.fillStyle='rgba(232,226,214,.55)';
        wc.fillRect(cxw-fl*11,cyw-14,4,4);
        };
        if(!(pixOn()&&pixWrap('dr:'+(run?'r':'g')+gait+':'+(run?0:hbob)+(fl>0?'r':'l')+(CT.ant?'a':''),72,56,PIX_ENV,drP,cxw,cyw,{up:50}))) drP();
'@

SubRx @'
var VER='33.84';
'@ @'
var VER='33.85';
'@

$pat = "(?m)^  now:'v33\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.85: With the pixel look on, deer and birds draw as crisp pixel frames. With the look off nothing changes except the animal steps are whole pixels. Check 33.85 fails on v33.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
