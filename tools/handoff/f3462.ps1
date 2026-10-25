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

if ($s.Contains("  {v:'34.62',what:")) { throw "check 34.62 is in the fixture already" }

SubRx @'
  {v:'34.61',what:
'@ @'
  {v:'34.62',what:'cw-setrevert5 (job 113): the restore helper line rules in the shared block have no raw px font size',
   run:function(){
     var css=(document.getElementById('ui-shared')||{textContent:''}).textContent.replace(/\/\*[\s\S]*?\*\//g,''), rs=css.match(/[^{}]*rescode\) > \.msub\s*\{[^}]*\}/g)||[], i, bad=[];
     if(!rs.length) return 'SKIP: no restore helper rule in the shared block';
     for(i=0;i<rs.length;i++) if(/#[0-9a-fA-F]{3,8}\b|rgba?\(|font-size\s*:\s*[\d.]+(px|em|rem)|font\s*:[^;]*[\d.]+px/.test(rs[i].slice(rs[i].indexOf('{')))) bad.push(rs[i].slice(rs[i].indexOf('{'),rs[i].indexOf('{')+60));
     return bad.length?'raw literal in the helper rule: '+bad[0]:null; }},
  {v:'34.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
