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

# THE STASH POINTS A FIRST RAID AT WHAT TO DO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          <div class="lohead">LOADOUT<em><span id="kitval">0</span>c going up</em></div>
'@ @'
          <div class="lohead">LOADOUT<em><span id="kitval">0</span>c going up</em></div>
          <div id="firstkit" class="hint" style="display:none;margin:4px 0 8px;padding:8px 10px;border:1px solid var(--amber);border-radius:4px;color:var(--amber);font-weight:700;letter-spacing:.04em">FIRST RAID: drag a gun and two heals in here, then go up at ENTER RAID!</div>
'@

SubRx @'
  var kvEl=document.getElementById('kitval');
'@ @'
  var kvEl=document.getElementById('kitval');
  try{ var _fk=document.getElementById('firstkit'); if(_fk) _fk.style.display=((((P&&P.runs)||0)===0)&&_goingUp.length===0)?'':'none'; }catch(_fke){}   // v17.89: a first raid is pointed at
'@

SubRx @'
var VER='17.88';
'@ @'
var VER='17.89';
'@

$pat = "(?m)^  now:'v17\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.89: A new player sees in the stash what to do before the first raid: drag a gun and two heals into the loadout, then go up at ENTER RAID! Check 17.89 fails on v17.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
