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

# at the party f2 and f8 need ctrl held, so a guest cannot freeze a raid by accident (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// The tag: a small plate top left (under SHOW FPS, clear of the upper right corner)
'@ @'
// v30.xx (cw-partykeys), the coordinator: AT THE PARTY F2 AND F8 NEED CTRL. The party launch mode (?party=1, and the 2 player arcade demo played from it) is a guest on keyboard and mouse at localhost, so these two
// keys are live there, and the F keys sit right above the gun number keys: a stray F2 or F8 froze the raid in a state the guest cannot read. In party mode a plain F2 or F8 is not taken (nothing changes, nothing
// is swallowed) and Ctrl+F2 and Ctrl+F8 do the job, the same hidden-operator pattern as the Ctrl+Shift+F10 operator card. Outside party mode the keys are exactly what they were (a Ctrl chord is still not taken there).
function partyKeyOk(e){ if(!e||e.altKey||e.metaKey||e.shiftKey) return false; return PARTY?!!e.ctrlKey:!e.ctrlKey; }
// The Ctrl that starts the chord has already flipped the crouch in raidKey (one change per press), so the chord gives that one change back, exactly as Ctrl with the wheel does (v15.65): a party guest who
// uses the chord keeps the stance he had.
function partyCtrlGive(e){ try{ if(PARTY&&e&&e.ctrlKey&&G&&!G.over&&!G.sim&&('ctrlUndo' in G)&&G.ctrlUndo!==null&&(keys.ControlLeft||keys.ControlRight)){ G.crouchTog=G.ctrlUndo; G.ctrlUndo=null; } }catch(_pg){} }   // 'in', not != null: a stance that was never set is undefined, and that is a stance too
// The tag: a small plate top left (under SHOW FPS, clear of the upper right corner)
'@

SubRx @'
el.textContent='edit words: on (f2)';
'@ @'
el.textContent=PARTY?'edit words: on (ctrl f2)':'edit words: on (f2)';
'@

SubRx @'
if(e.ctrlKey||e.altKey||e.metaKey||e.shiftKey) return;
'@ @'
if(!partyKeyOk(e)) return;   // v30.xx (cw-partykeys): in party mode the chord is Ctrl+F2, plain F2 does nothing
'@

SubRx @'
try{ txKeyToggle(); }catch(_t){}
'@ @'
partyCtrlGive(e); try{ txKeyToggle(); }catch(_t){}
'@

SubRx @'
if(e.code==='F8'&&!(e.ctrlKey||e.altKey||e.metaKey||e.shiftKey)){
'@ @'
if(e.code==='F8'&&partyKeyOk(e)){   // v30.xx (cw-partykeys): in party mode the chord is Ctrl+F8, plain F8 does nothing
'@

SubRx @'
try{ if(SNIP.on) snipEnd('key'); else snipStart(); }catch(_t){}
'@ @'
partyCtrlGive(e); try{ if(SNIP.on) snipEnd('key'); else snipStart(); }catch(_t){}
'@

SubRx @'
['EDIT THE WORDS','F2']
'@ @'
['EDIT THE WORDS',PARTY?'CTRL + F2':'F2']
'@

SubRx @'
['SNIP THE SCREEN','F8']
'@ @'
['SNIP THE SCREEN',PARTY?'CTRL + F8':'F8']
'@

SubRx @'
F2 turns it on and off from anywhere, and a raid stands still while it is on.
'@ @'
'+(PARTY?'Ctrl with F2 turns':'F2 turns')+' it on and off from anywhere, and a raid stands still while it is on.
'@

SubRx @'
var VER='31.36';
'@ @'
var VER='31.37';
'@

$pat = "(?m)^  now:'v31\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.37: At the party, F2 and F8 now need Ctrl held, so a stray press from a guest does nothing. Ctrl and F2 edits the words, Ctrl and F8 snips. Check 31.37 fails on v31.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
