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

if ($s.Contains("  {v:'32.66',what:")) { throw "check 32.66 is in the fixture already" }

SubRx @'
  {v:'32.65',what:
'@ @'
  {v:'32.66',what:'pause box end run has no extra top margin and the divider uses the bright line',
   run:function(){
     var css=''; for(var i=0;i<document.styleSheets.length;i++){ try{ var rs=document.styleSheets[i].cssRules; for(var j=0;j<rs.length;j++){ css+=rs[j].cssText; } }catch(e){} }
     if(!/#abandonbtn[^{]*\{[^}]*margin-top: 0(px)?;/.test(css)) return 'end run still has a top margin';
     if(!/#pausebox > h3[^{]*\{[^}]*border-bottom-color: var\(--ui-line-hi\)/.test(css)) return 'divider is not the bright line';
     return null; }},
  {v:'32.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
