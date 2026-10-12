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

# GUN STAT CARD IN THE BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        ),x+11,_ry+LH(3)*BZ);
'@ @'
        ),x+11,_ry+LH(3)*BZ);
    // v23.xx (feat2c), HIS #17 and his answer 34 (2026-10-12): THE STAT CARD IN THE BACKPACK. A gun under the mouse (keyboard and
    // mouse first), or else the selected stack when it is a gun (the arrows and the pad D-pad move it), shows the same card as the
    // pickup (gunCardDraw) against the gun in his hands: beside the panel on the right when there is room, else inside its right edge.
    // The rows of itemRows on the left are unchanged. The Undercroft draws this panel too, so the floor backpack has the card as well.
    try{
      var _gcK=null, _gcI, _gcC, _gcIt, _gcW, _gcRs=Math.max(1,hudRes()), _gcFw=Math.round(msgPx(hudFS(TYPE.label))*18), _gcX;
      if(!(PAD&&PAD.on)&&G.bagCells) for(_gcI=0;_gcI<G.bagCells.length;_gcI++){ _gcC=G.bagCells[_gcI];
        if(mouse.x>=_gcC.x&&mouse.x<=_gcC.x+_gcC.w&&mouse.y>=_gcC.y&&mouse.y<=_gcC.y+_gcC.h){ if(ITEMS[_gcC.key]&&ITEMS[_gcC.key].use==='gun') _gcK=_gcC.key; break; } }
      if(!_gcK&&isGun) _gcK=sst.key;
      _gcIt=_gcK&&ITEMS[_gcK];
      if(_gcIt&&_gcIt.gk&&WEAPONS[_gcIt.gk]){
        _gcW=(typeof gunQPeek==='function'&&gunQPeek(_gcIt.gk))||WEAPONS[_gcIt.gk];
        _gcX=(W-(x+PW)>=_gcFw+LH(16)*_gcRs)?(x+PW+LH(8)*_gcRs+_gcFw):(x+PW-11);
        gunCardDraw(gunCompare(_gcW,p.wep),_gcX,Math.round(y+LH(40)*BZ)+Math.round(msgPx(hudFS(TYPE.label))*15),1,'IN BACKPACK');
      }
    }catch(_gcE){}
'@

SubRx @'
var VER='23.79';
'@ @'
var VER='23.80';
'@

$pat = "(?m)^  now:'v23\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.80: The backpack now shows a gun stat card for the gun under the mouse or the selected gun. Check 23.80 fails on v23.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
