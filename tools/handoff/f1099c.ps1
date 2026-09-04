$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== THE FIRST PAIR SETTLES, THE REST DO NOT MOVE. Run standalone, six
# ==== consecutive draws of the same pillager are byte identical. Run as a check,
# ==== the FIRST pair differs by 621 pixels and every pair after it is exact,
# ==== which is why the three racks measure a clean 0 on the old build and tens of
# ==== thousands on the new one while the drift control complains.
# ==== I have not identified what settles on that first pair and I am not going to
# ==== pretend I have. The measurement stops depending on it instead: every number
# ==== is the SETTLED reading, the smallest of two consecutive pairs, so a one-off
# ==== on the way in cannot become a finding and cannot condemn the instrument.
SubRx @'
     function pair(over){
       var b0=shot(look()), b1=shot(look(over));
       return diff(b0,b1);
     }
     var noise=pair(null);
     if(!(noise>=0)) return 'drawing one pillager threw';
     if(noise>40) bad.push('control: two draws of the same pillager differ by '+noise+' pixels, so this instrument cannot measure a rack');
'@ @'
     function once(over){ var b0=shot(look()), b1=shot(look(over)); return diff(b0,b1); }
     // THE SETTLED READING. The first pair after a resize moves; every pair after
     // it is exact. Two pairs, smallest wins, so nothing that happens once on the
     // way in can be mistaken for a rack.
     function pair(over){ var a=once(over), b=once(over); return (a<0||b<0)?-1:Math.min(a,b); }
     var noise=pair(null);
     if(!(noise>=0)) return 'drawing one pillager threw';
     if(noise>40) bad.push('control: two settled draws of the same pillager differ by '+noise+' pixels, so this instrument cannot measure a rack');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
