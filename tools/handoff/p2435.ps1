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

# A WINDOW SITS IN A DARK ROOM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1b (his #50, from the AAA judge of the Wirt and Last Pour shots): A WINDOW SITS IN A DARK ROOM. The room
     behind a window was dimmed to 82 percent, so round a card window (Wirt, the Last Pour, the Terms, the party) the big station
     signs of the Undercroft still read as cut off words, SHOP, CR and POUR and MAY GLITCH, like a second menu under the first.
     The room is dimmed to 93 percent now: the floor is still there, a shape and no words. */
  #root .modal{ background:radial-gradient(1200px 600px at 50% -10%, rgba(170,164,152,.05), transparent 60%), rgba(6,7,8,.93); }
'@

SubRx @'
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#aeb8c2';
  ctx.fillText('$'+P.credits.toLocaleString()
'@ @'
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#aeb8c2';
  // vNN.xx (ui5q1b, his #50, the Wirt shot): the money line is the floor's, like its heading (v20.88): not painted while a window is open
  if(!hubWinOn()) ctx.fillText('$'+P.credits.toLocaleString()
'@

SubRx @'
var VER='24.34';
'@ @'
var VER='24.35';
'@

$pat = "(?m)^  now:'v24\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.35: The room behind a window is darker, and the floor money line hides while a window is open. Check 24.35 fails on v24.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
