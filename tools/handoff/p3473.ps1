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

# GUN KICK ON THE BODY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pxBob(ph,moving){
'@ @'
// v28.xx (cw-gunkick) I6: the body kick of one shot, in whole art pixels. 0 with no muzzle value or EFFECT INTENSITY off; 1 for most guns, 2 for the heavy ones (shotgun, magnum, sniper, dmr, lance); HALF intensity keeps 1. Render only, no random draw.
function pxKick(muzzle,wid){
  var f=(CFG.fxInt===undefined)?1:Math.max(0,Math.min(1,+CFG.fxInt||0)), b, n;
  if(!(muzzle>0)||f<=0) return 0;
  b=wid?gunBase(wid):''; n=(b==='shotgun'||b==='magnum'||b==='sniper'||b==='dmr'||b==='lance')?2:1;
  return Math.max(1,Math.round(n*f));
}
function pxBob(ph,moving){
'@

SubRx @'
ty=y+dyUp; pxd=x+lean+rx; px=pxd;
'@ @'
ty=y+dyUp; pxd=x+lean+rx-fl*(hold&&!dn&&!crouch?pxKick(muzzle,st.own&&st.own.wep&&st.own.wep.id):0); px=pxd; /* v28.xx (cw-gunkick) I6: the gun and shoulders jolt back 1 to 2 art px on a shot (muzzle reaches the linked window too) */
'@

SubRx @'
var VER='34.72';
'@ @'
var VER='34.73';
'@

$pat = "(?m)^  now:'v34\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.73: Firing jolts the pixel gun and shoulders back a pixel or two. Check 34.73 fails on v34.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
