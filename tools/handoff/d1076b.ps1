$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\DESIGN.md'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
Not verified: the other eight layouts drawn and looked at, since the check
'@ @'
### The corpus caught me and it was right

The full run failed on two checks that had nothing to do with the layouts:
the WHAT IS NEW card was still stamped v10.61 against a build at v10.76, so
a friend opening the game on Saturday would read news fifteen builds old.

That is my miss, over fifteen builds. I have been updating the DEVNOW line
every build, which the parse gate enforces, and never the card, which is a
different field with a deliberately different rule: WHATSNEW_VER moves only
when the LIST changes, so the card does not nag on every measurement-only
build. The price of that rule is remembering to move it when the list really
does change, and I did not. It is exactly the failure v10.60 caught, also at
fifteen builds stale.

The card now carries the player-facing half of v10.62 to v10.76: the Copy
report button, a found gun filling the empty slot, F as a melee strike, the
briefing a new character actually reads, the safe pocket saying when it is
not protecting anything, the death screen counting the gun, and the title
screen and stash layouts. Seven lines, straight after the line that says
this is an alpha.

Not verified: the other eight layouts drawn and looked at, since the check
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
