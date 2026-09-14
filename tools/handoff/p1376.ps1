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

# DOWNED AND EXTRACTION AUDIT OF 2026-09-14, finding 4: BACKING OUT IN THE FIRST SECOND AND A HALF
# DELETED AN ARMOURY GUN YOU HAD PUT IN THE BACKPACK. Dragging your gun off the belt into the
# backpack takes it off the armoury list and records it on G.spliced, so an abandoned raid can
# put it back. endRaid does that in the abandon branch, but an abandon inside 1.5 seconds with
# nothing walked, searched or fired takes the discard path first, which throws the raid away as
# never having happened and returns before that branch. The backpack holding the gun went with
# it. The discard path now puts the spliced guns back too.
SubRx @'
    if(!G.sim){ dropDeadKeys(); saveProfile(); }
    G=null; keys={};
'@ @'
    // v13.76, downed and extraction audit: an armoury gun spliced out in these first moments
    // goes back, exactly as the abandon branch below puts it back. This path returned first.
    if(!G.sim&&G.spliced) for(var _sq=0;_sq<G.spliced.length;_sq++) if(P.weapons.indexOf(G.spliced[_sq])<0) P.weapons.push(G.spliced[_sq]);
    if(!G.sim){ dropDeadKeys(); saveProfile(); }
    G=null; keys={};
'@
SubRx @'
var VER='13.75';
'@ @'
var VER='13.76';
'@

$pat = "(?m)^  now:'v13\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.76: BACKING OUT AT ONCE NO LONGER DELETES A GUN YOU BAGGED. Downed and extraction audit of 2026-09-14, finding 4: bagging your armoury gun takes it off the armoury and records it on G.spliced for an abandon to put back, but an abandon inside 1.5 seconds with nothing done takes the discard path, which returned before the abandon branch that restores it, so the gun was gone. The discard path now restores the spliced guns. Check 13.76 bags the armoury carbine and abandons at once, requiring the carbine back in the armoury, with the same abandon five seconds in as the control; it fails on v13.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
