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

if ($s.Contains("  {v:'24.78',what:")) { throw "check 24.78 is in the fixture already" }

SubRx @'
  {v:'24.77',what:
'@ @'
  {v:'24.78',what:'his #50 (UI redesign ui5q1u, from the 4K visual QA of the attract HOW TO PLAY page): an attract page keeps growing with the screen past 30px type (the cap is 60px), so at 4K it is the same share of the screen as at 1080p',
   run:function(){
     var css=document.getElementById('arcattcss'), t, m;
     if(!css&&typeof arcadeAttEl==='function'){ try{ arcadeAttEl('arcpage'); }catch(_a){} css=document.getElementById('arcattcss'); }
     if(!css) return 'SKIP: no attract page style here';
     t=css.textContent||''; m=/\.arcpage\{[^}]*clamp\(12px,1\.15vw,(\d+)px\)/.exec(t);
     if(!m) return 'the attract page size rule was not found';
     if(+m[1]<60) return 'the attract page type stops growing at '+m[1]+'px, half size on a 4K screen';
     return null; }},
  {v:'24.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
