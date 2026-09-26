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

# A RESTORE CODE CARRIES THE IMPORTED FRIEND. restoreMake wrote every row of the Mainframe but the friend imported from a run
# report (P.ghost), and restoreApply neither took it from the code nor cleared it, so a restored character inherited the replaced
# character's friend or silently lost their own. One field in the maker, one line in the applier.
SubRx @'
         mr:P.mapRunN||null,
         w:{},s:{}};
'@ @'
         mr:P.mapRunN||null,
         // v15.96, ghost audit finding: A RESTORE CODE CARRIES THE IMPORTED FRIEND. P.ghost is the one row of the Mainframe the
         // code never wrote, so a friend imported from a run report (importGhost) never travelled with the character: a code
         // pasted on a fresh browser came up with the import prompt and the report file was needed again. The friend is the
         // object parseGhost made, seven small fields, so the code grows by under two hundred characters (check 11.03 holds the
         // code under 4000). A character with no friend writes null, which restoreApply reads as none.
         gh:(P.ghost&&typeof P.ghost==='object'&&P.ghost.tag)?P.ghost:null,
         w:{},s:{}};
'@
SubRx @'
  P.merc=null; P.contracts=[]; P.seals={}; P.mapSeen={}; P.discover={}; P.terms=[]; P.notExt=0;
'@ @'
  P.merc=null; P.contracts=[]; P.seals={}; P.mapSeen={}; P.discover={}; P.terms=[]; P.notExt=0;
  // v15.96, ghost audit finding: A RESTORE CODE CARRIES THE IMPORTED FRIEND. The friend imported at the Mainframe (P.ghost) was
  // neither carried by the code nor cleared here, so a code pasted over a character who had imported one kept that friend: the
  // Mainframe still said they walk your raids and applyGhost still dressed a pillager as them on the restored character's raids,
  // while the panel promises the code REPLACES the save. The code's friend now comes through, and a code with none, or one made
  // before this build with no friend field, leaves none, the same rule v15.00 set for the named pillager records. applyGhost
  // already guards the gun by WEAPONS[P.ghost.wep]. No number and no seeded draw moved.
  P.ghost=(o.gh&&typeof o.gh==='object'&&typeof o.gh.tag==='string'&&o.gh.tag)?o.gh:null;
'@
SubRx @'
var VER='15.95';
'@ @'
var VER='15.96';
'@

$pat = "(?m)^  now:'v15\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.96: A RESTORE CODE CARRIES THE IMPORTED FRIEND. A friend imported at the Mainframe from a run report never travelled in a restore code, and a code pasted over a character who had one kept that friend on the Mainframe and in the raids. The code now carries the friend, and a code with none, or an older code, leaves none. Check 15.96 makes a code with a friend and one without and restores each over the other; it fails on v15.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
