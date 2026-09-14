$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# 2026-09-13 AUDIT ITEM 5: A CONTROLLER CANNOT TRADE WITH THE PEDDLER. The stall rows are
# the number keys, which no pad button reaches, and its [X] walk away named the pad X
# button, which holds E for a poll the stall never reads, so X did not close it either.
# While the stall is open the D-pad now moves a marker over the rows, A takes the marked
# row and X walks away, all on the press, and the panel draws the marker and names them.
SubRx @'
  if(state!=='raid'||!G){ padRelease(); return; }
'@ @'
  if(state!=='raid'||!G){ padRelease(); return; }
  // v13.49, audit item 5: THE PEDDLER ON A PAD. While the stall is open it owns the pad:
  // the D-pad moves a marker over its rows (sell the backpack, then his stock), A takes
  // the marked row through the same number key the keyboard uses, and X walks away, the
  // button the stall prompt names. Nothing else on the pad acts behind the panel.
  if(G.trade&&!G.over){
    var _pn=((G.trade.stock&&G.trade.stock.length)||0)+1;
    if(_pn>9) _pn=9;
    G.pedSel=clamp(G.pedSel||0,0,_pn-1);
    if(pressed(12)&&!PAD.prev[12]) G.pedSel=(G.pedSel-1+_pn)%_pn;
    if(pressed(13)&&!PAD.prev[13]) G.pedSel=(G.pedSel+1)%_pn;
    if(pressed(0)&&!PAD.prev[0]){ var _pk='Digit'+(G.pedSel+1); raidKey(_pk,false,null); keys[_pk]=false; }
    if(pressed(2)&&!PAD.prev[2]){ raidKey('KeyE',false,null); keys['KeyE']=false; G.pedSel=0; }
    for(var _tb=0;_tb<bt.length;_tb++) PAD.prev[_tb]=pressed(_tb);
    return;
  }
'@
SubRx @'
  ctx.fillText('['+keyLabel('KeyE','E')+'] walk away',x+PW-14,cy); ctx.textAlign='left';
'@ @'
  ctx.fillText((padOn()?'[D-PAD] choose  [A] take  ':'')+'['+keyLabel('KeyE','E')+'] walk away',x+PW-14,cy); ctx.textAlign='left';   // v13.49
'@
SubRx @'
  ctx.fillText('[1]  SELL BACKPACK  ('+n+')',x+14,cy);
'@ @'
  ctx.fillText((padOn()?(((G.pedSel||0)===0)?'[A]':'   '):'[1]')+'  SELL BACKPACK  ('+n+')',x+14,cy);   // v13.49: the pad marker
'@
SubRx @'
    ctx.fillText('['+(i+2)+']  '+(S.sold?'sold':IT.name),x+LH(38),cy);
'@ @'
    ctx.fillText((padOn()?(((G.pedSel||0)===i+1)?'[A]  ':'     '):('['+(i+2)+']  '))+(S.sold?'sold':IT.name),x+LH(38),cy);   // v13.49: the pad marker
'@
SubRx @'
var VER='13.48';
'@ @'
var VER='13.49';
'@

$pat = "(?m)^  now:'v13\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.49: A CONTROLLER CAN TRADE WITH THE PEDDLER. Audit item 5 of 2026-09-13: the stall rows are the number keys, which no pad button reaches, and its [X] walk away named the pad X button, which holds E for a poll the stall never reads. While the stall is open the D-pad now moves a marker over the rows, A takes the marked row through the same number key the keyboard uses, and X walks away, and the panel draws the marker and names the buttons on a pad. Check 13.49 fakes a pad at an open stall and requires D-pad down to move the marker, A to buy the marked item, and X to close the stall, with the keyboard 3 still buying as the control; it fails on v13.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
