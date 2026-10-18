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

# THE DOWNED TIMER GETS ITS OWN CENTRED ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _barY=_dy+Math.round(_hH*0.42);

'@ @'
    var _tmY=_dy+Math.round(_hH*1.05), _barY=_dy+Math.round(_hH*0.42)+Math.round(_hH*1.05);   // v28.xx (cw-downplate2): the timer has its own row under the word down, centred

'@

SubRx @'
ctx.textAlign='left';   // v28.xx (cw-downplate): the timer is the hero, as big as the word down
'@ @'
ctx.textAlign='center';   // v28.xx (cw-downplate2): one centred column (critic on screen 34: the timer was pushed to the plate edge)
'@

SubRx @'
ctx.fillText(Math.max(0,p.downT).toFixed(2)+'s',W/2+110,_barY+9); ctx.textAlign='center';
'@ @'
ctx.fillText(Math.max(0,p.downT).toFixed(2)+'s',W/2,_tmY);
'@

SubRx @'
rowY=dy+Math.round(hH*0.42)+10+Math.round(hD*1.15);
'@ @'
rowY=dy+Math.round(hH*0.42)+Math.round(hH*1.05)+10+Math.round(hD*1.15);
'@

SubRx @'
return {x:Math.round(cx-260),y:top,w:520,h:rowY+16-top};
'@ @'
return {x:Math.round(cx-240),y:top,w:480,h:rowY+16-top};
'@

SubRx @'
var VER='31.33';
'@ @'
var VER='31.34';
'@

$pat = "(?m)^  now:'v31\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.34: When you are down, the timer now sits centred under the word down and everything stacks in one column. Check 31.34 fails on v31.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
