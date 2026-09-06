$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS NOTE, 2026-09-05 in-run at 130 s: "when lightning is about to hit, it
# should say like 'lightning incoming' at the circle." The warning ring
# (v6.87, on the ground since v11.35) closes as the strike nears and says
# nothing. It carries his words now, with the seconds left, above the ring.

# 1. THE WORDS, in one place, beside the strike code.
SubRx @'
var STRIKE_WARN=1.6, STRIKE_R=118, STRIKE_DMG=62;
function strikeTick(dt){
'@ @'
var STRIKE_WARN=1.6, STRIKE_R=118, STRIKE_DMG=62;
// v11.57, HIS NOTE: what the warning ring says, in his words, with the
// seconds left. One place, so the draw and the check read the same line.
function strikeLabel(S){
  return 'LIGHTNING INCOMING '+Math.max(1,Math.ceil((S&&S.t)||0))+'S';
}
function strikeTick(dt){
'@

# 2. DRAWN AT THE CIRCLE, above the ring, in world space with the ring.
SubRx @'
      wc.beginPath(); wc.arc(_S.x,_S.y,STRIKE_R*(1-_k*0.86),0,6.2832); wc.stroke();
      if(_k>0.55){
'@ @'
      wc.beginPath(); wc.arc(_S.x,_S.y,STRIKE_R*(1-_k*0.86),0,6.2832); wc.stroke();
      // v11.57, HIS NOTE: "it should say like 'lightning incoming' at the circle".
      var _slt=strikeLabel(_S);
      wc.font=FS(TYPE.label); wc.textAlign='center';
      var _slw=wc.measureText(_slt).width;
      wc.fillStyle='rgba(6,9,13,.72)';
      wc.fillRect(_S.x-_slw/2-6,_S.y-STRIKE_R-LH(26),_slw+12,LH(15));
      wc.fillStyle='rgba(190,210,255,'+(0.55+0.45*_k).toFixed(3)+')';
      wc.fillText(_slt,_S.x,_S.y-STRIKE_R-LH(15));
      wc.textAlign='left';
      if(_k>0.55){
'@

# STAMPS.
SubRx @'
var VER='11.56';
'@ @'
var VER='11.57';
'@
SubRx @'
var WHATSNEW_VER='11.56';
'@ @'
var WHATSNEW_VER='11.57';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE STORM WARNING RING SAYS LIGHTNING INCOMING, with the seconds left, right at the circle.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.56:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.56 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.56:[^']*'",{ param($m) "now:'v11.57: HIS NOTE of 2026-09-05, the strike warning should say lightning incoming at the circle. strikeLabel(S) owns his line with the seconds left and render2D draws it above the closing ring in world space. Check 11.57 reads the label at 1.6 s and at 0.3 s and requires his words and the rounded seconds, and controls that render2D reads strikeLabel.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
