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

# PILLAGERS FLANK WIDER AND TAKE COVER MORE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function meleeStrike(){
'@ @'
// 2026-10-12 (flankcover), HIS ANSWER 9 a: pillagers flank and use cover more. A lone pillager in a fight walked to a point 1.25 rad
// (72 degrees) off the line between you, so he mostly came at you from the front quarter; he now swings out to RAI_FLANK, 1.6 rad
// (92 degrees), so he arrives from your side. A man called to the fight by his crew keeps the station the crew gave him. While his
// gun cycles he looked for cover only inside 600 and only one step (95) away; he now looks out to RAI_COVER_D (900) and at two
// steps, 95 then 160, in the same eight directions, so a man trading shots at range breaks your line of sight between shots far
// more often. No draw on any stream: the cover search and the flank point are pure geometry.
var RAI_FLANK=1.6, RAI_COVER_D=900, RAI_COVER_R=[95,160];
function raiderFlankAng(e,pang){ return pang+((e.crewArc!==undefined)?e.crewArc:e.flank*RAI_FLANK); }
function raiderCoverSpot(e,p,d){
  var i, k, a, x, y, a0;
  if(!(d<RAI_COVER_D)) return null;
  a0=Math.atan2(e.y-p.y,e.x-p.x);
  for(k=0;k<RAI_COVER_R.length;k++){
    for(i=0;i<8;i++){
      a=a0+i*0.7854; x=e.x+Math.cos(a)*RAI_COVER_R[k]; y=e.y+Math.sin(a)*RAI_COVER_R[k];
      if(losClear(e.x,e.y,x,y,G.vseg)&&!losClear(p.x,p.y,x,y,G.vseg)) return {x:x,y:y};
    }
  }
  return null;
}
function meleeStrike(){
'@

SubRx @'
        var fang=pang+((e.crewArc!==undefined)?e.crewArc:e.flank*1.25);
'@ @'
        var fang=raiderFlankAng(e,pang);   // 2026-10-12 (flankcover): a lone man swings wider (RAI_FLANK)
'@

SubRx @'
          var _rcv=null;
          if(CFG.raiderCover!==0&&!e.merc&&d<600){
            for(var _rci=0;_rci<8;_rci++){
              var _rca=Math.atan2(e.y-p.y,e.x-p.x)+_rci*0.7854;
              var _rcx=e.x+Math.cos(_rca)*95,_rcy=e.y+Math.sin(_rca)*95;
              if(losClear(e.x,e.y,_rcx,_rcy,G.vseg)&&!losClear(p.x,p.y,_rcx,_rcy,G.vseg)){ _rcv={x:_rcx,y:_rcy}; break; }
            }
          }
'@ @'
          var _rcv=(CFG.raiderCover!==0&&!e.merc)?raiderCoverSpot(e,p,d):null;   // 2026-10-12 (flankcover): farther out, two rings
'@

SubRx @'
var VER='25.46';
'@ @'
var VER='25.47';
'@

$pat = "(?m)^  now:'v25\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.47: Pillagers now come at you from the side more and duck behind cover between shots even at long range. Check 25.47 fails on v25.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
