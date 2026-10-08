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

# THE EXTRACTION LINES GROW AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _exRow=_exBelt-LH(26);   // the arrow, the distance, the converging count
  var _exBan=_exBelt-LH(48);   // the headline above it
'@ @'
  // v19.54, seen on the 4K ring screenshot (2026-10-08): these lines kept their 1080p size and spacing at 4K while the belt under them
  // grew, so HOLD E TO CALL FOR EXTRACTION and the inbound banner were small print. Their words and their gaps grow with the screen.
  var _exR=Math.max(1,(typeof hudRes==='function')?hudRes():1);
  var _exRow=_exBelt-LH(26)*_exR;   // the arrow, the distance, the converging count
  var _exBan=_exBelt-LH(48)*_exR;   // the headline above it
'@

SubRx @'
    var _exL=extLetter(G.active);
    ctx.font=FS(TYPE.head); ctx.textAlign='center';
'@ @'
    var _exL=extLetter(G.active);
    ctx.font=hudFS(TYPE.head); ctx.textAlign='center';
'@

SubRx @'
      ctx.save(); ctx.translate(W/2-28,_exRow-LH(4)); ctx.rotate(_ea+Math.PI/2);
'@ @'
      ctx.save(); ctx.translate(W/2-28*_exR,_exRow-LH(4)*_exR); ctx.rotate(_ea+Math.PI/2); ctx.scale(_exR,_exR);
'@

SubRx @'
      ctx.font=FS(TYPE.label); ctx.fillStyle='#ffc04a';
      ctx.fillText(metres(_ed)+'m',W/2+14,_exRow);
'@ @'
      ctx.font=hudFS(TYPE.label); ctx.fillStyle='#ffc04a';
      ctx.fillText(metres(_ed)+'m',W/2+14*_exR,_exRow);
'@

SubRx @'
        ctx.font=FS(TYPE.label);
        ctx.fillStyle=inbound>4?'#ff5a4a':'#ffc04a';
'@ @'
        ctx.font=hudFS(TYPE.label);
        ctx.fillStyle=inbound>4?'#ff5a4a':'#ffc04a';
'@

SubRx @'
    ctx.font=FS(TYPE.head); ctx.textAlign='center';
    ctx.fillStyle='#4de3d0'; ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CALL FOR EXTRACTION',W/2,_exRow);
'@ @'
    ctx.font=hudFS(TYPE.head); ctx.textAlign='center';
    ctx.fillStyle='#4de3d0'; ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CALL FOR EXTRACTION',W/2,_exRow);
'@

SubRx @'
    if(G.active.callT>0) bar(W/2-70,_exRow+LH(5),140,7,
'@ @'
    if(G.active.callT>0) bar(W/2-70*_exR,_exRow+LH(5)*_exR,140*_exR,7*_exR,
'@

SubRx @'
y=Math.min(y,Math.round(by-LH(48)-LH(34)-h));
'@ @'
y=Math.min(y,Math.round(by-(LH(48)+LH(34))*Math.max(1,hudRes())-h));
'@

SubRx @'
var VER='19.53';
'@ @'
var VER='19.54';
'@

$pat = "(?m)^  now:'v19\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.54: At 4K the extraction call and countdown are big enough to read at a glance. Check 19.54 fails on v19.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
