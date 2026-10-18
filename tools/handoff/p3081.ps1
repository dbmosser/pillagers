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

# no multiplier beside the combo ring at the cursor (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
, cb, cs, tm, bx, bh, bw, bs, tn, big=(mx>=4);
'@ @'
, cb, cs;
'@

SubRx @'
    c.font=hudFS(big?TYPE.huge:TYPE.title); c.textAlign='left'; c.textBaseline='alphabetic';
    tn='x'+mx; bh=Math.round((big?42:34)*z); bw=Math.round(c.measureText(tn).width+20*z);
    tm=(typeof ARCADE==='object'&&ARCADE&&G.arcade&&!ARCADE.solo&&ARCADE.team&&Date.now()-ARCADE.team.at<TEAM.win*1000);
    bx=Math.round(rx+r+(tm?30:14)*z); bs=1+STYR.bump*gp+(lo?0.07*Math.sin(t*STYR.hz):0);
    c.save(); c.translate(bx+bw/2,ry); c.scale(bs,bs); c.translate(-(bx+bw/2),-ry);
    hudPlate(bx,Math.round(ry-bh/2),bw,bh,'rgb('+cs+')','rgba(8,10,13,.86)');
    c.fillStyle='rgb('+cs+')'; hudText(tn,bx+Math.round(11*z),Math.round(ry+(big?14:9.5)*z));
    c.restore();

'@ @'
    // cw-nomult, HIS ORDER (2026-10-18): "i don't like the multiplier next to the reticule, get rid of that". The number and its plate beside the ring are gone;
    // the ring, its sweep, the flash and the flicker stay (his survey pick q17 keeps the ring at the cursor). The multiplier still shows left of the score.
'@

SubRx @'
var VER='30.80';
'@ @'
var VER='30.81';
'@

$pat = "(?m)^  now:'v30\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.81: The multiplier number next to the aiming ring is gone. The ring stays. Check 30.81 fails on v30.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
