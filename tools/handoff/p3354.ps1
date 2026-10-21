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

# RAID START MAP CLEARER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mapContractsDraw(cd,rows){
'@ @'
// v28.xx (cw-cx-mapstart-clear): critic P1, keep every map label at 16px and contract rewards at 20px on the raid-start map only.
function mapStartFont(font,z,min){
  if(!mapFirstOn()) return font;
  return String(font).replace(/([\d.]+)px/,function(a,n){return Math.max((min||16)*z,parseFloat(n)).toFixed(1)+'px';});
}
function mapContractsDraw(cd,rows){
'@

SubRx @'
      nameFont=FSz('600 15.4px '+HUDF,z), cntFont=FSz(TYPE.label,z), rewFont=FSz(TYPE.label,z);
'@ @'
      nameFont=FSz('600 15.4px '+HUDF,z), cntFont=mapStartFont(FSz(TYPE.label,z),z), rewFont=mapStartFont(FSz(TYPE.label,z),z,20);
  if(mapFirstOn()) bh=Math.max(1,Math.round(z));   // v28.xx (cw-cx-mapstart-clear): quiet idle tracks keep all eight contracts visible.
'@

SubRx @'
      if(txt){ ctx.font=rewFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(txt,c.x+c.w-q,mid); ctx.textAlign='left'; }
'@ @'
      if(txt){ ctx.font=rewFont; ctx.fillStyle=mapFirstOn()?UIC.tx_1:UIC.tx_2; ctx.textAlign='right'; ctx.fillText(txt,c.x+c.w-q,mid); ctx.textAlign='left'; }
'@

SubRx @'
        ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,mid2-bh/2,barW,bh);
'@ @'
        ctx.fillStyle=mapFirstOn()?UIC.ui_line:UIC.ui_line_hi; ctx.fillRect(c.x+q,mid2-bh/2,barW,bh);
'@

SubRx @'
        barW=c.w-2*q; ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW,bh);
'@ @'
        barW=c.w-2*q; ctx.fillStyle=mapFirstOn()?UIC.ui_line:UIC.ui_line_hi; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW,bh);
'@

SubRx @'
    var t=String(s), fm=(/([\d.]+)px/).exec(String(ctx.font)), fp=fm?parseFloat(fm[1]):12;
'@ @'
    ctx.font=mapStartFont(ctx.font,Math.max(1,hudRes()));   // v28.xx (cw-cx-mapstart-clear): enforce the floor before measuring and placing actual labels.
    var t=String(s), fm=(/([\d.]+)px/).exec(String(ctx.font)), fp=fm?parseFloat(fm[1]):12;
'@

SubRx @'
    ctx.fillStyle='rgba(239,233,220,.66)';   // v31.xx (cw-mapstyle): zone names are the style guide's tx-1 at about 70 percent over a dark halo (they were the district tint at 28 percent, dark on dark)
'@ @'
    ctx.fillStyle=mapFirstOn()?UIC.tx_2:'rgba(239,233,220,.66)';   // v28.xx (cw-cx-mapstart-clear): opaque secondary text over the existing dark halo.
'@

SubRx @'
    if(!CQ.cache) continue;
'@ @'
    if(!CQ.cache||(mapFirstOn()&&CQ.strong)) continue;   // v28.xx (cw-cx-mapstart-clear): the strongbox keeps its dedicated icon, without a second cache ring.
'@

SubRx @'
    ctx.beginPath(); ctx.arc(qx,qy,(6.5+1.5*qp)*_MZ,0,6.2832); ctx.stroke();   // v31.xx (cw-mapstyle2): a cache ring a size smaller, so a stack of them is not a pile
'@ @'
    ctx.beginPath(); ctx.arc(qx,qy,(mapFirstOn()?4:(6.5+1.5*qp))*_MZ,0,6.2832); ctx.stroke();   // v28.xx (cw-cx-mapstart-clear): 4px cache rings keep every location visible in packed rooms.
'@

SubRx @'
    ctx.beginPath(); ctx.arc(qx,qy,2.6*_MZ,0,6.2832); ctx.fill();
'@ @'
    ctx.beginPath(); ctx.arc(qx,qy,(mapFirstOn()?1.6:2.6)*_MZ,0,6.2832); ctx.fill();
'@

SubRx @'
    mapIcon(qx,qy,13*_MZ);
'@ @'
    mapIcon(qx,qy,(mapFirstOn()?7:13)*_MZ);
'@

SubRx @'
    if(!rc.revealed||rc.opened) continue;
'@ @'
    if(!rc.revealed||rc.opened||(mapFirstOn()&&rc.cache)) continue;   // v28.xx (cw-cx-mapstart-clear): a revealed cache already has its small icon.
'@

SubRx @'
    ctx.fillText('CACHE',rmx,rmy-12*_MZ); ctx.textAlign='left';
'@ @'
    if(!mapFirstOn()) ctx.fillText('CACHE',rmx,rmy-12*_MZ); ctx.textAlign='left';   // v28.xx (cw-cx-mapstart-clear): revealed caches obey the same no-words rule.
'@

SubRx @'
var VER='33.53';
'@ @'
var VER='33.54';
'@

$pat = "(?m)^  now:'v33\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.54: Small cache icons keep their locations. Map labels and contract rewards read more clearly. Check 33.54 fails on v33.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
