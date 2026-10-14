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

# NO STARTER GUN IN THE CLASS KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GUN_CLASS_OF={pistol:'pistol',magnum:'pistol',tacker:'pistol',smg:'smg',sputter:'smg',rifle:'rifle',chatter:'rifle',carbine:'carbine',lmg:'lmg',shotgun:'shotgun',scuttle:'shotgun',dmr:'marksman',whisper:'marksman',sniper:'sniper',lance:'energy'};
'@ @'
var GUN_CLASS_OF={pistol:'pistol',magnum:'pistol',smg:'smg',rifle:'rifle',carbine:'carbine',lmg:'lmg',shotgun:'shotgun',dmr:'marksman',whisper:'marksman',sniper:'sniper',lance:'energy'};   // v26.39 (nostarters2): the four starter guns are in no table
'@

SubRx @'
var VER='26.38';
'@ @'
var VER='26.39';
'@

$pat = "(?m)^  now:'v26\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.39: The four removed starter guns are out of the class key table too, and a check keeps them out of every table. Check 26.39 fails on v26.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
