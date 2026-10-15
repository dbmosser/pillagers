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

# THE ALERT IS POLISHED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  hf=FS(TYPE.head); lf=FS(TYPE.label); hp=msgPx(hf); lp=msgPx(lf); gs=Math.round(hp*0.9);
'@ @'
  // v27.50 (alert3), HIS ANSWER (2026-10-14), "just polish UI up as you see fit consistent with AAA practices", and the HUD spec (section 6): the
  // headline of an alert is the L size (the 32 px step), the detail under it stays the S size. It was the M size, the size of a prompt; a callout
  // that has to be read in a firefight is the biggest line the HUD has bar the score and DOWN.
  hf=FS(TYPE.title); lf=FS(TYPE.label); hp=msgPx(hf); lp=msgPx(lf); gs=Math.round(hp*0.9);
'@

SubRx @'
           T:(o&&o.life>0)?o.life:MSGK[k].life,at:now};
'@ @'
           T:(o&&o.life>0)?o.life:MSGK[k].life,at:now};
  G.alert.T0=G.alert.T;   // v27.50 (alert3): the life it was shown with, for the time bar under the plate
'@

SubRx @'
  ctx.globalAlpha=oa*al;
  hudPlate(x0,y0,L.w,L.h,col,(a.k==='crit'||a.k==='warn')?HUDC.dangerPlate:HUDC.plate);
'@ @'
  ctx.globalAlpha=oa*al;
  ctx.save(); ctx.translate(0,Math.round((1-Math.min(1,(now-a.at)/0.12))*-LH(10)));   // v27.50 (alert3): it drops in from 10 above over its fade in
  hudPlate(x0,y0,L.w,L.h,col,(a.k==='crit'||a.k==='warn')?HUDC.dangerPlate:HUDC.plate);
'@

SubRx @'
  ctx.globalAlpha=oa; ctx.textAlign=oal;
}
'@ @'
  if(a.T0>0&&!alertHeld(a)){ ctx.fillStyle=col; ctx.globalAlpha=oa*al*0.6; ctx.fillRect(x0+LH(3),y0+L.h-Math.max(2,LH(2)),Math.max(0,(L.w-LH(3))*Math.min(1,a.T/a.T0)),Math.max(2,LH(2))); }   // v27.50 (alert3): its time, a bar along the foot of the plate
  ctx.restore();
  ctx.globalAlpha=oa; ctx.textAlign=oal;
}
'@

SubRx @'
var VER='27.49';
'@ @'
var VER='27.50';
'@

$pat = "(?m)^  now:'v27\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.50: The alert headline is larger, the plate drops in, and a time bar runs down along its foot. Check 27.50 fails on v27.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
