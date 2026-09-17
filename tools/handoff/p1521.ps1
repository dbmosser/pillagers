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

SubRx @'
    // v8.24b, audit: THE HIRE SHOOTS FIRST, whatever state he is in. mercEngage
'@ @'
    // v15.21, hire audit finding: A SELF-REVIVE LEAVES YOUR HIRE HALF WAY THROUGH HIS PICKUP. revSaid and revProgP, his
    // coming-for-you line and his 3.2 second pickup clock, were cleared only by a pickup that finished. Press F before he
    // finished and his branch below stopped running with both still set, so on your next down, when the self-revive is
    // spent and he is the only way up, he said nothing and his clock carried on from where it had stopped: still close
    // by, he could pull you up a fraction of a second in. Each frame he runs while you are on your feet now clears both,
    // so every down starts his line and his clock afresh, as the first one does. No text and no number moves.
    if(e.kind==='raider'&&e.merc&&!p.downed){ e.revSaid=0; e.revProgP=0; }
    // v8.24b, audit: THE HIRE SHOOTS FIRST, whatever state he is in. mercEngage
'@
SubRx @'
var VER='15.20';
'@ @'
var VER='15.21';
'@

$pat = "(?m)^  now:'v15\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.21: A SELF-REVIVE LEAVES YOUR HIRE HALF WAY THROUGH HIS PICKUP. If you went down beside your hire and got up on F before he pulled you up, he kept his half done pickup, so on your next down he never said he was coming for you and could pull you up well short of the usual 3.2 seconds. Every down now gets his line and a fresh pickup. Check 15.21 downs you beside him, self-revives part way through his pickup, downs you again and times the second pickup; it fails on v15.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
