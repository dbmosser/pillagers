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

# What is new card: scrim, a 720px flat panel, left title, one Got it (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
wnW=Math.min(_wnWW-LH(60),LH(1000));
'@ @'
wnW=Math.min(_wnWW-LH(60),LH(460));   // v28.xx (cw-wnew40) critic on screen 40 (2 of 5): "1560px slab". The card is a 720px card now (the style guide: a modal never exceeds its content).
'@

SubRx @'
var wnX=_wnWW/2-wnW/2, wnY=_wnHH/2-wnH/2-LH(10);
'@ @'
wnH+=LH(34);   // v28.xx (cw-wnew40): room for the footer row (Got it)
    var wnX=_wnWW/2-wnW/2, wnY=_wnHH/2-wnH/2-LH(10);
'@

SubRx @'
hudPanel(wnX,wnY,wnW,wnH,1);
'@ @'
// v28.xx (cw-wnew40) critic on screen 40: "no scrim, so station labels, the weapon bar and a toast fight it". Scrim first, then a flat panel (1px line-hi, no chamfer, no tick).
    ctx.fillStyle=UIC.ui_scrim; ctx.fillRect(0,0,_wnWW,_wnHH);
    ctx.fillStyle=UIC.ui_panel; ctx.fillRect(wnX,wnY,wnW,wnH);
    ctx.strokeStyle=UIC.ui_line_hi; ctx.lineWidth=1; ctx.strokeRect(wnX+0.5,wnY+0.5,wnW-1,wnH-1);
'@

SubRx @'
ctx.fillText('NEW IN '+verShown(WHATSNEW_VER,1),_wnWW/2,wnY+LH(32));
'@ @'
// v28.xx (cw-wnew40): "centred amber title": the title sits top-left in tx-1 over a rule (amber is for the one primary).
    ctx.textAlign='left'; ctx.fillStyle=UIC.tx_1;
    ctx.fillText('NEW IN '+verShown(WHATSNEW_VER,1),wnX+LH(22),wnY+LH(32));
    ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(wnX+LH(22),wnY+LH(44),wnW-LH(44),1);
'@

SubRx @'
ctx.font=FS(TYPE[wnRole]); ctx.fillStyle='#cdd6dd';
'@ @'
ctx.font=FS(TYPE[wnRole]); ctx.fillStyle=UIC.tx_1;
'@

SubRx @'
ctx.fillText((PAD&&PAD.on)?'walk to dismiss':'press ENTER or walk to dismiss',_wnWW/2,wnY+wnH-LH(12));
'@ @'
// v28.xx (cw-wnew40): "no close or primary": the one amber primary (Got it) sits bottom-right, the dismiss hint bottom-left at label size.
    var _gbW=LH(104), _gbH=LH(36), _gbX=wnX+wnW-LH(22)-_gbW, _gbY=wnY+wnH-LH(18)-_gbH;
    ctx.fillStyle=UIC.acc; ctx.fillRect(_gbX,_gbY,_gbW,_gbH);
    ctx.textAlign='center'; ctx.font=FS(TYPE.label); ctx.fillStyle=UIC.acc_ink;
    ctx.fillText('Got it',_gbX+_gbW/2,_gbY+_gbH*0.68);
    ctx.textAlign='left'; ctx.fillStyle=UIC.tx_2;
    ctx.fillText((PAD&&PAD.on)?'walk to dismiss':'press ENTER or walk to dismiss',wnX+LH(22),_gbY+_gbH*0.68);
'@

SubRx @'
var VER='29.89';
'@ @'
var VER='29.90';
'@

$pat = "(?m)^  now:'v29\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.90: What is new card: cleaner layout and a Got it button. Check 29.90 fails on v29.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
