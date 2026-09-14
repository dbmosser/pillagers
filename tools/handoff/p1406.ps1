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

# SAVING, PROFILE AND SETTINGS AUDIT OF 2026-09-15, finding 2: UNDO'S BACKUP WAS ONE KEY FOR EVERY SAVE SLOT, AND A RESTORE
# CODE NEVER WROTE IT. Each save slot has its own storage key, but the pre-restore backup UNDO goes back to was one fixed
# key. A file restore in save 1 made UNDO appear in save 2, and pressing it turned save 2 into save 1's old character,
# with save 2's own character left only in that shared key for the next restore anywhere to overwrite. And pasting a
# restore code wrote no backup at all, so UNDO brought back whatever an older file restore had kept. The backup now
# lives under the slot's own key (save 1's key is unchanged), and a restore code keeps the character it replaces.
SubRx @'
var SKEY=(SLOT==='1')?'salvagerun:profile':('salvagerun:profile:'+SLOT);
'@ @'
var SKEY=(SLOT==='1')?'salvagerun:profile':('salvagerun:profile:'+SLOT);
var RESTORE_BACKUP_KEY=SKEY+':prerestore';   // v14.06, save audit: each slot keeps its own UNDO backup; save 1 keeps the old key name
'@
SubRx @'
try{ return localStorage.getItem('salvagerun:profile:prerestore')||''; }catch(_e){ return ''; }
'@ @'
try{ return localStorage.getItem(RESTORE_BACKUP_KEY)||''; }catch(_e){ return ''; }
'@
SubRx @'
try{ localStorage.setItem('salvagerun:profile:prerestore',JSON.stringify(P)); }catch(_e2){}
'@ @'
try{ localStorage.setItem(RESTORE_BACKUP_KEY,JSON.stringify(P)); }catch(_e2){}
'@
SubRx @'
try{ localStorage.setItem('salvagerun:profile:prerestore',JSON.stringify(P)); }catch(e3){}
'@ @'
try{ localStorage.setItem(RESTORE_BACKUP_KEY,JSON.stringify(P)); }catch(e3){}
'@
SubRx @'
    var o=pend;
    if(!restoreApply(o)) return;
'@ @'
    var o=pend;
    // v14.06, save audit: the character a code replaces is kept for UNDO, as a file restore keeps it.
    try{ localStorage.setItem(RESTORE_BACKUP_KEY,JSON.stringify(P)); }catch(_pk){}
    if(!restoreApply(o)) return;
'@
SubRx @'
var VER='14.05';
'@ @'
var VER='14.06';
'@

$pat = "(?m)^  now:'v14\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.06: UNDO KEEPS ITS OWN SLOT AND A RESTORE CODE KEEPS THE CHARACTER IT REPLACES. Saving, profile and settings audit of 2026-09-15, finding 2: the pre-restore backup was one fixed key for every save slot, so a file restore in save 1 made UNDO in save 2 turn it into save 1 old character, and pasting a restore code wrote no backup at all. The backup now uses the slot own key, save 1 keeping the old name, and a restore code writes it before applying. Check 14.06 pastes a code through the real READ and REPLACE buttons and requires the backup to hold the character it replaced, with the code applied as the control; it fails on v14.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
