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

# READABLE SHARED STATUS LABELS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  nf=FS(TYPE.label); vf=FS(TYPE.micro);
'@ @'
  nf=FS(TYPE.head); vf=FS(TYPE.label);   // v28.xx (cw-cx-statusread): shared status type grows from about 16/13 to 20/16 px at 1080p.
'@

SubRx @'
// A dark tab with round ends from x0 to x1, h tall, centred on cy.
function statusPill(x0,cy,x1,h){
  var r=h/2;
  if(x1<x0+h) x1=x0+h;
  ctx.beginPath();
  ctx.arc(x0+r,cy,r,Math.PI*0.5,Math.PI*1.5);
  ctx.arc(x1-r,cy,r,-Math.PI*0.5,Math.PI*0.5);
  ctx.closePath(); ctx.fill();
}
'@ @'
// v28.xx (cw-cx-statusread): the shared status panel, four-pixel corners and one quiet border, at the existing size and anchor.
function statusPill(x0,cy,x1,h){
  var r=Math.min(LH(4),h/2), top=cy-h/2, bot=cy+h/2;
  if(x1<x0+h) x1=x0+h;
  ctx.beginPath(); ctx.moveTo(x0+r,top); ctx.lineTo(x1-r,top); ctx.quadraticCurveTo(x1,top,x1,top+r);
  ctx.lineTo(x1,bot-r); ctx.quadraticCurveTo(x1,bot,x1-r,bot); ctx.lineTo(x0+r,bot); ctx.quadraticCurveTo(x0,bot,x0,bot-r);
  ctx.lineTo(x0,top+r); ctx.quadraticCurveTo(x0,top,x0+r,top); ctx.closePath(); ctx.fill();
  ctx.lineWidth=1; ctx.strokeStyle='#4a5257'; ctx.stroke();
}
'@

SubRx @'
      ctx.fillStyle='rgba(6,9,13,.62)'; statusPill(cx-ph/2,cy,tx+tw+LH(10),ph);
'@ @'
      ctx.fillStyle='rgba(22,25,27,.90)'; statusPill(cx-ph/2,cy,tx+tw+LH(10),ph);   // v28.xx (cw-cx-statusread): style-guide panel fill for every status.
'@

SubRx @'
  lw=Math.max(2,S*0.085); rr=r*0.8; u=S*0.24; hx=r*1.04; ph=S*0.86;
'@ @'
  lw=Math.max(2,S*0.085); rr=r*0.8; u=S*0.24; hx=r*1.04; ph=S*1.12;   // v28.xx (cw-cx-statusread): the two larger text lines fit inside the shared panel.
'@

SubRx @'
      ctx.font=nf; ctx.fillStyle=E.col;     ctx.fillText(E.nm,tx,cy-LH(2));
      ctx.font=vf; ctx.fillStyle='#cdd6dd'; ctx.fillText(E.v||'',tx,cy+LH(9));
'@ @'
      // v28.xx (cw-cx-statusread): neutral readable type; the existing ring and glyph carry each status colour.
      ctx.font=nf; ctx.fillStyle='#efe9dc'; ctx.fillText(E.nm,tx,cy-LH(2));
      ctx.font=vf; ctx.fillStyle='#cdd6dd'; ctx.fillText(E.v||'',tx,cy+LH(11));
'@

SubRx @'
  wC=(S+LH(110))*hr;                         // one column, icon and words, on screen
'@ @'
  wC=(S+LH(130))*hr;   // v28.xx (cw-cx-statusread): collision clearance includes the larger shared status labels.
'@

SubRx @'
      x=Math.floor(s/rows)*(S+LH(110)); y=(s%rows)*(S+g); s++;
'@ @'
      x=Math.floor(s/rows)*(S+LH(130)); y=(s%rows)*(S+g); s++;   // v28.xx (cw-cx-statusread): the same width when a second column is needed.
'@

SubRx @'
var VER='36.19';
'@ @'
var VER='36.20';
'@

$pat = "(?m)^  now:'v36\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.20: Status names and values are larger in matching bordered panels; the active reload chain shows as a status with its count. Check 36.20 fails on v36.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
