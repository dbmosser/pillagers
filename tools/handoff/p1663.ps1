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

# A SPECTATING HOST TAKES NO DAMAGE OF ANY KIND (co-op review 2026-09-27; v16.56 covered rounds only).

SubRx @'
  if(G&&((G.deathBeat!==undefined&&G.deathBeat!==null)||(G.player&&G.player.dying))) return;
'@ @'
  if(G&&((G.deathBeat!==undefined&&G.deathBeat!==null)||(G.player&&G.player.dying))) return;
  // v16.63, stability (review of v16.56): a host who left the raid and is spectating has no body in it. v16.56 let enemy
  // rounds pass where he stood, but frag blasts, shells and every other hurt still reached him: grunts in his window and red
  // numbers on empty ground for his teammate. Nothing hurts a spectating host now.
  if(G&&G.player&&G.player.specOut) return;
'@

SubRx @'
var VER='16.62';
'@ @'
var VER='16.63';
'@

$pat = "(?m)^  now:'v16\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.63: A SPECTATING HOST TAKES NO DAMAGE OF ANY KIND. Stability pass before a co-op session. v16.56 let enemy rounds pass where a spectating host stood, but frag blasts, shells and every other hurt still reached his empty body: grunts in his window and red numbers on empty ground for his teammate. Nothing hurts a spectating host now. Check 16.63 fails on v16.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
