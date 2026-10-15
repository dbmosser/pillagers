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

# PLAYER 2 SEES THE MENDER BEAMS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function affixMend(e){
'@ @'
function affixMendSeen(e){   // v28.34 (cloud-coop-mender-beams-seen), CLOUD HUNT 2026-10-15: a linked window runs no AI, so it finds what the host mender is mending with the same rule, and heals nothing
  var i, o, out=[];
  if(!e||!(e.hp>0)||e.downed||e.finished||!G||!G.ents) return out;
  for(i=0;i<G.ents.length;i++){
    o=G.ents[i];
    if(o===e||o.boss||o.name===BOSS_NAME||o.kind==='raider'||o.kind==='peddler'||o.kind==='stray'||o.neutral||o.downed||o.finished||!(o.hp>0)||!(o.hp<o.maxhp)) continue;
    if(dist(o,e)>AFFIX_MEND_R) continue;
    out.push(o); if(out.length>=4) break;
  }
  return out;
}
function affixMend(e){
'@

SubRx @'
    if(k==='mend'&&e.mendFx>0&&e.mendTo){
'@ @'
    mt=(k!=='mend')?null:(typeof NET==='object'&&NET.on&&netEntsPeer())?((((G.t||0)%0.5)<0.4)?affixMendSeen(e):null):((e.mendFx>0)?e.mendTo:null);   // v28.34 (cloud-coop-mender-beams-seen), CLOUD HUNT 2026-10-15: player 2 window draws the beams too (the kill it first tell), on the host rhythm of 0.4 s in every 0.5 s
    if(mt&&mt.length){
'@

SubRx @'
      for(j=0;j<e.mendTo.length;j++){ o=e.mendTo[j]; wc.beginPath(); wc.moveTo(e.x,e.y-e.r*0.8); wc.lineTo(o.x,o.y-8); wc.stroke(); }
'@ @'
      for(j=0;j<mt.length;j++){ o=mt[j]; wc.beginPath(); wc.moveTo(e.x,e.y-e.r*0.8); wc.lineTo(o.x,o.y-8); wc.stroke(); }
'@

SubRx @'
  var A=AFFIX[e.affix], k=e.affix, x=e.x, y=e.y-spriteTop(e)-12, fl=(Math.cos(e.face)<0)?-1:1, f, j, aa, rr, cx, pts, o;
'@ @'
  var A=AFFIX[e.affix], k=e.affix, x=e.x, y=e.y-spriteTop(e)-12, fl=(Math.cos(e.face)<0)?-1:1, f, j, aa, rr, cx, pts, o, mt;
'@

SubRx @'
var VER='28.33';
'@ @'
var VER='28.34';
'@

$pat = "(?m)^  now:'v28\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.34: In co-op, player 2 now sees the green mender beams too, so he knows which machine to kill first. Check 28.34 fails on v28.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
