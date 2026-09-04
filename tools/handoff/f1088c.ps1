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

# ==== A SIXTH CHECK READ THE DELETED CARDS, and the full run found it rather
# ==== than me: v10.08 asks whether the old name for the Pillbox survives on any
# ==== surface, and one of its surfaces was the guide cards. It refused to pass
# ==== on a missing source, which is exactly right, and said so.
# ==== Same treatment as v10.26: the surface goes, the check stays. The feeling
# ==== tags are still read and are still a surface a player sees.
SubRx @'
     // The guide card and the feeling tags are read as data.
     var cards=(typeof PRIMER!=='undefined')?JSON.stringify(PRIMER):'';
     var tags=(typeof TAGS!=='undefined')?JSON.stringify(TAGS):'';
     if(!cards||!tags) bad.push('this fixture could not read the guide cards or the feeling tags');
     if(cards&&isWord(cards,OLDL)) bad.push('a guide card still says '+OLDL);
     if(tags&&isWord(tags,OLDL)) bad.push('a feeling tag still says '+OLDL);
'@ @'
     // v10.88: the guide cards were the FIRST TIME OUT card and are deleted. The
     // feeling tags are still a surface a player reads, and are still read here.
     var tags=(typeof TAGS!=='undefined')?JSON.stringify(TAGS):'';
     if(!tags) bad.push('this fixture could not read the feeling tags');
     if(tags&&isWord(tags,OLDL)) bad.push('a feeling tag still says '+OLDL);
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
