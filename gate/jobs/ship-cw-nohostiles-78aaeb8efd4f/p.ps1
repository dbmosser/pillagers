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

# NO MORE HOSTILES CLOSING IN LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    {
      // count what is actually converging, because a number climbing while you
      // stand still is the tension the wait was missing
      var inbound=0;
      for(var qi=0;qi<G.ents.length;qi++){
        var qe=G.ents[qi];
        if(qe.state==='investigate'||qe.state==='chase'||qe.state==='alarm'){
          if(dist(qe,G.active)<1500) inbound++;
        }
      }
      if(inbound){
        ctx.font=hudFS(TYPE.label);
        ctx.fillStyle=inbound>4?'#ff5a4a':'#ffc04a';
        var _exH=inbound+(inbound===1?' HOSTILE':' HOSTILES')+' CLOSING IN';
        extRowPlate(_exH,W/2,_exRow,_exR,_exBW);   // v32.xx (cw-hostplate), cw-hostcol
        hudText(_exH,W/2,_exRow);   // v22.xx (tr8fixa): a caps callout under EXTRACT A INBOUND (INBOUND stays his word for the craft)
      }
    }
    ctx.textAlign='left';
'@ @'
    // v37.xx (cw-nohostiles), HIS ORDER (2026-11-02), with a picture of "14 hostiles closing in": "this message about 'hostiles closing in' is not helpful". The count line and its plate are gone; the extract banner above stays.
    ctx.textAlign='left';
'@

SubRx @'
// v32.xx (cw-hostplate), the critic on screen 37: the red "hostiles closing in" line under the countdown sat loose on the floor with no plate. It stands on the same flat HUD plate as the countdown, measured to its words.
function extRowPlate(s,x,y,R,minW){
  // v32.xx (cw-hostcol), the critic on screen 37: the plate was a narrower pill touching the banner. It takes the banner width (minW) and sits 8 px under it, one column.
  var w=Math.max(hudRawW(s)+LH(24)*R,minW||0), h=LH(22)*R, px=Math.round(x-w/2), py=Math.round(y-LH(16)*R);
  hudPanel(px,py,w,h,0.9,true);
  return {x:px,y:py,w:w,h:h};
}
'@ @'

'@

SubRx @'
var VER='37.40';
'@ @'
var VER='37.41';
'@

$pat = "(?m)^  now:'v37\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.41: the hostiles closing in line under the extract banner is gone Check 37.41 fails on v37.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
