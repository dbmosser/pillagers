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

# A ROUND THAT BREAKS A WRECK NO LONGER BOUNCES OFF IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        var _pf=ricoFace(b,_struck,ux,uy)?null:penFactor(_struck);   // v26.xx (feel18): a glancing round at steel glances, it does not punch through
'@ @'
        // v28.56 (cloud-feel-rico-wreck-gone), CLOUD HUNT 2026-10-15: a round that breaks the wreck it strikes bounced off a wall that was gone; it
        // glances only while the struck wall still stands (damageWall above counts it down), otherwise it goes on as it did before feel18.
        var _rs=!!_struck&&!(_struck.hpLeft<=0);   // on a linked window the host takes the broken wall away a moment later, so the wall's own strength decides in both windows
        var _pf=(_rs&&ricoFace(b,_struck,ux,uy))?null:penFactor(_struck);   // v26.xx (feel18): a glancing round at steel glances, it does not punch through
'@

SubRx @'
          if(ricochetOff(b,_struck,ux,uy)) punched=true; else hit=true;   // v26.xx (feel18): off steel once
'@ @'
          if(_rs&&ricochetOff(b,_struck,ux,uy)) punched=true; else hit=true;   // v26.xx (feel18): off steel once   // v28.56 (cloud-feel-rico-wreck-gone), CLOUD HUNT 2026-10-15: only off a wall still standing
'@

SubRx @'
var VER='28.55';
'@ @'
var VER='28.56';
'@

$pat = "(?m)^  now:'v28\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.56: A shot that breaks a wreck no longer bounces off the empty space where the wreck was. Check 28.56 fails on v28.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
