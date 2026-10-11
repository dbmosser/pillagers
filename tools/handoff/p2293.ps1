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

# ALERT MARKS SIT ABOVE THE NAMEPLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<VIS.length;i++){
    var e=VIS[i];
    var mk=null;
    if(e.state==='investigate') mk=['?','#ffc04a'];
    else if(e.state==='chase'||e.state==='alarm') mk=['!','#ff5040'];
    if(!mk) continue;
    var sm2=w2s(e.x,spriteTop(e)+22,e.y);
    if(sm2){
      ctx.fillStyle=mk[1];
      ctx.font=FS(TYPE.head); ctx.textAlign='center';
      ctx.fillText(mk[0],sm2.x,sm2.y); ctx.textAlign='left';
    }
  }
'@ @'
  // v22.xx, the raid text rewrite (R42): ? AND ! SIT ABOVE THE NAMEPLATE AT EVERY SIZE. HIS ORDER (2026-10-09): the raid text reads like
  // a shooter HUD, and there the alert mark sits clear over the name of what is on you. The mark was lifted spriteTop+22 SCREEN pixels
  // while the nameplate under it is drawn in the world and grows with the zoom, so at 1080p the mark sat in the plate and at 4K (or
  // zoomed in, or down the sights) it sat on the body. Its lift is now the top of that plate (the same spriteTop+8 and micro plate
  // height the world pass uses) times ZOOM(), plus a small gap grown with the screen; it is hudFS(TYPE.head) with the ink outline,
  // and it never leaves the top of the screen. A Crier winding up gets no mark: its own CRIER Ns ring and countdown say it.
  var _mkPh=Math.ceil(msgPx(FS(TYPE.micro))*1.35), _mkZ=ZOOM(), _mkG=LH(4)*Math.max(1,hudRes());
  for(i=0;i<VIS.length;i++){
    var e=VIS[i];
    var mk=null;
    if(e.kind==='snitch'&&e.state==='alarm'&&e.wind!==undefined&&e.wind!==null) continue;   // v22.xx (R42): the winding Crier shows only its countdown
    if(e.state==='investigate') mk=['?','#ffc04a'];
    else if(e.state==='chase'||e.state==='alarm') mk=['!','#ff5040'];
    if(!mk) continue;
    var sm2=w2s(e.x,(spriteTop(e)+8+_mkPh-3)*_mkZ+_mkG,e.y);
    if(sm2){
      ctx.fillStyle=mk[1];
      ctx.font=hudFS(TYPE.head); ctx.textAlign='center';
      hudText(mk[0],sm2.x,Math.max(sm2.y,Math.round(msgPx(ctx.font)+LH(2))));   // v22.xx (R42): outlined, and kept on the screen
      ctx.textAlign='left';
    }
  }
'@

SubRx @'
var VER='22.92';
'@ @'
var VER='22.93';
'@

$pat = "(?m)^  now:'v22\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.93: The ? and ! over a machine now sit just above its name at every screen size and zoom. Check 22.93 fails on v22.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
