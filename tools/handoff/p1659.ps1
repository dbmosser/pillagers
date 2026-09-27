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

# A FAULT WHILE THE HOST SPECTATES IS WRITTEN INTO THE RUN REPORT (stability pass before his co-op session, 2026-09-27).

SubRx @'
    if(NET.specAcc>=NET_HUB_STEP){ NET.specAcc=0; NET.upN++; netEntsTick(); netContTick(); if(NET.upN%5===0) netWorldSend(); }
  }catch(e){}
'@ @'
    if(NET.specAcc>=NET_HUB_STEP){ NET.specAcc=0; NET.upN++; netEntsTick(); netContTick(); if(NET.upN%5===0) netWorldSend(); }
  }catch(e){
    // v16.59, stability (co-op review): a fault here froze the enemies, rounds and searches for the party still up top, and
    // was swallowed without a word, so nothing in any run report said why. It is written into the host run report once.
    if(!NET.specErr){ NET.specErr=1; try{ noteCrash('error','spectate: '+((e&&e.message)||e),crashWhere(e&&e.stack)); }catch(_nc){} }
  }
'@

SubRx @'
  NET.specG=G; NET.specHow=String(how||'extract'); NET.specAcc=0; NET.specIdle=0;
'@ @'
  NET.specG=G; NET.specHow=String(how||'extract'); NET.specAcc=0; NET.specIdle=0; NET.specErr=0;
'@

SubRx @'
var VER='16.58';
'@ @'
var VER='16.59';
'@

$pat = "(?m)^  now:'v16\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.59: A FAULT WHILE THE HOST SPECTATES IS WRITTEN INTO THE RUN REPORT. Stability pass before a co-op session. When the host keeps the raid running for the party after leaving it, a fault there froze the enemies and searches for everyone still up top and was swallowed without a word. It is now written into the host run report once, so it can be found and fixed. Check 16.59 fails on v16.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
