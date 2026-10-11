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

# RETICLE WORDS GROW AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _HB=hotbarSlots()[hotSel()];
    var _gunUp=(!_HB||_HB.kind==='gun');
'@ @'
    // v22.xx, the raid text rewrite (R41): THE RETICLE WORDS GROW AT 4K. HIS ORDER (2026-10-09): the raid text reads like a shooter HUD,
    // the same size on every screen. The cross grew with the screen at v9.53 (HIS REPORT AT 4K: "reticule is tiny"), but the words
    // under it (NO AMMO, JAMMED, [R] RELOAD), the reload seconds beside it, the struck-through line and the widths of the magazine
    // and reload rings kept their 1080p size, so at 4K the thing you read in a firefight was small print beside a big cross. They
    // now use hudFS and grow by the same screen factor (_wz, its own, as the hit ticks have since v21.25). At 1080p nothing moves.
    var _wz=Math.max(1,(typeof hudRes==='function')?hudRes():1);
    var _HB=hotbarSlots()[hotSel()];
    var _gunUp=(!_HB||_HB.kind==='gun');
'@

SubRx @'
      ctx.lineWidth=(CFG.cursorLoud!==0?3.4:2.2)+((typeof _kick!=='undefined')?_kick*1.6:0); ctx.lineCap='butt';
'@ @'
      ctx.lineWidth=((CFG.cursorLoud!==0?3.4:2.2)+((typeof _kick!=='undefined')?_kick*1.6:0))*_wz; ctx.lineCap='butt';   // v22.xx (R41): the ring width grows with the screen
'@

SubRx @'
      var _rlr=gap+len+4;
      if(CFG.cursorLoud!==0){
        ctx.strokeStyle='rgba(255,192,74,.26)'; ctx.lineWidth=4.4;
        ctx.beginPath(); ctx.arc(rx0,ry0,_rlr,0,6.2832); ctx.stroke();
        ctx.strokeStyle='rgba(255,192,74,.95)'; ctx.lineWidth=4.4;
        ctx.beginPath(); ctx.arc(rx0,ry0,_rlr,-1.5708,-1.5708+6.2832*_rlf); ctx.stroke();
        var _ta0=ctx.textAlign;
        ctx.font=FS(TYPE.micro); ctx.textAlign='left'; ctx.fillStyle='rgba(255,192,74,.95)';
        ctx.fillText((Math.max(0,p.reloading)/1000).toFixed(1)+'s',rx0+_rlr+7,ry0+4);
        ctx.textAlign=_ta0;
      } else {
        ctx.strokeStyle='rgba(255,192,74,.9)'; ctx.lineWidth=2.4;
'@ @'
      var _rlr=gap+len+4*_wz;   // v22.xx (R41): the ring, its widths and the seconds grow with the screen
      if(CFG.cursorLoud!==0){
        ctx.strokeStyle='rgba(255,192,74,.26)'; ctx.lineWidth=4.4*_wz;
        ctx.beginPath(); ctx.arc(rx0,ry0,_rlr,0,6.2832); ctx.stroke();
        ctx.strokeStyle='rgba(255,192,74,.95)'; ctx.lineWidth=4.4*_wz;
        ctx.beginPath(); ctx.arc(rx0,ry0,_rlr,-1.5708,-1.5708+6.2832*_rlf); ctx.stroke();
        var _ta0=ctx.textAlign;
        ctx.font=hudFS(TYPE.micro); ctx.textAlign='left'; ctx.fillStyle='rgba(255,192,74,.95)';
        ctx.fillText((Math.max(0,p.reloading)/1000).toFixed(1)+'s',rx0+_rlr+7*_wz,ry0+4*_wz);
        ctx.textAlign=_ta0;
      } else {
        ctx.strokeStyle='rgba(255,192,74,.9)'; ctx.lineWidth=2.4*_wz;
'@

SubRx @'
      ctx.strokeStyle=rCol; ctx.lineWidth=2;
      ctx.beginPath();
      ctx.moveTo(rx0-gap+2,ry0-gap+2); ctx.lineTo(rx0+gap-2,ry0+gap-2);
      ctx.stroke();
      ctx.font=FS(TYPE.micro); ctx.textAlign='center';
'@ @'
      ctx.strokeStyle=rCol; ctx.lineWidth=2*_wz;   // v22.xx (R41): the line and the word under it grow with the screen
      ctx.beginPath();
      ctx.moveTo(rx0-gap+2*_wz,ry0-gap+2*_wz); ctx.lineTo(rx0+gap-2*_wz,ry0+gap-2*_wz);
      ctx.stroke();
      ctx.font=hudFS(TYPE.micro); ctx.textAlign='center';
'@

SubRx @'
      ctx.fillText(rState==='jam'?'JAMMED':(rState==='dry'?'NO AMMO':'['+keyLabel('KeyR','R')+'] RELOAD'),rx0,ry0+gap+len+LH(14));
'@ @'
      ctx.fillText(rState==='jam'?'JAMMED':(rState==='dry'?'NO AMMO':'['+keyLabel('KeyR','R')+'] RELOAD'),rx0,ry0+gap+len+LH(14)*_wz);
'@

SubRx @'
var VER='22.91';
'@ @'
var VER='22.92';
'@

$pat = "(?m)^  now:'v22\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.92: On a 4K screen NO AMMO, JAMMED, the reload key and the reload seconds by the crosshair are now as big as the crosshair. Check 22.92 fails on v22.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
