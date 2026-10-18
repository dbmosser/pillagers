$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'31.07',what:")) { throw "check 31.07 is in the fixture already" }

SubRx @'
  {v:'31.06',what:
'@ @'
  {v:'31.07',what:'the how to play page spells out left stick and right stick (the critic: L STICK is cryptic)',
   run:function(){
     if(typeof arcadeKeyWord!=='function') return 'the how to play keys still say L STICK and R STICK (no arcadeKeyWord)';
     if(arcadeKeyWord('L STICK')!=='LEFT STICK') return 'L STICK is '+arcadeKeyWord('L STICK');
     if(arcadeKeyWord('R STICK')!=='RIGHT STICK') return 'R STICK is '+arcadeKeyWord('R STICK');
     if(arcadeKeyWord('A')!=='A') return 'a plain key changed';
     var c=document.createElement('div'); arcadeAttKeys(c,'L STICK');
     if(!/left stick/i.test(c.textContent)) return 'the cell reads '+c.textContent;
     return null; }},
  {v:'31.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
