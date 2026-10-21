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

# THE PIXEL ROLE GEAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pxM(){ return new Uint8Array(PXB.W*PXB.H); }
'@ @'
// v33.82 (cw-pixrole), HIS ORDERS (2026-10-20 22:45 to 23:05) and his answer 73 (the role gear is worn on the body), job 86g ship 4: THE ROLE GEAR ON THE PIXEL BODY, ONE FIGURE CONSTANT, THE PEDDLER AND THE SURVIVOR.
// v33.82 (cw-pixrole):  The vector role gear was drawn for the 42 px figure; the pixel pillager is 54 px, so with the pixel look on figKS scales it by PIX_FIGK about the feet: the pauldron top (23.6 up) lands on
// v33.82 (cw-pixrole):  the pixel shoulder line (32 up) within 1 art px. figKS is the one place the figure scale comes from for the role gear; the aim dots take no build height on the pixel body (it has one build).
// v33.82 (cw-pixrole):  The peddler (brown coat, stubble) and the survivor (grey coat, head bandage, no pack) are pixel suits of the same rig.
var PIX_FIGK=1.35;
PXB_RAMP.peddler={coat:['#b08a5e','#7a5a3a','#54402a','#34281a'],trs:['#5a4a38','#3a3026','#2a231a','#1a150f'],gear:['#c4a070','#946e44','#664a2a','#42301c'],pack:['#a88458','#7a5a3a','#54402a','#34281a'],acc:'#e8c050'};
PXB_RAMP.survivor={coat:['#b4b0a2','#8a8578','#625e54','#3e3b34'],trs:['#7a766a','#56534a','#3c3a33','#26241f'],gear:['#a09c8e','#78746a','#54514a','#34322c'],pack:['#a09c8e','#78746a','#54514a','#34322c'],acc:'#d8d4c8'};
function pxM(){ return new Uint8Array(PXB.W*PXB.H); }
'@

SubRx @'
  if(oid&&oid!=='outnone'&&!PIX_OUTFIT[oid]) return null;
'@ @'
  if(oid==='outsurvivor') return {head:'short',skin:'tan',clothes:'survivor',bot:0};   // v33.82 (cw-pixrole): the survivor and the peddler wear their own pixel suits
  if(oid==='outpeddler') return {head:'short',skin:'fair',clothes:'peddler',bot:0};
  if(oid&&oid!=='outnone'&&!PIX_OUTFIT[oid]) return null;
'@

SubRx @'
    p.put(pxRR(pxM(),3,26,10,40,2),C.pack); p.put(pxRect(pxM(),4,27,9,29),C.gear); p.P(6,30,C.acc);
'@ @'
    if(cl!=='survivor'){ p.put(pxRR(pxM(),3,26,10,40,2),C.pack); p.put(pxRect(pxM(),4,27,9,29),C.gear); p.P(6,30,C.acc); }   // v33.82 (cw-pixrole): the survivor carries nothing
'@

SubRx @'
  if(o.tell&&bot){ p.P(11,11,E.brow); p.P(12,11,E.brow); p.P(24,11,E.brow); p.P(23,11,E.brow); }
'@ @'
  if(o.tell&&bot){ p.P(11,11,E.brow); p.P(12,11,E.brow); p.P(24,11,E.brow); p.P(23,11,E.brow); }
  if(cl==='survivor'){ for(x=10;x<=25;x++){ p.P(x,6,'#d8d4c8'); p.P(x,7,'#b4b0a2'); } p.P(14,6,'#b02a1e'); p.P(15,6,'#b02a1e'); p.P(15,7,'#8a1c14'); }   // v33.82 (cw-pixrole): the head bandage
  if(cl==='peddler'){ for(x=12;x<=23;x++) p.P(x,17,sk[2]); p.P(14,16,sk[2]); p.P(21,16,sk[2]); }   // and the stubble
'@

SubRx @'
function drawRoleMark(e){
'@ @'
function figKS(b){ var k; if(pixOn()) return [PIX_FIGK,PIX_FIGK]; k=figBuildK(b); return [FIG_SCALE*k[0],FIG_SCALE*k[1]]; }   // v33.82 (cw-pixrole): the figure scale of the role gear, one place
function drawRoleMark(e){
'@

SubRx @'
  var k=figBuildK(e&&e.build);   // v32.64 (cw-figlook): the role mark rides the shoulders, so it is scaled with the body
'@ @'
  var k=figKS(e&&e.build);   // v32.64 (cw-figlook): the role mark rides the shoulders, so it is scaled with the body; v33.82 (cw-pixrole): by the pixel figure on the pixel body
'@

SubRx @'
wc.scale(FIG_SCALE*k[0],FIG_SCALE*k[1]); wc.translate(-e.x,-e.y);
'@ @'
wc.scale(k[0],k[1]); wc.translate(-e.x,-e.y);
'@

SubRx @'
fk=(bld===null)?[1,1]:figBuildK(bld||'lean')
'@ @'
fk=(bld===null||pixOn())?[1,1]:figBuildK(bld||'lean')
'@

SubRx @'
var VER='33.83';
'@ @'
var VER='33.84';
'@

$pat = "(?m)^  now:'v33\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.84: With the pixel look on, role gear sits on the pixel shoulders, the aim dots start on the pixel gun, and the peddler and the survivor are pixel figures. Check 33.84 fails on v33.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
