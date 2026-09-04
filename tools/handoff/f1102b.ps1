$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
# ---- A GUARD THAT RETURNS THROWS AWAY WHAT WAS ALREADY FOUND. On the old build
# ---- this reported the missing memory and silently dropped the missing
# ---- explanation, which is half his question.
SubRx @'
       if(typeof fsMark!=='function'||typeof fsBackNote!=='function')
         return 'the build does not remember that he was in fullscreen when he switched save, so his question has no answer in the game';
       try{ localStorage.removeItem(KEY); }catch(_r1){}
'@ @'
       if(typeof fsMark!=='function'||typeof fsBackNote!=='function'){
         bad.push('the build does not remember that he was in fullscreen when he switched save, so his question has no answer in the game');
         return bad.join('; ');
       }
       try{ localStorage.removeItem(KEY); }catch(_r1){}
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
