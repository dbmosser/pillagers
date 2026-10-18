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

# RUN INFO PANEL ON THE SHARED PALETTE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
rows.push({k:'CONTRACTS',v:'',c:'#ffc04a'});
'@ @'
rows.push({k:'CONTRACTS',v:'',c:UIC.acc});   // v28.xx (cw-runinfopal), UI step 4 (style guide: one palette): the run info panel used five off-palette colours (#ffc04a, #c9b27a, #cdd6dd, #8a96a1, #7fc4a0); it now reads UIC: accent headings, tx_1 rows, tx_2 chevron, ok and danger for notes.
'@

SubRx @'
rows.push({k:'RUN GOALS',v:'',c:'#ffc04a'});
'@ @'
rows.push({k:'RUN GOALS',v:'',c:UIC.acc});
'@

SubRx @'
_clines.push({v:_live[_cs].txt,vc:'#c9b27a'});
'@ @'
_clines.push({v:_live[_cs].txt,vc:UIC.tx_1});
'@

SubRx @'
vc:_gl.done?'#7fc4a0':'#cdd6dd'});
'@ @'
vc:_gl.done?UIC.ok:UIC.tx_1});
'@

SubRx @'
ctx.fillStyle='#ffc04a'; ctx.fillText('RUN INFO',bx+pad,ry);
'@ @'
ctx.fillStyle=UIC.acc; ctx.fillText('RUN INFO',bx+pad,ry);
'@

SubRx @'
ctx.textAlign='right'; ctx.fillStyle='#8a96a1';
    hudChev(bx+bw-pad,ry,!HOc.c);
'@ @'
ctx.textAlign='right'; ctx.fillStyle=UIC.tx_2;
    hudChev(bx+bw-pad,ry,!HOc.c);
'@

SubRx @'
ctx.fillStyle=R2.vc||'#8a96a1';
'@ @'
ctx.fillStyle=R2.vc||UIC.tx_2;
'@

SubRx @'
vc:lost?'#c0503a':'#7fc4a0'});
'@ @'
vc:lost?UIC.danger:UIC.ok});
'@

SubRx @'
var VER='29.60';
'@ @'
var VER='29.61';
'@

$pat = "(?m)^  now:'v29\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.61: Run info panel uses the same colors as the menus. Check 29.61 fails on v29.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
