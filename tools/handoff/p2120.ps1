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

# THE GUN CARD STEPS ASIDE FOR THE BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    R.x+=_boG.dx; R.y+=_boG.dy; return R; })();   // v8.44: see the note on HUDBOX.body
'@ @'
    R.x+=_boG.dx; R.y+=_boG.dy; return R; })();   // v8.44: see the note on HUDBOX.body
  // v21.20, from the 4K visual pass of 2026-10-08 (V-D10): THE GUN CARD STEPS ASIDE FOR THE BACKPACK. The open backpack panel covered
  // the top left of this card (STOWED, the gun name, the rounds) at every screen size, and the backpack already shows the gun in
  // your hands, its numbers and its rounds at its own top. While the backpack is open the card is not drawn (a clip with no area,
  // so everything below still runs and the box the mouse uses stays where it is); it is back the moment the backpack shuts.
  if(G.bagOpen){ ctx.beginPath(); ctx.rect(0,0,0,0); ctx.clip(); }
'@

SubRx @'
var VER='21.19';
'@ @'
var VER='21.20';
'@

$pat = "(?m)^  now:'v21\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.20: The gun card in the corner hides while the backpack is open, instead of being half covered. Check 21.20 fails on v21.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
