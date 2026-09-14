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

# CONTRACTS, NOTORIETY AND WAVES AUDIT OF 2026-09-14, finding 5: A HIRE WHO DIED ON YOUR JOB TWICE WAS
# ANNOUNCED AS YOUR RIVAL. myRival scores an identity by kills plus deaths, and the only thing that ever
# writes deaths is a hired merc dying on your job. So a hire rehired after dying twice became YOUR RIVAL:
# his entity carried the rival flag and star, and four seconds in the game told you the companion who
# cannot shoot you would shoot on sight. A rival is someone you have killed; the score reads kills
# alone, and the announcement never names a hire.
SubRx @'
    var r=P.rivals[id],f=(r.kills||0)+(r.deaths||0);
'@ @'
    var r=P.rivals[id],f=(r.kills||0);   // v13.94: kills alone. deaths is only ever a hire dying on your job.
'@
SubRx @'
    if(G.ents[_rv].rival){
'@ @'
    if(G.ents[_rv].rival&&!G.ents[_rv].merc){   // v13.94, contracts audit: never announce your own hire
'@
SubRx @'
var VER='13.93';
'@ @'
var VER='13.94';
'@

$pat = "(?m)^  now:'v13\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.94: A HIRE WHO DIED ON YOUR JOB IS NOT YOUR RIVAL. Contracts, notoriety and waves audit of 2026-09-14, finding 5: myRival scored an identity by kills plus deaths, and deaths is only written when a hire dies on your job, so a hire who had died twice became YOUR RIVAL, carried the rival star and was announced as shooting on sight while he walked beside you. The score now reads kills alone and the announcement never names a hire. Check 13.94 requires an identity with two deaths and no kills not to be the rival, with an identity of two kills as the rival as the control; it fails on v13.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
