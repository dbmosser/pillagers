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

# THE NOTORIETY BANNER SAID THE PEDDLER WAS DONE WITH YOU. His ruling at v8.28
# was that the Peddler always trades regardless of notoriety, and pedOpen has
# answered true ever since; the hub card was renamed at the same build. The
# in-raid banner that fires when the score reaches two still said the stall
# had shut. It names what notoriety actually costs now, at every score.
SubRx @'
  if(n>=2) return 'The Peddler is done with you.';
  return 'Hiring costs more and pillagers are slower to trust you.';
'@ @'
  // v11.60: the stall never shuts (pedOpen, his v8.28 ruling); this said it did.
  if(n>=2) return 'Hiring costs more and pillagers are slower to trust you. Word has got round.';
  return 'Hiring costs more and pillagers are slower to trust you.';
'@
SubRx @'
// 2 gets its own word because 2 is where the stall actually shuts.
'@ @'
// 2 gets its own word because 2 is where the stall used to shut (it never shuts
// since v8.28; the banner caught up at v11.60).
'@

# STAMPS.
SubRx @'
var VER='11.59';
'@ @'
var VER='11.60';
'@
SubRx @'
var WHATSNEW_VER='11.59';
'@ @'
var WHATSNEW_VER='11.60';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE NOTORIETY BANNER STOPPED LYING ABOUT THE PEDDLER. At two notoriety it said the Peddler was done with you; he has traded with anyone since the stall stopped shutting. It says what notoriety really costs now.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.59:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.59 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.59:[^']*'",{ param($m) "now:'v11.60: the in-raid notoriety banner at two or more said the Peddler was done with you, while the stall has never shut since his v8.28 ruling (pedOpen answers true) and the hub card was renamed then. The banner names the real cost at every score now. From the v11.46 audit, P2.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
