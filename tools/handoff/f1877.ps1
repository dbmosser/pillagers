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

if ($s.Contains("  {v:'18.77',what:")) { throw "check 18.77 is in the fixture already" }

SubRx @'
  {v:'18.76',what:
'@ @'
  {v:'18.77',what:'the gambler window lines are centred like its title and cards: the credits line and Wirt line read centred, never flush against the panel edge',
   run:function(){
     var a=document.getElementById('wallet_gamble'), b=document.getElementById('gamble_line'), bad=[];
     if(!a||!b) return 'SKIP: no gambler window here';
     if(getComputedStyle(a).textAlign!=='center') bad.push('the credits line is '+getComputedStyle(a).textAlign+' aligned');
     if(getComputedStyle(b).textAlign!=='center') bad.push('the Wirt line is '+getComputedStyle(b).textAlign+' aligned');
     return bad.length?bad.join('; '):null; }},
  {v:'18.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
