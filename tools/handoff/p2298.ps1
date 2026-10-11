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

# LABEL PLATES FIT THEIR TEXT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function label(x,y,txt,col,delay,big,ik){
'@ @'
// v22.xx, the raid text rewrite (R47): LABEL PLATES FIT THEIR TEXT. HIS ORDER (2026-10-09): the raid text reads like a shooter HUD, and
// every word sits on a plate that fits it. The floating labels (loot found, targets down, WEAK SPOT) sat on a plate a fixed 13 units
// tall, laid 10 above the baseline, while a loot name is set in TYPE.label at about 18 units: the plate covered the lower two thirds
// of the letters and the caps stuck out of its top. The plate is now as tall as the letters (their measured ascent and descent, never
// less than the font's caps and descender share) with a padding grown with the font, as the Undercroft names have been since v18.63;
// the item icon grows to the plate. The step between labels stacked over one crate follows the same height (labelPlateH), so a stack
// of loot names no longer overlaps its own plates. A stacked column grows a little taller.
function labelPlateH(px){ px=(px>0)?px:13; return Math.round(px*0.74+px*0.2+2*Math.max(3,px*0.18)); }
function label(x,y,txt,col,delay,big,ik){
'@

SubRx @'
    myW=wc.measureText(txt).width+(ik?LH(26):0);
    wc.restore();
  }catch(_lm){}
'@ @'
    myW=wc.measureText(txt).width+(ik?LH(26):0);
    wc.restore();
  }catch(_lm){}
  var _lph=labelPlateH(msgPx(FS(big?TYPE.label:TYPE.micro)));   // v22.xx (R47): the plate this label is drawn on
  LBL_STEP=Math.max(LBL_STEP,_lph+2);
'@

SubRx @'
      if(Math.abs(o.x-x)<gap&&Math.abs(oy-ny)<13){ clash=true; break; }
'@ @'
      if(Math.abs(o.x-x)<gap&&Math.abs(oy-ny)<Math.max(13,_lph)){ clash=true; break; }
'@

SubRx @'
    var icw=lb.ik?15:0;
    wc.fillStyle='rgba(6,9,13,.55)';
    var lw=wc.measureText(lb.txt).width;
    wc.fillRect(lb.x-lw/2-4-icw,lb.y-rise-10,lw+8+icw,13);
    if(lb.ik) drawItemIcon(wc,lb.ik,lb.x-lw/2-icw+3,lb.y-rise-4,13);
'@ @'
    // v22.xx (R47): the plate is as tall as the letters, from their measured box, and the icon grows with it
    var _lbm=wc.measureText(lb.txt), lw=_lbm.width, _lbp=msgPx(wc.font);
    var _lba=Math.max(_lbm.actualBoundingBoxAscent||0,_lbp*0.74), _lbd=Math.max(_lbm.actualBoundingBoxDescent||0,_lbp*0.2), _lbq=Math.max(3,_lbp*0.18), _lbh=_lba+_lbd+_lbq*2, _lbt=lb.y-rise-_lba-_lbq;
    var _lbs=Math.max(13,Math.round(_lbh-4)), icw=lb.ik?_lbs+2:0;
    wc.fillStyle='rgba(6,9,13,.55)';
    wc.fillRect(lb.x-lw/2-4-icw,_lbt,lw+8+icw,_lbh);
    if(lb.ik) drawItemIcon(wc,lb.ik,lb.x-lw/2-icw/2-2,_lbt+_lbh/2,_lbs);
'@

SubRx @'
var VER='22.97';
'@ @'
var VER='22.98';
'@

$pat = "(?m)^  now:'v22\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.98: Loot names and callouts over the world now sit on a dark plate that fits the whole word. Check 22.98 fails on v22.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
