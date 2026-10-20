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

# THE EXTRACT INBOUND COUNTDOWN IS THE BIG NUMBER SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudFS(spec){ var f=FS(spec), r=Math.max(1,(typeof hudRes==='function')?hudRes():1); return (r===1)?f:f.replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*r).toFixed(1)+'px'; }); }

'@ @'
function hudFS(spec){ var f=FS(spec), r=Math.max(1,(typeof hudRes==='function')?hudRes():1); return (r===1)?f:f.replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*r).toFixed(1)+'px'; }); }
// v32.xx (cw-extbig), the critic on screen 37: the extract countdown was one of three small cues and no hero. While the ship is inbound the line takes the big-number size (TYPE.huge), the same type as the ammo hero; once it lands it is the callout size again.
function extBanFont(t){ return hudFS((t>0)?TYPE.huge:TYPE.head); }

'@

SubRx @'
    ctx.font=hudFS(TYPE.head); ctx.textAlign='center';
    var holding=G.beaconT<=0&&G.shipHold!==null&&G.shipHold!==undefined;

'@ @'
    ctx.font=extBanFont(G.beaconT); ctx.textAlign='center';   // v32.xx (cw-extbig)
    var holding=G.beaconT<=0&&G.shipHold!==null&&G.shipHold!==undefined;

'@

SubRx @'
var VER='32.34';
'@ @'
var VER='32.35';
'@

$pat = "(?m)^  now:'v32\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.35: While extraction is inbound the countdown line is drawn at the big number size. Check 32.35 fails on v32.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
