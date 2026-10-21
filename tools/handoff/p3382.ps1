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

# THE PIXEL LAMPS, FORGE AND SEAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!G.seal) return;
    var SW=G.seal,SRw=sealHere(),needW=sealNeed(SRw.tier);
    var pctW=clamp((SRw.cut+SW.gained)/needW,0,1);
    var swx=SW.x,swy=SW.y;
    wc.fillStyle='rgba(10,8,6,.40)';
    wc.beginPath(); wc.ellipse(swx,swy+4,30,11,0,0,6.2832); wc.fill();
    wc.fillStyle=INK; rrF(swx-26,swy-52,52,56,4);
    wc.fillStyle=SW.done?'#5a4a26':'#2f3844'; rrF(swx-24,swy-50,48,52,3);
    wc.fillStyle=SW.done?'#8a7038':'#465262'; wc.fillRect(swx-24,swy-50,48,4);
    wc.fillStyle='rgba(12,10,16,.6)'; wc.fillRect(swx-18,swy-40,36,3);
    wc.fillRect(swx-18,swy-24,36,3);
    wc.fillStyle=SW.done?'#ffc04a':'#4de3d0';
    wc.fillRect(swx-20,swy-6-44*pctW,40,Math.max(2,44*pctW));
    wc.globalAlpha=0.5;
    wc.fillStyle=SW.done?'#ffc04a':'#8fd0ff';
    wc.fillRect(swx-20,swy-8-44*pctW,40,2);
    wc.globalAlpha=1;
    wc.textAlign='center'; wc.font=FS(TYPE.label);
    wc.fillStyle=INK; wc.fillText(SW.done
'@ @'
    if(!G.seal) return;
    var SW=G.seal,SRw=sealHere(),needW=sealNeed(SRw.tier);
    var pctW=clamp((SRw.cut+SW.gained)/needW,0,1);
    var swx=SW.x,swy=SW.y, pctQ=SW.done?1:Math.round(pctW*20)/20;
    // v33.78 (cw-pixlamps), HIS ORDER (2026-10-20 22:45 to 23:05, the pixel pass): with the pixel look on the slab is one cached scene sprite by state and fill step (5 percent); the label below stays live world text.
    var swP=function(){
    wc.fillStyle='rgba(10,8,6,.40)';
    wc.beginPath(); wc.ellipse(swx,swy+4,30,11,0,0,6.2832); wc.fill();
    wc.fillStyle=INK; rrF(swx-26,swy-52,52,56,4);
    wc.fillStyle=SW.done?'#5a4a26':'#2f3844'; rrF(swx-24,swy-50,48,52,3);
    wc.fillStyle=SW.done?'#8a7038':'#465262'; wc.fillRect(swx-24,swy-50,48,4);
    wc.fillStyle='rgba(12,10,16,.6)'; wc.fillRect(swx-18,swy-40,36,3);
    wc.fillRect(swx-18,swy-24,36,3);
    wc.fillStyle=SW.done?'#ffc04a':'#4de3d0';
    wc.fillRect(swx-20,swy-6-44*pctQ,40,Math.max(2,44*pctQ));
    wc.globalAlpha=0.5;
    wc.fillStyle=SW.done?'#ffc04a':'#8fd0ff';
    wc.fillRect(swx-20,swy-8-44*pctQ,40,2);
    wc.globalAlpha=1;
    };
    if(!(pixOn()&&pixWrap('seal:'+(SW.done?'done':Math.round(pctQ*20)),64,72,PIX_ENV,swP,swx,swy,{up:54}))) swP();
    wc.textAlign='center'; wc.font=FS(TYPE.label);
    wc.fillStyle=INK; wc.fillText(SW.done
'@

SubRx @'
    wc.fillStyle='rgba(10,8,6,.42)'; wc.beginPath(); wc.ellipse(fx,fy+6,34,11,0,0,6.2832); wc.fill();
    wc.fillStyle=INK; rrF(fx-28,fy-13,56,19,3);
    wc.fillStyle='#3b414a'; rrF(fx-26,fy-12,52,16,2); wc.fillStyle='#5b6470'; wc.fillRect(fx-26,fy-12,52,2);
    wc.fillStyle=INK; rrF(fx-24,fy-50,48,40,3);
    wc.fillStyle='#2a2f37'; rrF(fx-22,fy-48,44,36,2); wc.fillStyle='#454d58'; wc.fillRect(fx-22,fy-48,44,3);
    wc.fillStyle='rgba(0,0,0,.30)'; for(k=0;k<3;k++) wc.fillRect(fx-22,fy-40+k*9,44,1);
    wc.fillStyle=INK; wc.fillRect(fx+9,fy-70,13,24); wc.fillStyle='#343a43'; wc.fillRect(fx+11,fy-68,9,22); wc.fillStyle='#4b535e'; wc.fillRect(fx+11,fy-68,9,2);
    wc.fillStyle=INK; wc.fillRect(fx-16,fy-41,32,17);

'@ @'
    // v33.78 (cw-pixlamps): with the pixel look on the furnace, chimney, anvil and the dark frame of the mouth are one cached scene sprite; the molten mouth, the glow, the ring, the embers and the label below stay live.
    var fgP=function(){
    wc.fillStyle='rgba(10,8,6,.42)'; wc.beginPath(); wc.ellipse(fx,fy+6,34,11,0,0,6.2832); wc.fill();
    wc.fillStyle=INK; rrF(fx-28,fy-13,56,19,3);
    wc.fillStyle='#3b414a'; rrF(fx-26,fy-12,52,16,2); wc.fillStyle='#5b6470'; wc.fillRect(fx-26,fy-12,52,2);
    wc.fillStyle=INK; rrF(fx-24,fy-50,48,40,3);
    wc.fillStyle='#2a2f37'; rrF(fx-22,fy-48,44,36,2); wc.fillStyle='#454d58'; wc.fillRect(fx-22,fy-48,44,3);
    wc.fillStyle='rgba(0,0,0,.30)'; for(k=0;k<3;k++) wc.fillRect(fx-22,fy-40+k*9,44,1);
    wc.fillStyle=INK; wc.fillRect(fx+9,fy-70,13,24); wc.fillStyle='#343a43'; wc.fillRect(fx+11,fy-68,9,22); wc.fillStyle='#4b535e'; wc.fillRect(fx+11,fy-68,9,2);
    wc.fillStyle=INK; wc.fillRect(fx-16,fy-41,32,17);
    forgeAnvil(wc,fx-7,fy-60,14,'#59626e',INK);
    };
    if(!(pixOn()&&pixWrap('forge',72,92,PIX_ENV,fgP,fx,fy,{up:74}))) fgP();
    gl=wc.createLinearGradient(0,fy-39,0,fy-26);
    gl.addColorStop(0,'#ffe9a8'); gl.addColorStop(0.45,'#ff9a2a'); gl.addColorStop(1,'#a8300a');
    wc.globalAlpha=0.78+0.22*pv; wc.fillStyle=gl; wc.fillRect(fx-14,fy-39,28,13); wc.globalAlpha=1;
    wc.save(); wc.globalCompositeOperation='lighter'; wc.globalAlpha=0.30+0.20*pv; wc.fillStyle='#ff8a2a'; wc.fillRect(fx-14,fy-39,28,13); wc.restore();
'@

SubRx @'
    gl=wc.createLinearGradient(0,fy-39,0,fy-26);
    gl.addColorStop(0,'#ffe9a8'); gl.addColorStop(0.45,'#ff9a2a'); gl.addColorStop(1,'#a8300a');
    wc.globalAlpha=0.78+0.22*pv; wc.fillStyle=gl; wc.fillRect(fx-14,fy-39,28,13); wc.globalAlpha=1;
    wc.save(); wc.globalCompositeOperation='lighter'; wc.globalAlpha=0.30+0.20*pv; wc.fillStyle='#ff8a2a'; wc.fillRect(fx-14,fy-39,28,13); wc.restore();
    forgeAnvil(wc,fx-7,fy-60,14,'#59626e',INK);

'@ @'

'@

SubRx @'
      if(LG.post){
        // A LAMP POST, standing on the ground, because outdoors there is nothing
        // overhead for a bracket to hang from and a light with no visible cause
        // is the thing he has now reported twice.
        shadowE(LG.x,LG.y,7,3,.34);
        wc.fillStyle=INK; wc.fillRect(lhx-3,lhy+2,6,52);
        wc.fillStyle='#3a3f47'; wc.fillRect(lhx-2,lhy+2,4,52);
        wc.fillStyle='#4d545e'; wc.fillRect(lhx-2,lhy+2,1.4,52);
        wc.fillStyle=INK; wc.fillRect(lhx-6,LG.y-3,12,4);
        wc.fillStyle='#2f343b'; wc.fillRect(lhx-5,LG.y-3,10,3);
      } else {
        // bracket down from above, then the housing, then the lit element
        wc.fillStyle='rgba(20,18,26,.85)';
        wc.fillRect(lhx-1,lhy-14,2,14);
      }
      wc.fillStyle='#2a2733'; wc.fillRect(lhx-7,lhy-2,14,5);
      wc.fillStyle='#141220'; wc.fillRect(lhx-8,lhy+3,16,2);

'@ @'
      // v33.78 (cw-pixlamps), HIS ORDER (2026-10-20 22:45 to 23:05, the pixel pass): with the pixel look on the post, bracket and housing are one cached scene sprite per kind; the lit element, its glow and the ground shadow stay live.
      // A LAMP POST, standing on the ground, because outdoors there is nothing overhead for a bracket to hang from and a light with no visible cause is the thing he has now reported twice.
      if(LG.post) shadowE(LG.x,LG.y,7,3,.34);
      var lpP=function(){
      if(LG.post){
        wc.fillStyle=INK; wc.fillRect(lhx-3,lhy+2,6,52);
        wc.fillStyle='#3a3f47'; wc.fillRect(lhx-2,lhy+2,4,52);
        wc.fillStyle='#4d545e'; wc.fillRect(lhx-2,lhy+2,1.4,52);
        wc.fillStyle=INK; wc.fillRect(lhx-6,LG.y-3,12,4);
        wc.fillStyle='#2f343b'; wc.fillRect(lhx-5,LG.y-3,10,3);
      } else {
        // bracket down from above, then the housing, then the lit element
        wc.fillStyle='rgba(20,18,26,.85)';
        wc.fillRect(lhx-1,lhy-14,2,14);
      }
      wc.fillStyle='#2a2733'; wc.fillRect(lhx-7,lhy-2,14,5);
      wc.fillStyle='#141220'; wc.fillRect(lhx-8,lhy+3,16,2);
      };
      if(!(pixOn()&&pixWrap(LG.post?'lamp:p':'lamp:b',24,LG.post?62:26,PIX_ENV,lpP,LG.x,LG.y,{up:LG.post?56:50}))) lpP();
'@

SubRx @'
var VER='33.81';
'@ @'
var VER='33.82';
'@

$pat = "(?m)^  now:'v33\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.82: With the pixel look on, lamp posts, the forge and the great seal draw as crisp pixel sprites. With the look off nothing changes. Check 33.82 fails on v33.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
