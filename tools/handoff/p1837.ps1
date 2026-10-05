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

# ONE BAR FOR EVERY METER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function bar(x,y,w,h,f,c,bg){
  ctx.fillStyle=bg||'rgba(6,9,13,.8)'; ctx.fillRect(x,y,w,h);
  ctx.fillStyle=c; ctx.fillRect(x,y,w*clamp(f,0,1),h);
  ctx.strokeStyle='rgba(127,146,216,.30)'; ctx.lineWidth=1; ctx.strokeRect(x+.5,y+.5,w-1,h-1);
}
'@ @'
// v18.37, THE STYLING PASS IN THE RAID (2026-10-04): ONE BAR FOR EVERY METER. Health, armour, stamina and every progress bar
// were flat rectangles. They are rounded capsules now: a dark track, the fill lit along its top and its own colour through the
// middle (so the colour a check or an eye reads at the centre is the colour it always was), a thin light line along the top
// and a rounded steel ring. Same position, size and fraction everywhere.
function bar(x,y,w,h,f,c,bg){
  var r=Math.max(1,Math.min(h/2,6)), fw=w*clamp(f,0,1), gr;
  function rp(px,py,pw,ph){ ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(px,py,pw,ph,r); else ctx.rect(px,py,pw,ph); }
  ctx.save();
  rp(x,y,w,h); ctx.fillStyle=bg||'rgba(6,9,13,.8)'; ctx.fill();
  if(fw>0.5){
    rp(x,y,w,h); ctx.clip();
    try{ gr=ctx.createLinearGradient(0,y,0,y+h); gr.addColorStop(0,litHex(c,0.22,true)); gr.addColorStop(0.5,c); gr.addColorStop(1,darkHex(c,0.80)); ctx.fillStyle=gr; }catch(_g){ ctx.fillStyle=c; }
    ctx.fillRect(x,y,fw,h);
    if(h>=6){ ctx.fillStyle='rgba(255,255,255,.16)'; ctx.fillRect(x,y+1,fw,Math.max(1,h*0.12)); }
  }
  ctx.restore();
  rp(x+.5,y+.5,w-1,h-1); ctx.strokeStyle='rgba(127,146,216,.38)'; ctx.lineWidth=1; ctx.stroke();
}
'@

SubRx @'
var VER='18.36';
'@ @'
var VER='18.37';
'@

$pat = "(?m)^  now:'v18\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.37: Health, armour, stamina and progress bars are rounded, shaded capsules. Check 18.37 fails on v18.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
