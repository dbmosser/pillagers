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

# YOUR TEAMMATE SEES THE DAMAGE YOU TAKE. His note of 2026-09-27.

SubRx @'
  p.hp-=amt;
'@ @'
  p.hp-=amt;
  if(NET.on&&!G.sim&&amt>0.5&&CFG.dmgNumbers!==0){ try{ netFxDmg(p.x,p.y-26,Math.round(amt),'#ff5a4a',p.hp<=0); }catch(_nfd){} }   // v16.25, his note: your teammate sees the damage you take, in red, over you
'@

SubRx @'
var VER='16.24';
'@ @'
var VER='16.25';
'@

$pat = "(?m)^  now:'v16\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.25: YOUR TEAMMATE SEES THE DAMAGE YOU TAKE. His note. In co-op every hit that gets through your armour shows on your teammate screen as a red number over you. No number moved. Check 16.25 fails on v16.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
