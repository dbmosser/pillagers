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

if ($s.Contains("  {v:'30.16',what:")) { throw "check 30.16 is in the fixture already" }

SubRx @'
  {v:'30.15',what:
'@ @'
  {v:'30.16',what:'the operator backdrop is solid (the board page behind it never shows through as ghost words; critic on 62 and 63)',
   run:function(){
     if(typeof arcadeOpOpen!=='function'||typeof arcadeOpClose!=='function'||typeof ARCADE!=='object'||!ARCADE) return 'SKIP: no operator card';
     var was=ARCADE.on, op, bd, a, res=null, al;
     try{
       ARCADE.on=true;
       if(!arcadeOpOpen()) return 'the operator card did not open';
       op=document.getElementById('arcop'); if(!op) return 'no operator card element';
       bd=op.previousElementSibling; if(!bd) return 'no backdrop element';
       a=getComputedStyle(bd).backgroundColor;
       al=/\/\s*([0-9.]+)\s*\)/.exec(a); al=al?parseFloat(al[1]):(/rgba\([^)]*,\s*([0-9.]+)\)/.exec(a)?parseFloat(/rgba\([^)]*,\s*([0-9.]+)\)/.exec(a)[1]):1);
       if(al<0.999) res='the operator backdrop is '+a+', not solid';
       return res;
     } finally { try{ arcadeOpClose(); }catch(e){} ARCADE.on=was; }
   }},
  {v:'30.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
