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

if ($s.Contains("  {v:'32.08',what:")) { throw "check 32.08 is in the fixture already" }

SubRx @'
  {v:'32.07',what:
'@ @'
  {v:'32.08',what:'pause box small buttons and the abandon link are at least 48px high',
   run:function(){
     var css=''; for(var i=0;i<document.styleSheets.length;i++){ try{ var rs=document.styleSheets[i].cssRules; for(var j=0;j<rs.length;j++){ css+=rs[j].cssText; } }catch(e){} }
     if(!/#fbbtn[^{]*\{[^}]*min-height: var\(--btn-h-sm\)/.test(css)) return 'fbbtn is not 48px high';
     if(!/#abandonbtn[^{]*\{[^}]*min-height: var\(--btn-h-sm\)/.test(css)) return 'abandon link is not 48px high';
     return null; }},
  {v:'32.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
