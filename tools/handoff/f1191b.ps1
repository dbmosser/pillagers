$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Check 11.30 asserted the TAB-then-ENTER message that v11.91 deliberately
# removes (his order: the belt key equips the gun it shows). The v11.91
# corpus was green on 322 of 323 with this one red. Rewritten to the new
# contract: the key brings the backpack gun up and names no detour. Fails on
# the v11.90 fixture, where the message names ENTER and the pistol stays
# bagged. Idempotent.
$enc = New-Object Text.UTF8Encoding $false
function L { param([string[]]$lines) return ($lines -join "`n") }
function RepRx([string]$path, [string]$old, [string]$new, [int]$n) {
  $s = [IO.File]::ReadAllText($path)
  if ($s.IndexOf($new) -ge 0) { Write-Output ('already repaired: ' + $old.Substring(0, [Math]::Min(40, $old.Length))); return }
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne $n) { throw ('anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ('repaired: ' + $old.Substring(0, [Math]::Min(40, $old.Length)))
}
$M = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
RepRx $M "  {v:'11.30',what:'a belt key for a gun still in the backpack names the key that equips it, ENTER, and not TAB alone; a belt key for the gun in hand says nothing of the sort'," "  {v:'11.30',what:'a belt key for a gun still in the backpack brings it up (v11.91) with no TAB-then-ENTER message, and a belt key for the gun in hand says nothing of the sort'," 1
RepRx $M (L @(
  "     if(m.indexOf(wrong)>=0) bad.push('the belt key still says ""'+m+'""');",
  "     if(m.indexOf('ENTER')<0) bad.push('the belt key does not name ENTER: ""'+m+'""');",
  "     if(m.indexOf('backpack')<0) bad.push('control: the belt key did not produce the backpack message at all: ""'+m+'"", so key 3 did not reach the pistol');")) (L @(
  "     // v11.91, HIS ORDER: the key EQUIPS the gun it shows; the v11.30 message",
  "     // that named ENTER is gone with the detour it described.",
  "     if(m.indexOf(wrong)>=0) bad.push('the belt key still says ""'+m+'""');",
  "     if(m.indexOf('ENTER')>=0) bad.push('the belt key still names ENTER: ""'+m+'""');",
  "     if(!(p.wep&&p.wep.id==='pistol')) bad.push('key 3 did not bring the backpack pistol up (in hand: '+(p.wep&&p.wep.id)+', said ""'+m+'"")');",
  "     if(g.bag.indexOf('gun_pistol')>=0) bad.push('the pistol is still in the backpack after key 3');")) 1
