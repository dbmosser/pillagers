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

# THE IN-RING INBOUND PROMPT STEPS ASIDE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      } else if(padZ.beaconT!==null){
        ctx.fillStyle='#4de3d0';
        ctx.fillText('INBOUND '+Math.ceil(padZ.beaconT)+'s',ps.x,ps.y);
'@ @'
      } else if(padZ.beaconT!==null){
        // v22.41, the raid text rewrite (R15): THE IN-RING INBOUND PROMPT STEPS ASIDE. Standing in the ring he called, this printed
        // INBOUND and its seconds over his own character while the band above the belt said EXTRACT A INBOUND with the same seconds.
        // While this ring is the one the band counts in, the prompt steps aside, as the CALL and EXTRACT prompts already do (v19.56).
        // A ring that is not the active one keeps it.
        if(!(G.active===padZ&&G.beaconT!==null&&G.beaconT!==undefined&&!G.over)){
          ctx.fillStyle='#4de3d0';
          ctx.fillText('INBOUND '+Math.ceil(padZ.beaconT)+'s',ps.x,ps.y);
        }
'@

SubRx @'
var VER='22.40';
'@ @'
var VER='22.41';
'@

$pat = "(?m)^  now:'v22\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.41: Standing in the ring you called, INBOUND shows once, in the band above the belt. Check 22.41 fails on v22.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
