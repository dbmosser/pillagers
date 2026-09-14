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

SubRx @'
      try{ sfx('cache'); }catch(e){}
      renderAvatar(hid,pid);
'@ @'
      // v14.38, audio audit finding 4: WEARING OR UNLOCKING A LOOK MAKES A SOUND. Both successes asked for a voice blip has
      // never had, so they were silent while the failure beside them clanked, and each left a spare panner connected. They
      // use the rare find voice.
      try{ sfx('pickRare'); }catch(e){}
      renderAvatar(hid,pid);
'@
SubRx @'
          try{ sfx('cache'); }catch(e){}
        } else { try{ sfx('clank'); }catch(e){} return; }
'@ @'
          try{ sfx('pickRare'); }catch(e){}   // v14.38: a voice that exists
        } else { try{ sfx('clank'); }catch(e){} return; }
'@
SubRx @'
var VER='14.37';
'@ @'
var VER='14.38';
'@

$pat = "(?m)^  now:'v14\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.38: WEARING OR UNLOCKING A LOOK MAKES A SOUND. Both successes asked for a sound the game has never had, so they were silent while a refusal clanked. They now play the rare find sound. Check 14.38 confirms that voice sounds, that the missing one does not, and that no cosmetic handler still asks for it; it fails on v14.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
