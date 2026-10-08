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

# THE BELT TEXT GROWS WITH THE BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function FS(spec){
  var k=spec+'|'+uiScale(),hit=_fs[k];
'@ @'
// v18.71, SEEN ON THE 4K RAID SCREENSHOT (2026-10-07): THE BELT TEXT GROWS WITH THE BELT. The belt slots are sized by the room
// they have (up to LH(112)), but the key number, the count and the caption over them were the smallest HUD type, so at 4K a
// count was a speck in the corner of a big slot. They now take a share of the slot size, never smaller than before.
function beltFS(bw,k){ var f=FS(TYPE.micro), m=(/([\d.]+)px/).exec(f), n=m?parseFloat(m[1]):11, want=Math.round(bw*k); return (want>n)?f.replace((/([\d.]+)px/),want+'px'):f; }
function FS(spec){
  var k=spec+'|'+uiScale(),hit=_fs[k];
'@

SubRx @'
      ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(160,172,184,.8)';
      ctx.fillText(String(q+1),bx+LH(4),hy+LH(11));
'@ @'
      ctx.font=beltFS(bw,0.13); ctx.fillStyle='rgba(160,172,184,.8)';   // v18.71: grows with the slot
      ctx.fillText(String(q+1),bx+LH(4),hy+Math.max(LH(11),Math.round(bw*0.13)+LH(3)));
'@

SubRx @'
      if(S.count!==null&&S.count!==undefined){
        ctx.font=FS(TYPE.micro);
'@ @'
      if(S.count!==null&&S.count!==undefined){
        ctx.font=beltFS(bw,0.16);   // v18.71: grows with the slot
'@

SubRx @'
      ctx.font=FS(TYPE.micro); ctx.fillStyle='#8a96a1'; ctx.textAlign='center';
      ctx.fillText(sl[sel].name+'   [FIRE] use'+(padOn()?'':'    [V] signal'),W/2,hy-LH(6));   // v13.52: no pad button reaches V
'@ @'
      ctx.font=beltFS(bw,0.12); ctx.fillStyle='#8a96a1'; ctx.textAlign='center';   // v18.71: grows with the slots under it
      ctx.fillText(sl[sel].name+'   [FIRE] use'+(padOn()?'':'    ['+keyName(keysOf('KeyV'))+'] signal'),W/2,hy-LH(6));   // v13.52: no pad button reaches V; v18.71: the key as set
'@

SubRx @'
var VER='18.70';
'@ @'
var VER='18.71';
'@

$pat = "(?m)^  now:'v18\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.71: At 4K the numbers on the belt and the caption above it are readable. Check 18.71 fails on v18.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
