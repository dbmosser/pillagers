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

# THREE BODIES THAT READ (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function torsoPathPC(b,cx,ty,jh){
  if(b==='broad') buildPath(cx,ty,BUILD_BROAD,0);
  else if(b==='curved') buildPath(cx,ty,jh?BUILD_CPT:BUILD_CURVED,0);
  else { wc.beginPath(); if(HAS_RR) wc.roundRect(cx-6.5,ty-22,13,11,3); else wc.rect(cx-6.5,ty-22,13,11); }
}
'@ @'
function torsoPathPC(b,cx,ty,jh){
  if(b==='broad') buildPath(cx,ty,BUILD_BROAD,0);
  else if(b==='curved') buildPath(cx,ty,jh?BUILD_CPT:BUILD_CURVED,0);
  else { wc.beginPath(); if(HAS_RR) wc.roundRect(cx-5.6,ty-22,11.2,11,3); else wc.rect(cx-5.6,ty-22,11.2,11);   /* v23.xx (spr16): Lean is slimmer */ }
}
'@

SubRx @'
                   :{w:9.4,y:-20.2,h:6.8,sx:-4.4,sx2:2.8,sw:1.6,pw:2.6,py:-16.6,ph:3,by:-13.0,bh:1.4};
'@ @'
                   :{w:8.2,y:-20.2,h:6.8,sx:-3.9,sx2:2.5,sw:1.4,pw:2.3,py:-16.6,ph:3,by:-13.0,bh:1.4};   // v23.xx (spr16): cut to the slimmer Lean torso
'@

SubRx @'
  wc.fillStyle=INK;
  rrF(x-6.9+swing2*.5,ty-11.6,5.8,7.9-liftB*.5,1.5);
'@ @'
  // v23.xx (spr16), HIS ORDER (2026-10-12) "make them all look better" and answer 24 "b" (silhouettes for readability first):
  // THREE BODIES THAT READ. At raid size Lean and Broad were the same person. Broad now stands on wider legs and bigger boots (the
  // whole leg block, trousers, boots, soles and toe caps, is drawn 1.2 times as wide about the body's centre, so the feet still land
  // on the same line) with a thicker arm on the gun; Lean wears the plate carrier on a slimmer torso (11 wide, was 13) with a
  // slimmer arm. Curved keeps her outline, her rig cut to it (v23.xx spr15) and her jiggle. Cosmetic only: nothing a fight reads.
  var _LSX=(_BLD==='broad')?1.2:1;
  if(_LSX!==1){ wc.save(); wc.translate(x,0); wc.scale(_LSX,1); wc.translate(-x,0); }
  wc.fillStyle=INK;
  rrF(x-6.9+swing2*.5,ty-11.6,5.8,7.9-liftB*.5,1.5);
'@

SubRx @'
    wc.fillStyle=litHex(_BT[1],.30); wc.fillRect(x+1.1+swing+_toe,ty-4.2-liftA,2.2,1.0);
  }
'@ @'
    wc.fillStyle=litHex(_BT[1],.30); wc.fillRect(x+1.1+swing+_toe,ty-4.2-liftA,2.2,1.0);
  }
  if(_LSX!==1) wc.restore();   // v23.xx (spr16): end of the Broad legs
'@

SubRx @'
  wc.fillStyle=INK; rrF(x-7.5+leanX,ty-23,15,13,4);
  wc.fillStyle=cc; rrF(x-6.5+leanX,ty-22,13,11,3);
'@ @'
  if(_PC){ wc.fillStyle=INK; rrF(x-6.6+leanX,ty-23,13.2,13,4); wc.fillStyle=cc; rrF(x-5.6+leanX,ty-22,11.2,11,3); }   // v23.xx (spr16): Lean is slimmer
  else {
  wc.fillStyle=INK; rrF(x-7.5+leanX,ty-23,15,13,4);
  wc.fillStyle=cc; rrF(x-6.5+leanX,ty-22,13,11,3);
  }
'@

SubRx @'
    if(_BLD){ buildPath(x+leanX,ty,(_BLD==='broad')?BUILD_BROAD:BUILD_CURVED,0); wc.fill(); } else wc.fillRect(x-6.5+leanX,ty-22,13,11);
'@ @'
    if(_BLD){ buildPath(x+leanX,ty,(_BLD==='broad')?BUILD_BROAD:BUILD_CURVED,0); wc.fill(); } else if(_PC) wc.fillRect(x-5.6+leanX,ty-22,11.2,11); else wc.fillRect(x-6.5+leanX,ty-22,13,11);
'@

SubRx @'
  wc.fillStyle=coat; if(_BLD==='broad') wc.fillRect(1+ext,-2.9,6,5.8); else if(_BLD==='curved') wc.fillRect(1+ext,-2.0,6,4.0); else wc.fillRect(1+ext,-2.4,6,4.8);
'@ @'
  wc.fillStyle=coat; if(_BLD==='broad') wc.fillRect(1+ext,-3.3,6,6.6); else if(_BLD==='curved') wc.fillRect(1+ext,-2.0,6,4.0); else if(_PC) wc.fillRect(1+ext,-2.1,6,4.2); else wc.fillRect(1+ext,-2.4,6,4.8);   /* v23.xx (spr16): Broad thicker, Lean slimmer */
'@

SubRx @'
var _ah=(_BLD==='broad')?2.9:(_BLD==='curved'?2.0:2.4);
'@ @'
var _ah=(_BLD==='broad')?3.3:(_BLD==='curved'?2.0:2.1);
'@

SubRx @'
var VER='24.15';
'@ @'
var VER='24.16';
'@

$pat = "(?m)^  now:'v24\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.16: Lean, Broad and Curved now look like three different bodies at raid size. Check 24.16 fails on v24.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
