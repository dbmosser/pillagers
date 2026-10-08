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

# BARE LEGGED OUTFITS WEAR SHORTS ON CURVED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawBuildTorso(b,cx,ty,cc,cHi,cLo,trs,jc,jh,lx,lA,lB){
'@ @'
function drawBuildTorso(b,cx,ty,cc,cHi,cLo,trs,jc,jh,lx,lA,lB,legc){   // v20.06: trs fills the hips, legc the legs below them
'@

SubRx @'
  if(b==='curved'){ wc.fillStyle=trs; wc.fillRect(lx-6.3+lB,ty-10.9,4.6,2.2); wc.fillRect(lx+1.7+lA,ty-10.9,4.6,2.2); }
'@ @'
  if(b==='curved'){ wc.fillStyle=legc||trs; wc.fillRect(lx-6.3+lB,ty-10.9,4.6,2.2); wc.fillRect(lx+1.7+lA,ty-10.9,4.6,2.2); }
'@

SubRx @'
drawBuildTorso(_BLD,x+leanX,ty,cc,cHi,cLo,_TRS,_JG.c,_JG.h,x,swing*.5,swing2*.5);
'@ @'
drawBuildTorso(_BLD,x+leanX,ty,cc,cHi,cLo,(OUTF&&!OUTF.trs)?darkHex(cc,.62):_TRS,_JG.c,_JG.h,x,swing*.5,swing2*.5,_TRS);   /* v20.06: a bare-legged suit wears shorts on the hips */
'@

SubRx @'
var VER='20.05';
'@ @'
var VER='20.06';
'@

$pat = "(?m)^  now:'v20\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.06: The Baller and the Tomb Explorer wear shorts on a Curved body. Check 20.06 fails on v20.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
