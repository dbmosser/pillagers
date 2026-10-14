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

# THE SELF-REVIVE SAYS SO AGAIN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.tel.revives++; if(!injFoley('revive')) blip('pick'); try{ sndRevLand(); }catch(_rl){}   // v25.40 (usefoleyd): the injector and the gear say('SELF-REVIVE USED','info',{sub:'Back on your feet.'});   // v22.xx (R51): the caps headline, the rest as the detail
'@ @'
  G.tel.revives++; if(!injFoley('revive')) blip('pick'); try{ sndRevLand(); }catch(_rl){}   // v25.40 (usefoleyd): the injector and the gear sound it
  // v26.13 (nightfix4), found by the overnight regression run of 2026-10-13 (check 23.04): THE SELF-REVIVE SAYS SO AGAIN. v25.40 gave it the injector and gear sounds, and
  // the note for that was written in front of the callout, which turned the say() call into comment text: since then getting up on your own said nothing on screen.
  // The callout is back as v22.xx (R51) had it, the caps headline with the rest as the detail, beside the new sounds.
  say('SELF-REVIVE USED','info',{sub:'Back on your feet.'});
'@

SubRx @'
var VER='26.12';
'@ @'
var VER='26.13';
'@

$pat = "(?m)^  now:'v26\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.13: Getting up with the self-revive says SELF-REVIVE USED again, along with the new sounds. Check 26.13 fails on v26.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
