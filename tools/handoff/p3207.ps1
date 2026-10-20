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

# EASY MODE YES GIVES A FREE MEDKIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(yes){ ARCADE.easy=1; try{ say('Easy mode on','info'); }catch(_es){} }

'@ @'
  if(yes){
    ARCADE.easy=1; try{ say('Easy mode on','info'); }catch(_es){}
    // v28.xx (cw-easymed), HIS ANSWER (2026-10-18, 3.16 b): when a guest says yes to easier, "30 percent less damage, plus a free medkit". The damage cut was already in (EASY_MUL); the medkit goes in the bag now
    try{ if(G&&Array.isArray(G.bag)) G.bag.push('medkit'); }catch(_em){}
  }

'@

SubRx @'
var VER='32.06';
'@ @'
var VER='32.07';
'@

$pat = "(?m)^  now:'v32\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.07: Saying yes to easy mode now also puts a free medkit in your bag. Check 32.07 fails on v32.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
