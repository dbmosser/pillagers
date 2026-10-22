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

# TEAMMATE PAD LOST PRIORITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // v28.xx (cw-cx-padlosttag): one teammate warning, his words unchanged, clear of the top message and score stack.
  if(NET.padPeerLost&&G&&!G.over&&state==='raid'){
    t=NET.same==='host'?'p2 pad lost':'p1 pad lost';
    ctx.save();
    try{
      var z=Math.max(0.75,Math.min(2.2,H/1080)), ph=48;
      ctx.font=uiFont('body',1);
      var pw=Math.ceil(ctx.measureText(t).width)+88;
      var bottom=Math.max(HUDBOSSB,HUDGIFTB,HUDMSGB);
      if(SCOREBOX.g===G) bottom=Math.max(bottom,SCOREBOX.y+SCOREBOX.h);
      var py=Math.max(H*0.30-ph*z/2,bottom+16*z);
      ctx.translate(W/2-pw*z/2,py); ctx.scale(z,z);
      uiPanel(ctx,0,0,pw,ph,UIC.warn);
      var icon=uiIconPath('controller');
      if(icon){ ctx.save(); ctx.translate(16,12); ctx.strokeStyle=UIC.warn; ctx.lineWidth=2; ctx.stroke(icon); ctx.restore(); }
      ctx.font=uiFont('body',1); ctx.textAlign='left'; ctx.textBaseline='middle';
      ctx.fillStyle=UIC.warn; ctx.fillText(t,56,ph/2);
    }finally{ ctx.restore(); }
    return t;
  }
'@ @'
  // v28.xx (cw-cx-padlostfocus): one teammate warning, his words unchanged, clear of the top message and score stack.
  if(NET.padPeerLost&&G&&!G.over&&state==='raid'){
    t=NET.same==='host'?'p2 pad lost':'p1 pad lost';
    ctx.save();
    try{
      var z=Math.max(0.75,Math.min(2.2,H/1080)), ph=64;
      ctx.font=uiFont('title',1);
      var pw=Math.max(280,Math.ceil(ctx.measureText(t).width)+112);
      var bottom=Math.max(HUDBOSSB,HUDGIFTB,HUDMSGB);
      if(SCOREBOX.g===G) bottom=Math.max(bottom,SCOREBOX.y+SCOREBOX.h);
      var py=Math.max(H*0.30-ph*z/2,bottom+24*z);
      ctx.translate(W/2-pw*z/2,py); ctx.scale(z,z);
      uiPanel(ctx,0,0,pw,ph,UIC.warn);
      var icon=uiIconPath('controller');
      if(icon){ ctx.save(); ctx.translate(24,20); ctx.strokeStyle=UIC.warn; ctx.lineWidth=2; ctx.stroke(icon); ctx.restore(); }
      ctx.font=uiFont('title',1); ctx.textAlign='left'; ctx.textBaseline='middle';
      ctx.fillStyle=UIC.tx_1; ctx.fillText(t,64,ph/2);
    }finally{ ctx.restore(); }
    return t;
  }
'@

SubRx @'
var VER='34.09';
'@ @'
var VER='34.10';
'@

$pat = "(?m)^  now:'v34\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.10: The warning has a 32px primary text title, a wider 64px panel and 24px clearance from the centre notices. Check 34.10 fails on v34.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
