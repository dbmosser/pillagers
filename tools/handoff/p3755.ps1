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

# WAITING STATUS READS CLEARLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netWatchHud(){
  ctx.save();
  try{
    netPingDraw();
    var y=H-LH(38), label='waiting', w;
    ctx.font=hudFS(TYPE.label); ctx.textAlign='center'; ctx.textBaseline='middle';
    w=ctx.measureText(label).width+LH(32);
    ctx.fillStyle='rgba(11,12,13,.88)'; ctx.fillRect((W-w)/2,y-LH(18),w,LH(36));
    ctx.fillStyle=HUDC.ally; ctx.fillText(label,W/2,y);
  }finally{ ctx.restore(); }
}
'@ @'
function netWatchHud(){
  ctx.save();
  try{
    netPingDraw();
    // v28.xx (cw-cx-outwatchread): critic round 1 could not distinguish the small waiting line from a world tag. Keep his waiting-only status, 32px minimum, 64px clear of the bottom edge.
    var s=Math.max(1,hudRes()), y=H-96*s, label='waiting', w;
    ctx.font=hudFS(TYPE.title).replace(/([\d.]+)px/,function(m,n){ return Math.max(32*s,+n)+'px'; });
    ctx.textAlign='center'; ctx.textBaseline='middle';
    w=Math.max(208*s,ctx.measureText(label).width+48*s);
    ctx.fillStyle='rgba(17,19,21,.94)'; ctx.fillRect((W-w)/2,y-32*s,w,64*s);
    ctx.fillStyle=HUDC.ally; ctx.fillRect((W-w)/2,y-32*s,w,3*s);
    ctx.fillStyle=HUDC.text||'#e8e4dc'; ctx.fillText(label,W/2,y);
  }finally{ ctx.restore(); }
}
'@

SubRx @'
var VER='37.54';
'@ @'
var VER='37.55';
'@

$pat = "(?m)^  now:'v37\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.55: The waiting status uses at least 32px text at 1080p in a 64px-high panel, with 64px clear of the bottom edge. Normal raid HUD and controls stay as ordered. Check 37.55 fails on v37.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
