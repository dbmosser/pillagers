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

# READABLE PING LABELS AND MAP GLYPHS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netPingDraw(){
'@ @'
// v28.xx (cw-cx-pingread), critic on his solo ping: 13px orange words covered the target. One readable plate above the body, for every seat.
function netPingLabel(lbl,x,y,r){
  var w, left, by, top;
  ctx.save();
  lbl=String(lbl).toLowerCase();
  ctx.font='600 '+(16*r)+'px '+HUDF;
  w=Math.min(W-32*r,hudRawW(lbl)+16*r);
  left=clamp(x-w/2,8*r,W-w-8*r);
  by=clamp(y<132*r?y+48*r:y-88*r,32*r,H-24*r);top=by-24*r;
  hudPanel(left,top,w,32*r,.85,1);
  ctx.textAlign='center';ctx.textBaseline='alphabetic';ctx.fillStyle=UIC.tx_1;
  ctx.fillText(lbl,left+w/2,by);
  ctx.restore();
}
function netPingDraw(){
'@

SubRx @'
    ctx.font=hudFS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c; hudText(lbl,clamp(x,LH(60)*r,W-LH(60)*r),y-LH(16)*r); ctx.textAlign='left';
'@ @'
    netPingLabel(lbl,x,y,r);   // v28.xx (cw-cx-pingread): 16px bone text, shared plate and a clear gap above the target.
'@

SubRx @'
      colourCueGlyph(ctx,q.dg?'danger':q.pl?'loot':q.w?'target':'place',s.x,s.y,.85*R,ctx.fillStyle);MMAP.ops+=3;
'@ @'
      colourCueGlyph(ctx,q.dg?'danger':q.pl?'loot':q.w?'target':'place',s.x,s.y,1.5*R,ctx.fillStyle);MMAP.ops+=3;   // v28.xx (cw-cx-pingread): 18px target shape and 21px dark backing at 1080p.
'@

SubRx @'
    colourCueGlyph(ctx,p.dg?'danger':p.pl?'loot':p.w?'target':'place',px,py,Math.max(1,hudRes()),p.dg?'#ff4a3a':p.w?'#ff8a3c':'#6fe0ff'); // v28.xx (cw-cx-minicues): the same ping shapes on the sector map.
'@ @'
    colourCueGlyph(ctx,p.dg?'danger':p.pl?'loot':p.w?'target':'place',px,py,1.5*Math.max(1,hudRes()),p.dg?'#ff4a3a':p.w?'#ff8a3c':'#6fe0ff'); // v28.xx (cw-cx-pingread): the same larger ping shape on the full map.
'@

SubRx @'
var VER='35.42';
'@ @'
var VER='35.43';
'@

$pat = "(?m)^  now:'v35\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.43: Ping labels are readable above their targets and ping shapes are larger on both maps. Check 35.43 fails on v35.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
