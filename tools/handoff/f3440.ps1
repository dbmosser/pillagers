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

if ($s.Contains("  {v:'34.40',what:")) { throw "check 34.40 is in the fixture already" }

SubRx @'
  {v:'34.39',what:
'@ @'
  {v:'34.40',what:'a zero score on the run over card is the hero in tx-1, not dimmed to tx-2 (critic on 52)',
   run:function(){
     var bad=null;
     for(var i=0;i<document.styleSheets.length;i++){ var rs; try{ rs=document.styleSheets[i].cssRules; }catch(e){ continue; }
       for(var j=0;j<rs.length;j++){ var r=rs[j]; if(r.selectorText&&r.selectorText.indexOf('.aos.aoz')>=0&&/tx-2/.test(r.style.cssText)) bad=r.cssText; } }
     if(bad) return 'a zero score is still dimmed: '+bad;
     return null; }},
  {v:'34.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
