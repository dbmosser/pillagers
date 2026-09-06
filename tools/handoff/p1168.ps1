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

# DROPPING A TACTICAL BELT ITEM ON THE STASH SAID "BACK IN THE BACKPACK" while
# taking it OUT of the backpack. The drop (v8.72) clears its belt key, splices
# it from the kit, and it lands in the stash, which is where the pointer let go
# of it. The line names the stash now, the word the rest of the room uses.
SubRx @'
      say2((ITEMS[key]?ITEMS[key].name:key)+' back in the backpack.');
'@ @'
      say2((ITEMS[key]?ITEMS[key].name:key)+' back in the stash.');   // v11.68: it left the backpack
'@

# STAMPS.
SubRx @'
var VER='11.67';
'@ @'
var VER='11.68';
'@
SubRx @'
var WHATSNEW_VER='11.67';
'@ @'
var WHATSNEW_VER='11.68';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'DROPPING A BELT ITEM ON THE STASH NOW SAYS WHERE IT WENT. It said "back in the backpack" while taking it out of the backpack; it went to the stash, and the line says so.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.67:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.67 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.67:[^']*'",{ param($m) "now:'v11.68: dropping a tactical belt item on the stash said back in the backpack while splicing it out of the backpack (v8.72 drop: clears the belt key, leaves the kit, lands in the stash). The line names the stash now. From the v11.46 audit, P2.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
