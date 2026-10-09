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

# THE HIRE TAB GREYS WHAT YOU CANNOT AFFORD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      cell.className='vcell'+(i===P._mercSel?' on':'')+((cost===null)?' locked':'');
'@ @'
      cell.className='vcell'+(i===P._mercSel?' on':'')+((cost===null)?' locked':'')+((cost!==null&&P.merc!==ID.id&&cost>(P.credits||0))?' poor':'');   // v21.47: a hire you cannot pay for reads grey, as the shop does (v21.46)
'@

SubRx @'
var VER='21.46';
'@ @'
var VER='21.47';
'@

$pat = "(?m)^  now:'v21\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.47: The hire tab shows fees you cannot afford in grey, as the shop does. Check 21.47 fails on v21.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
