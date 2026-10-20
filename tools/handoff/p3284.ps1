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

# FLOOR BACKPACK CARDS ON A PAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
try{ G=hubBagG; drawBag(); drawBelt(); try{ beltHoverHud(); }catch(_bhv){} drawDragGhost(); }
'@ @'
try{ G=hubBagG; drawBag(); drawBelt(); try{ if(padOn()) BELTHOV.box=null; else beltHoverHud(); }catch(_bhv){} drawDragGhost(); }   // v32.xx (cw-bagpadcards): on a pad the floor backpack shows the focused cell's card only, never a belt card as well
'@

SubRx @'
  G.bagPanel={x:x,y:y,w:PW,h:hh};
'@ @'
  G.bagPanel={x:x,y:y,w:PW,h:hh}; G.bagCardBox=null; G.bagHead=null; G.bagFoot=null;   // v32.xx (cw-bagpadcards): the card, header row and footer hint boxes, recorded as drawn
'@

SubRx @'
  ctx.fillText(_bh,x+PW-11,cy); ctx.textAlign='left';
'@ @'
  ctx.fillText(_bh,x+PW-11,cy); ctx.textAlign='left'; var _hdrB=cy+LH(8)*BZ; G.bagHead={x:G.bagPanel.x,y:G.bagPanel.y,w:G.bagPanel.w,h:_hdrB-G.bagPanel.y+2};   // v32.xx (cw-bagpadcards): the header row, title to divider
'@

SubRx @'
    bagHintDraw((state==='hub')?(padOn()?padB('DPAD move   A pick up or place   Y drop   B close')
'@ @'
    G.bagFoot={x:x+11,y:_ry+LH(6)*BZ-LH(14)*BZ,w:PW-22,h:LH(18)*BZ*2};   // v32.xx (cw-bagpadcards): the footer hint row (room for two lines)
    bagHintDraw((state==='hub')?(padOn()?padB('DPAD move   A pick up or place   Y drop   B close')
'@

SubRx @'
        _gcX=(W-(x+PW)>=_gcFw+LH(16)*_gcRs)?(x+PW+LH(8)*_gcRs+_gcFw):(x+PW-11);
        gunCardDraw(gunCompare(_gcW,p.wep),_gcX,Math.round(y+LH(40)*BZ)+Math.round(msgPx(hudFS(TYPE.label))*15),1,'IN BACKPACK');
'@ @'
        // v32.xx (cw-bagpadcards), the o-10 pictures (2026-10-20): the card was placed by a guessed width (352 px) while it is 440 px wide, so it sat 86 px over the panel and covered "view to close". It is placed by its real size: beside the panel, top level with it; with no room beside, inside the panel's right edge below the header row and above the footer hint.
        var _gcCmp=gunCompare(_gcW,p.wep), _gcSz=gunCardSize(_gcCmp,'IN BACKPACK'), _gcBp=G.bagPanel, _gcM=Math.round(LH(8)*_gcRs), _gcT;
        _gcX=_gcBp.x+_gcBp.w+_gcM+_gcSz.w;
        if(_gcX<=W-_gcM) _gcT=Math.max(_gcM,Math.min(_gcBp.y,H-_gcM-_gcSz.h));
        else { _gcX=_gcBp.x+_gcBp.w-_gcM; _gcT=Math.round(_hdrB+_gcM); }
        gunCardDraw(_gcCmp,_gcX,_gcT+_gcSz.h,1,'IN BACKPACK');
        G.bagCardBox={x:_gcX-_gcSz.w,y:_gcT,w:_gcSz.w,h:_gcSz.h};
'@

SubRx @'
e.style.display=on?'block':'none';
'@ @'
// v32.xx (cw-bagpadcards): in the Undercroft the chip sits top centre, clear of the location title at the top left.
  try{ var _kh=(typeof state!=='undefined'&&state==='hub'); e.style.left=_kh?'50%':'10px'; e.style.transform=_kh?'translateX(-50%)':'none'; }catch(_kp){}
  e.style.display=on?'block':'none';
'@

SubRx @'
var VER='32.83';
'@ @'
var VER='32.84';
'@

$pat = "(?m)^  now:'v32\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.84: One item card beside the open floor backpack, clear of its header and hint row; the keyboard chip clear of the title. Check 32.84 fails on v32.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
