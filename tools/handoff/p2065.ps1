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

# A LISTENER HEARS PLAYER 2 RUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          var _lr=(_lf?(G.sprinting?300:210):(G.sprinting?430:290))*(CFG.listenGain===undefined?1.35:CFG.listenGain)/1.35;
'@ @'
          // v20.65, from the whole-game bug hunt of 2026-10-08 (H14): THE SPRINT OF WHICHEVER PLAYER IT HUNTS, as the crouch on the
          // line above already is. It read the host sprint, so in co-op player 2 sprinting was heard only out to the walking reach
          // (210, not 300) and slipped it, and player 2 walking was tracked out to the sprinting reach whenever the host ran.
          // Solo is unchanged: the host is the only player it hunts.
          var _lsp=(p.net?p.sp:G.sprinting);
          var _lr=(_lf?(_lsp?300:210):(_lsp?430:290))*(CFG.listenGain===undefined?1.35:CFG.listenGain)/1.35;
'@

SubRx @'
var VER='20.64';
'@ @'
var VER='20.65';
'@

$pat = "(?m)^  now:'v20\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.65: In co-op, a hunting Listener now hears player 2 by his own sprint, not the sprint of the host. Check 20.65 fails on v20.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
