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

if ($s.Contains("  {v:'31.81',what:")) { throw "check 31.81 is in the fixture already" }

SubRx @'
  {v:'31.80',what:
'@ @'
  {v:'31.81',what:'two paired windows: the one the keyboard plays wears a keyboard marker (his 3.5 c)',
   run:function(){
     if(typeof kbMarkWant!=='function'||typeof kbMarkSet!=='function'||typeof kbMarkTick!=='function') return 'no keyboard marker (kbMarkWant, kbMarkSet, kbMarkTick missing)';
     if(kbMarkWant('host',true,true)!==true) return 'the front host window with its partner up has no marker';
     if(kbMarkWant('p2',false,true)!==true) return 'the front player 2 window has no marker';
     if(kbMarkWant('host',true,false)!==false||kbMarkWant('p2',true,false)!==false) return 'a window that is not in front wears the marker';
     if(kbMarkWant('host',false,true)!==false||kbMarkWant('',true,true)!==false) return 'a lone window wears the marker';
     kbMarkSet(true); var e=document.getElementById('kbmark');
     if(!e||e.style.display!=='block'||e.textContent!=='keyboard') return 'the marker chip is not shown as keyboard';
     kbMarkSet(false); if(e.style.display!=='none') return 'the marker chip does not hide';
     return null;
   }},
  {v:'31.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
