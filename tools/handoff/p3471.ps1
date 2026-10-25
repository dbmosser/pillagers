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

# RAID BACKPACK CLOSE BUTTON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var hh=LH(236)*BZ+rows*(TILE+GAP)
'@ @'
var hh=LH(242)*BZ+rows*(TILE+GAP)
'@

SubRx @'
var cy=y+LH(30)*BZ;
  ctx.font=bFS(TYPE.title);
'@ @'
var cy=y+LH(36)*BZ;   // v28.xx (cw-bagclose): the header is 6 px taller so the close button sits inside it
  ctx.font=bFS(TYPE.title);
'@

SubRx @'
  ctx.fillText(_bh,x+PW-11,cy); ctx.textAlign='left'; var _hdrB=cy+LH(8)*BZ;
'@ @'
  // v28.xx (cw-bagclose), his Q1 (2026-09-03): "Every menu screen gets a CLOSE button and ESC closes it". The raid backpack had ESC, Tab and B but no button. One 36 px ghost square in the card corner (the style guide close place: top right of the header, the close glyph, the pad B when the last input was a pad); a click does what ESC does (shuts the backpack and drops a held drag). The key hints end left of it.
  var _hintR=x+PW-11;
  if(state!=='hub'){
    var _cbS=Math.round(36*BZ), _cbP=Math.round(LH(6)*BZ), _cb={x:Math.round(G.bagPanel.x+G.bagPanel.w-_cbP-_cbS),y:Math.round(G.bagPanel.y+_cbP),w:_cbS,h:_cbS}, _cbH=inRect(_cb,mouse.x,mouse.y);
    G.bagClose=_cb; _hintR=Math.min(_hintR,_cb.x-Math.round(LH(12)*BZ));
    ctx.save();
    ctx.fillStyle=_cbH?'#232b35':'rgba(0,0,0,0)'; ctx.fillRect(_cb.x,_cb.y,_cb.w,_cb.h);
    ctx.strokeStyle=_cbH?'#efe9dc':'#3d444a'; ctx.lineWidth=1; ctx.strokeRect(_cb.x+.5,_cb.y+.5,_cb.w-1,_cb.h-1);
    if(padOn()){ ctx.font=bFS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#efe9dc'; ctx.fillText(padB('B'),_cb.x+_cb.w/2,_cb.y+_cb.h/2+LH(6)*BZ); }
    else { var _cbI=uiIconPath('close'), _cbZ=Math.round(18*BZ); if(_cbI){ ctx.translate(_cb.x+(_cb.w-_cbZ)/2,_cb.y+(_cb.h-_cbZ)/2); ctx.scale(_cbZ/24,_cbZ/24); ctx.lineWidth=2*24/_cbZ; ctx.lineCap='square'; ctx.strokeStyle=_cbH?'#efe9dc':'#aaa498'; ctx.stroke(_cbI); } }
    ctx.restore();
  } else G.bagClose=null;
  ctx.fillText(_bh,_hintR,cy); ctx.textAlign='left'; var _hdrB=cy+LH(8)*BZ;
'@

SubRx @'
  // PICK UP AN ITEM. Only while the inventory is open, and the drag is claimed
'@ @'
  // v28.xx (cw-bagclose), his Q1: the close button on the raid backpack does what ESC does there, shuts it and drops a held drag.
  if(e.button===0&&G&&!G.over&&G.bagOpen&&G.bagClose&&state!=='hub'&&inRect(G.bagClose,mouse.x,mouse.y)){ G.bagOpen=false; G.drag=null; return; }
  // PICK UP AN ITEM. Only while the inventory is open, and the drag is claimed
'@

SubRx @'
var VER='34.70';
'@ @'
var VER='34.71';
'@

$pat = "(?m)^  now:'v34\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.71: The raid backpack has a close button in its corner. Check 34.71 fails on v34.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
